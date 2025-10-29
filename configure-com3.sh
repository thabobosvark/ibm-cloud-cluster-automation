#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <com3_ip>"
  echo "Example: $0 10.242.64.18"
  exit 1
fi

COM3_IP=$1

echo "Configuring com3 at $COM3_IP..."

# Connect to com3 and run configuration commands
ssh -o StrictHostKeyChecking=no root@$COM3_IP << 'CO3_SCRIPT'
  echo "Creating clusteradmin user..."
  adduser clusteradmin
  echo "!Super@4" | passwd --stdin clusteradmin
  
  echo "Installing sudo..."
  dnf install sudo -y
  
  echo "Setting up sudo access..."
  usermod -aG wheel clusteradmin
  echo "clusteradmin ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/clusteradmin
  chmod 440 /etc/sudoers.d/clusteradmin
  
  echo "Installing NFS..."
  dnf install nfs-utils -y
  
  echo "Mounting NFS..."
  mount -t nfs 10.242.64.4:/home /home
  echo "10.242.64.4:/home /home nfs defaults 0 0" >> /etc/fstab
  setsebool -P use_nfs_home_dirs 1
  
  echo "Configuration complete!"
CO3_SCRIPT

echo "✅ com3 at $COM3_IP configured successfully!"
echo "You can now connect: ssh clusteradmin@$COM3_IP"
