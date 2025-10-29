#!/bin/bash
# Diagnostic script for IBM Cloud SSH access

echo "=== IBM Cloud SSH Diagnostic ==="
echo "Head node IP: 141.125.159.109"
echo "Private network: 10.242.64.0/24"

# Check if we can reach the head node
echo -e "\n=== Testing head node access ==="
ssh -o ConnectTimeout=10 -i ~/.ssh/id_ed25519 clusteradmin@141.125.159.109 "echo '✅ Head node accessible'"

# Check available SSH keys on head node
echo -e "\n=== Available SSH keys on head node ==="
ssh -i ~/.ssh/id_ed25519 clusteradmin@141.125.159.109 "find /root/.ssh /home/clusteradmin/.ssh -name '*.pub' 2>/dev/null"

# Check if head node can reach com3 nodes
echo -e "\n=== Testing head node to com3 access ==="
for ip in 10.242.64.13 10.242.64.14 10.242.64.15; do
  echo "Testing $ip..."
  ssh -i ~/.ssh/id_ed25519 clusteradmin@141.125.159.109 "ping -c 1 -W 1 $ip >/dev/null 2>&1 && echo '✅ Reachable' || echo '❌ Unreachable'"
done

echo -e "\n=== Manual configuration required ==="
echo "If SSH to com3 nodes fails, you need to:"
echo "1. Log into IBM Cloud console"
echo "2. Check the com3 instances"
echo "3. Ensure the correct SSH key is attached"
echo "4. Use the console to manually configure the nodes"
