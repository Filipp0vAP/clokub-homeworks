## Use keys to create bucket
resource "yandex_kms_symmetric_key" "meme-key" {
  name              = "meme-bucket-key"
  folder_id         = var.yandex_folder_id
  description       = "key for meme bucket"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}

resource "yandex_storage_bucket" "s3-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "filipp0vap-120124"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.meme-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  anonymous_access_flags {
    read = true
    list = true
  }
}

## Create object and upload file
resource "yandex_storage_object" "devops-meme" {
  bucket     = yandex_storage_bucket.s3-bucket.bucket
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  key        = "meme.jpg"
  source     = "./meme.jpg"
  acl        = "public-read"
}