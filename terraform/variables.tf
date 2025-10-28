variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud Region"
  type        = string
  default     = "eu-gb"
}

variable "resource_group" {
  description = "Resource Group Name"
  type        = string
  default     = "Default"
}

variable "ssh_key_name" {
  description = "SSH Key Name"
  type        = string
  default     = "key"
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "eu-gb-default-vpc-10182040"
}

variable "subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = "eu-gb-2-default-subnet"
}
