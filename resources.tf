# resources.tf

## Диски для VM-1
resource "yandex_compute_disk" "boot_disk-1" {
  name           = "boot-disk-1"
  zone           = var.default_zone
  size           = 10
  type           = "network-hdd"
  image_id       = var.image_id
}

resource "yandex_compute_disk" "data_disk-1" {
  name       = "data_disk-1"
  zone       = var.default_zone
  size       = 1
  block_size = 4096
}

## Сеть и подсеть для VM-1
resource "yandex_vpc_network" "network-1" {
  name = var.vpc_network_name
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = var.vpc_subnet_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = var.default_cidr
}
