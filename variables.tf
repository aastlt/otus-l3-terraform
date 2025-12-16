# variables.tf

##cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

##vm vars
variable "vm_resources_list" {
  type = list(object({
    vm_name       = string
    cpu           = number
    ram           = number
    gpus          = number
    disk          = number
    core_fraction = number
  }))
  default = [
    {
      vm_name       = "otus-l3-terraform"
      cpu           = 2
      ram           = 2
      gpus          = 0
      disk          = 1
      core_fraction = 5

    },
    # {
    #   vm_name       = "vm-2"
    #   cpu           = 4
    #   ram           = 2
    #   gpus          = 0
    #   disk          = 3
    #   core_fraction = 5
    # },
  ]
  description = "There's list if dict's with VM resources"
}

variable "vm_name" {
  type        = string
  default     = "otus-l3-terraform"
  description = "VM name"
}

variable "domain" {
  type        = string
  default     = "local"
  description = "Domain name for the infrastructure"
}

variable "image_id" {
  type        = string
  default     = "fd8oees0esvl0qf4lp59" # Debian 11 OS Login
  description = "ID образа ОС"
}

variable "vpc_network_name" {
  type        = string
  default     = "network-1"
  description = "VPC network name"
}

variable "vpc_subnet_name" {
  type        = string
  default     = "subnet-1"
  description = "VPC subnet name"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vms_ssh_root_key" {
  type        = map(any)
  default     = {
    serial-port-enable = 1
    ssh-keys           = "~/.ssh/id_rsa.pub"
  }
}

variable "ssh_user" {
  type        = string
  default     = "debian"
  description = "SSH user for Ansible connection"
}
