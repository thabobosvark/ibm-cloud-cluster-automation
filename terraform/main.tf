# Get existing VPC data
data "ibm_is_vpc" "existing_vpc" {
  name = var.vpc_name
}

# Get existing subnet data
data "ibm_is_subnet" "existing_subnet" {
  name = var.subnet_name
}

# Get SSH key data
data "ibm_is_ssh_key" "existing_key" {
  name = var.ssh_key_name
}

# Get image data for CentOS Stream 9
data "ibm_is_image" "centos_stream_9" {
  name = "ibm-centos-stream-9-amd64-12"
}

# Create 3rd compute node (com2)
resource "ibm_is_instance" "com2_node" {
  name    = "com2"
  vpc     = data.ibm_is_vpc.existing_vpc.id
  zone    = "eu-gb-2"
  keys    = [data.ibm_is_ssh_key.existing_key.id]
  image   = data.ibm_is_image.centos_stream_9.id
  profile = "bx2-2x8"

  primary_network_interface {
    subnet = data.ibm_is_subnet.existing_subnet.id
  }

  tags = ["week4-assignment", "compute-node", "automated-deployment"]
}

# Output important information
output "com2_instance_id" {
  value = ibm_is_instance.com2_node.id
}

output "com2_private_ip" {
  value = ibm_is_instance.com2_node.primary_network_interface[0].primary_ip[0].address
}

output "com2_ssh_command" {
  value = "ssh root@${ibm_is_instance.com2_node.primary_network_interface[0].primary_ip[0].address}"
}

output "com2_status" {
  value = ibm_is_instance.com2_node.status
}
