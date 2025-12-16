# ansible.tf

# Генерация inventory файла для Ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    vm_name        = var.vm_name
    external_ip    = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
    internal_ip    = yandex_compute_instance.vm-1.network_interface.0.ip_address
    ssh_user       = var.ssh_user
    domain         = var.domain
  })
  filename = "${path.module}/bootstrap/inventory/hosts"
  
  depends_on = [yandex_compute_instance.vm-1]
}

# Провижининг с помощью Ansible
resource "null_resource" "ansible_provisioning" {
  triggers = {
    instance_id = yandex_compute_instance.vm-1.id
    inventory   = local_file.ansible_inventory.content
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 30
      cd ${path.module}/bootstrap
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts bootstrap.yml
    EOT
  }

  depends_on = [
    yandex_compute_instance.vm-1,
    local_file.ansible_inventory
  ]
}