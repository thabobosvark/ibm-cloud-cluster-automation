#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <node_ip>"
  echo "Example: $0 10.242.64.13"
  exit 1
fi

NODE_IP=$1

echo "Configuring node at $NODE_IP"

# Check if we can connect
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@$NODE_IP "echo 'Connected successfully'" || {
  echo "Cannot connect to $NODE_IP as root"
  echo "You may need to use IBM Cloud console or different SSH key"
  exit 1
}

# Basic user setup
echo "Creating clusteradmin user..."
ssh -o StrictHostKeyChecking=no root@$NODE_IP "adduser clusteradmin"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "echo '!Super@4' | passwd --stdin clusteradmin"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "dnf install sudo -y"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "usermod -aG wheel clusteradmin"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "echo 'clusteradmin ALL=(ALL) NOPASSWD:ALL' | tee /etc/sudoers.d/clusteradmin"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "chmod 440 /etc/sudoers.d/clusteradmin"

# Add SSH key
echo "Setting up SSH access..."
ssh -o StrictHostKeyChecking=no root@$NODE_IP "mkdir -p /home/clusteradmin/.ssh"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCCsrtROumtINmCBKvVHkd8gEK3d2CXmprcp97PIN0v clusteradmin@head' > /home/clusteradmin/.ssh/authorized_keys"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "chmod 700 /home/clusteradmin/.ssh"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "chmod 600 /home/clusteradmin/.ssh/authorized_keys"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "chown -R clusteradmin:clusteradmin /home/clusteradmin/.ssh"

# Setup NFS
echo "Setting up NFS..."
ssh -o StrictHostKeyChecking=no root@$NODE_IP "dnf install nfs-utils -y"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "mount -t nfs 10.242.64.4:/home /home"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "echo '10.242.64.4:/home /home nfs defaults 0 0' >> /etc/fstab"
ssh -o StrictHostKeyChecking=no root@$NODE_IP "setsebool -P use_nfs_home_dirs 1"

echo "✅ Node $NODE_IP configured successfully!"
echo "You can now connect: ssh clusteradmin@$NODE_IP"
