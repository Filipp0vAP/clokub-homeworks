## Create SA
resource "yandex_iam_service_account" "k8s-editor" {
  folder_id = var.yandex_folder_id
  name      = "k8s-editor"
}

## Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-k8s-editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-editor.id}"
}

## Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-k8s-static-key" {
  service_account_id = yandex_iam_service_account.k8s-editor.id
  description        = "static access key for sa-k8s-editor"
}

resource "yandex_iam_service_account" "k8s-node-account" {
  folder_id = var.yandex_folder_id
  name      = "k8s-node-account"
}

## Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-k8s-node-push" {
  folder_id = var.yandex_folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-node-account.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "sa-k8s-node-pull" {
  folder_id = var.yandex_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-node-account.id}"
}

## Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-k8s-node-static-key" {
  service_account_id = yandex_iam_service_account.k8s-node-account.id
  description        = "static access key for object storage"
}
resource "yandex_iam_service_account_key" "sa-registry-key" {
  service_account_id = yandex_iam_service_account.k8s-node-account.id
}