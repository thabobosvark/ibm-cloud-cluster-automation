# IBM Cloud HPC Cluster Automation

A fully automated HPC cluster deployment on IBM Cloud with 4 nodes.

## Cluster Nodes

- **head**: 10.242.64.4 (Public: 141.125.159.109)
- **com1**: 10.242.64.5
- **com2**: 10.242.64.6
- **com3**: 10.242.64.26

## User Access
- **Username**: clusteradmin
- **Password**: !Super@4
- **SSH Key**: id_ed25519

## Features
- Automated node deployment via GitHub Actions
- Shared NFS home directory (/home) across all nodes
- Passwordless SSH between nodes
- Centralized user management

## Quick Start

### Connect to com3 via ProxyJump:
```bash
ssh -J clusteradmin@141.125.159.109 clusteradmin@10.242.64.26
Or connect via head node:
```bash
ssh clusteradmin@141.125.159.109
ssh clusteradmin@10.242.64.26
```
Repository Structure
text
├── .github/workflows/
│   └── deploy-com3.yml          # CI/CD for new compute nodes
├── ansible/
│   ├── inventory.yml            # Cluster inventory
│   └── playbooks/               # Configuration playbooks
└── terraform/
    ├── main.tf                  # IBM Cloud infrastructure
    └── variables.tf             # Configuration variables
