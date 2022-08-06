variable "subscription_id" {
  default = "7da9aa2a-dee5-47d2-8cc8-ccb1d2a68c2d"
  type = string
}

variable "client_id" {
  default = "587b1ccc-6db4-463b-8180-c9b3c218e807"
  type = string
}

variable "client_secret" {
  default = "rAH8Q~6RqVhI6aoPOjhuhLk4PToSLJqalL_R9bi9"
  type = string
}

variable "tenant_id" {
  default = "4dde8df8-a59e-47d6-8eeb-86daff8a2f5d"
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
  default     = "South Central US"
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
