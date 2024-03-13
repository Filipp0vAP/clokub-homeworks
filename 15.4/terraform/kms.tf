resource "yandex_kms_symmetric_key" "k8s-key" {
  name              = "k8s-key"
  folder_id         = var.yandex_folder_id
  description       = "key for k8s"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}