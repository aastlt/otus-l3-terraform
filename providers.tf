# providers.tf

##Yandex Cloud
terraform {
    required_providers {
        yandex = {
            source  = "yandex-cloud/yandex"
            version = ">=0.13"
        }
        local = {
            source  = "hashicorp/local"
            version = "~> 2.0"
        }
        null = {
            source  = "hashicorp/null"
            version = "~> 3.0"
        }
    }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}
