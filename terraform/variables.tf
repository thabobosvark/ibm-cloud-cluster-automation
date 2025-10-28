variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "SSH key ID to provision the instance with"
  type        = string
  default     = "r010-5dfb8a94-89b1-4e95-bda6-3f8a6a9f7b5a"
}

variable "image_id" {
  description = "Image ID for the instance"
  type        = string
  default     = "r010-2c3e9f72-2e95-4a3c-8e4d-f6c4bdc77f9b"
}

variable "profile" {
  description = "Instance profile"
  type        = string
  default     = "bx2-2x8"
}
