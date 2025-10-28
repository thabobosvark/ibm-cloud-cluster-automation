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

# Create a VPC
resource "ibm_is_vpc" "cluster_vpc" {
  name = "hpc-cluster-vpc-${formatdate("YYYYMMDD", timestamp())}"
}

# Create a subnet
resource "ibm_is_subnet" "cluster_subnet" {
  name                     = "hpc-cluster-subnet-${formatdate("YYYYMMDD", timestamp())}"
  vpc                      = ibm_is_vpc.cluster_vpc.id
  zone                     = "eu-gb-1"
  total_ipv4_address_count = 256
}

# Create a security group
resource "ibm_is_security_group" "cluster_sg" {
  name = "hpc-cluster-sg-${formatdate("YYYYMMDD", timestamp())}"
  vpc  = ibm_is_vpc.cluster_vpc.id
}

# Allow SSH access
resource "ibm_is_security_group_rule" "ssh_in" {
  group     = ibm_is_security_group.cluster_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Allow all outbound traffic
resource "ibm_is_security_group_rule" "all_out" {
  group     = ibm_is_security_group.cluster_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Create the compute instance
resource "ibm_is_instance" "com3_node" {
  name    = "com3-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  image   = "r018-2c3e9f72-2e95-4a3c-8e4d-f6c4bdc77f9b"  # CentOS 9 for eu-gb
  profile = "bx2-2x8"
  keys    = ["r018-0882fad6-6daa-434a-9165-b3b29ae6814e"]  # Your SSH key ID
  vpc     = ibm_is_vpc.cluster_vpc.id
  zone    = "eu-gb-1"

  primary_network_interface {
    subnet          = ibm_is_subnet.cluster_subnet.id
    security_groups = [ibm_is_security_group.cluster_sg.id]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# Optional: Create floating IP
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
