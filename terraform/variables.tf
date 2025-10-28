variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "SSH key ID"
  type        = string
  default     = "r018-0882fad6-6daa-434a-9165-b3b29ae6814e"
}

variable "image_id" {
  description = "Image ID for the instance"
  type        = string
  default     = "r018-2c3e9f72-2e95-4a3c-8e4d-f6c4bdc77f9b"
}

variable "profile" {
  description = "Instance profile"
  type        = string
  default     = "bx2-2x8"
}
