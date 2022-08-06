variable "subscription_id" {
  default = "622411f9-056b-4cd2-8612-cd26091f1c5c"
  type = string
}

variable "client_id" {
  default = "ac1b87b0-7786-4a07-8b97-dbed0c91348a"
  type = string
}

variable "client_secret" {
  default = "3zV8Q~mrb1fDvmkamu64gCq9DzcSnQPIZVokHcO7"
  type = string
}

variable "tenant_id" {
  default = "f958e84a-92b8-439f-a62d-4f45996b6d07"
  type = string
}

variable "resource_group_id" {
  default = "/subscriptions/7da9aa2a-dee5-47d2-8cc8-ccb1d2a68c2d/resourceGroups/Azuredevops"
  type    = string
}

variable "resource_group" {
  description = "Name of the resource group, already created by Udacity codelab"
  default     = "Azuredevops"
  type        = string
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created, udacity created resource group in South Central US"
  default     = "East US"
}

variable "username" {
  description = "The user name for vm login data"
  default     = "UdacityProject1"
  type        = string 
}

variable "password" {
  description = "The password for vm login data"
  default     = "UdacityProject1"
  type        = string
}

variable "number_of_vm" {
  description = "The number of virtual machine to create"
  default     = 3
  type        = number
}
