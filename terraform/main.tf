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

# Use the default VPC where your existing instances are
data "ibm_is_vpc" "existing_vpc" {
  name = "eu-gb-default-vpc-10182040"  # Your actual default VPC
}

# Use the default subnet where your existing instances are
data "ibm_is_subnet" "existing_subnet" {
  name = "eu-gb-2-default-subnet"  # Your actual default subnet
}

# Use the default security group
data "ibm_is_security_group" "existing_sg" {
  name = "footless-viper-prowler-fabric"  # Your default security group
}

# Create a floating IP for public access
resource "ibm_is_floating_ip" "com3_public_ip" {
  name   = "com3-public-ip"
  target = data.ibm_is_subnet.existing_subnet.primary_network_interface[0].id
}

# Create the compute instance using the same infrastructure as your existing nodes
resource "ibm_is_instance" "com3_node" {
  name    = "com3-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  image   = var.image_id
  profile = var.profile
  keys    = [var.ssh_key_id]  # Use existing SSH key
  vpc     = data.ibm_is_vpc.existing_vpc.id
  zone    = "eu-gb-2"  # Changed to eu-gb-2 to match your existing instances

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

# Associate the floating IP with the instance
resource "ibm_is_floating_ip_association" "com3_fip_assoc" {
  floating_ip = ibm_is_floating_ip.com3_public_ip.address
  target      = ibm_is_instance.com3_node.primary_network_interface[0].id
}

output "com3_instance_id" {
  value = ibm_is_instance.com3_node.id
}

output "com3_private_ip" {
  value = ibm_is_instance.com3_node.primary_network_interface[0].primary_ip[0].address
}

output "com3_public_ip" {
  value = ibm_is_floating_ip.com3_public_ip.address
}
