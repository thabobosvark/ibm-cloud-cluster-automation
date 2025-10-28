terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.84.3"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "us-south"
}

# Data source for existing VPC (use existing instead of creating new)
data "ibm_is_vpc" "existing_vpc" {
  name = "hpc-cluster-vpc"
}

# Data source for existing subnet
data "ibm_is_subnet" "existing_subnet" {
  name = "hpc-cluster-subnet"
}

# Data source for existing security group
data "ibm_is_security_group" "existing_sg" {
  name = "hpc-cluster-sg"
}

# Create a new compute node
resource "ibm_is_instance" "com3_node" {
  name    = "com3-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  image   = var.image_id
  profile = var.profile
  keys    = [var.ssh_key_id]

  primary_network_interface {
    subnet          = data.ibm_is_subnet.existing_subnet.id
    security_groups = [data.ibm_is_security_group.existing_sg.id]
  }

  vpc  = data.ibm_is_vpc.existing_vpc.id
  zone = "us-south-1"

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "ibm_is_floating_ip" "com3_fip" {
  name   = "com3-floating-ip-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  target = ibm_is_instance.com3_node.primary_network_interface[0].id
}

output "com3_instance_id" {
  value = ibm_is_instance.com3_node.id
}

output "com3_private_ip" {
  value = ibm_is_instance.com3_node.primary_network_interface[0].primary_ip[0].address
}

output "com3_public_ip" {
  value = ibm_is_floating_ip.com3_fip.address
}
