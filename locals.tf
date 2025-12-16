# locals.tf

## Add SSH-public key for default user (debian) from variables.tf, serial console access
locals {
    ssh-keys= "debian:${file(var.vms_ssh_root_key.ssh-keys)}"
    serial-port= "${var.vms_ssh_root_key.serial-port-enable}"
}
