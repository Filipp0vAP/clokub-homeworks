resource "yandex_compute_instance_group" "k8s-cluster-group" {
  name               = "k8s-cluster"
  service_account_id = var.service_account_id
  folder_id          = var.yandex_folder_id
  instance_template {
    name = "node-{instance.index}"

    resources {
      cores  = 2
      memory = 4
    }

    boot_disk {
      initialize_params {
        image_id = "fd808e721rc1vt7jkd0o"
        size     = 50
      }
    }

    network_interface {
      network_id = yandex_vpc_network.network-1.id
      subnet_ids = ["${yandex_vpc_subnet.subnet-1.id}"]
      nat        = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("/host/netology/id_rsa.pub")}"
    }
  }
  scale_policy {
    fixed_scale {
      size = 5
    }
  }
  allocation_policy {
    zones = ["ru-central1-a"]
  }
  deploy_policy {
    max_unavailable = 2
    max_creating    = 5
    max_expansion   = 2
    max_deleting    = 2
  }
}
