resource "yandex_kubernetes_cluster" "regional_cluster_1" {
  name        = "my-cluster"
  description = "cluster for netology"
  folder_id   = var.yandex_folder_id
  network_id  = yandex_vpc_network.network-1.id

  kms_provider {
    key_id = yandex_kms_symmetric_key.k8s-key.id
  }

  master {
    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public-subnet-1.zone
        subnet_id = yandex_vpc_subnet.public-subnet-1.id
      }

      location {
        zone      = yandex_vpc_subnet.public-subnet-2.zone
        subnet_id = yandex_vpc_subnet.public-subnet-2.id
      }

      location {
        zone      = yandex_vpc_subnet.public-subnet-3.zone
        subnet_id = yandex_vpc_subnet.public-subnet-3.id
      }
    }

    public_ip = true

    master_logging {
      enabled                    = true
      folder_id                  = var.yandex_folder_id
      kube_apiserver_enabled     = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      audit_enabled              = true
    }
  }

  service_account_id      = yandex_iam_service_account.k8s-editor.id
  node_service_account_id = yandex_iam_service_account.k8s-node-account.id

  release_channel = "STABLE"
}
resource "yandex_kubernetes_node_group" "my-node-group" {
  cluster_id  = yandex_kubernetes_cluster.regional_cluster_1.id
  name        = "node-group"
  description = "node-group"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.public-subnet-1.id}"]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }


  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public-subnet-1.zone
    }
  }
}