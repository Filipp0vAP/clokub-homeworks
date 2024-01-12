## Create SA
resource "yandex_iam_service_account" "meme-sa-s3" {
  folder_id = var.yandex_folder_id
  name      = "sa-storage"
}

## Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.meme-sa-s3.id}"
}

## Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.meme-sa-s3.id
  description        = "static access key for object storage"
}

resource "yandex_compute_instance_group" "meme-lamp-group" {
  name                = "meme-lamp"
  service_account_id  = yandex_iam_service_account.meme-sa-s3.id
  folder_id           = var.yandex_folder_id
  deletion_protection = false
  instance_template {
    name = "node-{instance.index}"

    resources {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        type     = "network-ssd"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.network-1.id
      subnet_ids = ["${yandex_vpc_subnet.subnet-1.id}"]
    }

    metadata = {
      serial-port-enable = 1
      ssh-keys           = "ubuntu:${file("../../id_rsa.pub")}"
      user-data          = "#cloud-config\n runcmd:\n - cd /var/www/html\n - sudo chmod 777 index.html\n - echo '<html><img src=\"http://${yandex_storage_bucket.s3-bucket.bucket_domain_name}/${yandex_storage_object.devops-meme.key}\"/><body>' > index.html\n - cat /etc/hostname >> index.html\n - echo '</body></html>' >> index.html\n - sudo systemctl restart apache2"

    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    zones = ["ru-central1-a"]
  }
  deploy_policy {
    max_unavailable = 2
    max_creating    = 3
    max_expansion   = 0
    max_deleting    = 2
  }
  load_balancer {
    target_group_name        = "meme-group"
    target_group_description = "load balancer meme group"
  }
  depends_on = [yandex_storage_bucket.s3-bucket]
}
resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "network-load-balancer-1"

  listener {
    name = "network-load-balancer-1-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.meme-lamp-group.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
  depends_on = [yandex_compute_instance_group.meme-lamp-group]
}