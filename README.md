# Infrastructure
## Summary  
A home labs IaC repo.

## Requirements
### Programs  
- Terraform
- Terragrunt
- SOPS (Not NEEDED, but highly reccomended)
- jq
- yq

### Services

#### Cloud
 - Amazon AWS S3
 - Namecheap

#### Local
 - Proxmox
 - Unifi

## Variables  
All variable files have a sample file in this repo with comments (if not explicitly obvious). Refrence those for comments.
- environment variables
  - See the envs.sh.example, there is a section for SOPS using AGE, and AWS.
- `common_vars/namecheap_vars.yaml`
  - You will need to create an IP key and whitelist your public ip you will be making changes from. Instructions [here](https://www.namecheap.com/support/api/intro/)
- `lab/common_vars/cloud_init_vars.yaml`
  - The clout-init configuration to use for the generated user (username, password, ssh keys).
- `lab/common_vars/common_vars.yaml`
  - Common vars shared accross all folders in `lab/`
  - The `network` variable is an odd one and due to a design choice made is fairly restrictive. This variable set the first three octets to be used for the ip. For example is a VM id is 100, and the `network` variable is 192.168.1, the IP of the VM will be 192.168.1.100. This may not stay this way due to the limitations it creates.  
- `lab/common_vars/proxmox_vars.yaml`
  - API credentials for Proxmox access
- `lab/common_vars/unifi_vars.yaml`
  - API credentials for UniFI access

Each Terraform module will require its own set of variables but most are fairly self explanatory. Please see the samples

## Scripts  
- inventory.sh (Not built)
  - Used to build an ansible inventory file. This inventory file is intended to be used by the repo [here](https://github.com/Daemonslayer2048/infrastructure-plays)

## Notes
- Cloud-Init templates can be built easily but a [repo](https://github.com/Daemonslayer2048/proxmox-cloud-init-builder) has already been made to aid in creating them.  

## To-Do
- Build Inventory script
