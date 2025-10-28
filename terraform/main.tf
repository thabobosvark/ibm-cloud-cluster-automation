terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.84.3"
    }
  }
}

provider "ibm" {
  region = "us-south"
}

resource "ibm_is_vpc" "cluster_vpc" {
  name = "hpc-cluster-vpc"
}

resource "ibm_is_subnet" "cluster_subnet" {
  name                     = "hpc-cluster-subnet"
  vpc                      = ibm_is_vpc.cluster_vpc.id
  zone                     = "us-south-1"
  total_ipv4_address_count = 256
}

resource "ibm_is_security_group" "cluster_sg" {
  name = "hpc-cluster-sg"
  vpc  = ibm_is_vpc.cluster_vpc.id
}

resource "ibm_is_security_group_rule" "ssh" {
  group     = ibm_is_security_group.cluster_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "internal" {
  group     = ibm_is_security_group.cluster_sg.id
  direction = "inbound"
  remote    = "10.0.0.0/8"
}

resource "ibm_is_instance" "com3_node" {
  name    = "com3-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  image   = var.image_id
  profile = var.profile
  keys    = [var.ssh_key_id]

  primary_network_interface {
    subnet          = ibm_is_subnet.cluster_subnet.id
    security_groups = [ibm_is_security_group.cluster_sg.id]
  }

  vpc       = ibm_is_vpc.cluster_vpc.id
  zone      = "us-south-1"
  user_data = file("${path.module}/user-data.sh")

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "ibm_is_floating_ip" "com3_fip" {
  name   = "com3-floating-ip"
  target = ibm_is_instance.com3_node.primary_network_interface[0].id
}

output "com3_instance_id" {
  value = ibm_is_instance.com3_node.id
}

output "com3_private_ip" {
  value = ibm_is_instance.com3_node.primary_network_interface[0].primary_ipv4_address
}

output "com3_public_ip" {
  value = ibm_is_floating_ip.com3_fip.address
}
