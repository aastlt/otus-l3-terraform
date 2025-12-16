# output.tf

output "instance_id" {
  value       = yandex_compute_instance.vm-1.id
  description = "ID виртуальной машины"
}

output "instance_hostname_fqdn" {
  value       = yandex_compute_instance.vm-1.fqdn
  description = "FQDN хоста виртуальной машины"
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
  description = "Внутренний IP адрес VM-1"
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
  description = "Внешний IP адрес VM-1"
}

output "network_id" {
  value       = yandex_vpc_network.network-1.id
  description = "ID сети"
}
