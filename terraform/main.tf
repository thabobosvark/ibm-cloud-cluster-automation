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
  region           = "eu-gb"
}

# Use your existing VPC
data "ibm_is_vpc" "existing_vpc" {
  name = "hpc-cluster-vpc-20251028"  # Your actual VPC name
}

# Use your existing subnet
data "ibm_is_subnet" "existing_subnet" {
  name = "hpc-cluster-subnet-20251028"  # Your actual subnet name
}

# Use your existing security group
data "ibm_is_security_group" "existing_sg" {
  name = "hpc-cluster-sg-20251028"  # Your actual security group name
}

# Create the compute instance using your existing infrastructure
resource "ibm_is_instance" "com3_node" {
  name    = "com3-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  image   = var.image_id
  profile = var.profile
  keys    = [var.ssh_key_id]
  vpc     = data.ibm_is_vpc.existing_vpc.id
  zone    = "eu-gb-1"

  primary_network_interface {
    subnet          = data.ibm_is_subnet.existing_subnet.id
    security_groups = [data.ibm_is_security_group.existing_sg.id]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

output "com3_instance_id" {
  value = ibm_is_instance.com3_node.id
}

output "com3_private_ip" {
  value = ibm_is_instance.com3_node.primary_network_interface[0].primary_ip[0].address
}
