#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <com3_ip>"
  echo "Example: $0 10.242.64.18"
  exit 1
fi

COM3_IP=$1

echo "Updating Ansible inventory with com3 at $COM3_IP..."

cat > ansible/inventory.yml << INVENTORY
---
all:
  vars:
    ansible_user: clusteradmin
    ansible_ssh_private_key_file: ~/.ssh/id_ed25519
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    cluster_user: clusteradmin
    head_node_ip: 10.242.64.4
    nfs_export_path: /home
    timezone: "UTC"
    cluster_network: "10.242.64.0/24"
    nfs_server: "head"
    mount_point: "/home"

  children:
    head_node:
      hosts:
        head:
          ansible_host: 10.242.64.4
          node_type: head

    compute:
      hosts:
        com1:
          ansible_host: 10.242.64.5
          node_type: compute
        com2:
          ansible_host: 10.242.64.6
          node_type: compute
        com3:
          ansible_host: $COM3_IP
          node_type: compute

    cluster:
      hosts:
        head:
        com1:
        com2:
        com3:
INVENTORY

echo "✅ Ansible inventory updated with com3: $COM3_IP"
