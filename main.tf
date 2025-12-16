# main.tf

## Конфигурация VM-1
resource "yandex_compute_instance" "vm-1" {
  name        = var.vm_name
  hostname    = "${var.vm_name}.${var.domain}"
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 2
    gpus   = 0
    core_fraction = 5
  }
  boot_disk {
    disk_id = yandex_compute_disk.boot_disk-1.id
  }
  secondary_disk {
    disk_id = yandex_compute_disk.data_disk-1.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  metadata = {
        serial-port-enable = local.serial-port
        ssh-keys           = local.ssh-keys
  }
}
