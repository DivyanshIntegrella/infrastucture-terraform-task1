variable "location" {
}

variable "rg_name" {
}

variable "azure-terraform"{
    type = string
    default = "App-Vnet"
    description = "Virtual network"
}

variable "password" {
  default = "Divyansh@123"
  description = "password for virtual machine"
  sensitive = true
}

variable "locals-name" {
  type = string
  default = "gateway"
}

variable "tenant" {
  default = "bd1024c1-001a-4eeb-963a-cfeccbc90226"
  sensitive = true
}