locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  common_vars = yamldecode(file("${get_parent_terragrunt_dir()}/common_vars/common_vars.yaml"))
  cloud_init_vars = yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/common_vars/cloud_init_vars.sops.yaml"))
  proxmox_vars = yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/common_vars/proxmox_vars.sops.yaml"))
  unifi_vars = yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/common_vars/unifi_vars.sops.yaml"))
}

inputs = merge(
  local.global_vars.inputs,
  {
    proxmox            = local.proxmox_vars.proxmox
    cloud_init         = local.cloud_init_vars.cloud_init
    unifi              = local.unifi_vars.unifi
    unifi-network-name = local.common_vars.unifi-network-name
    gateway            = local.common_vars.gateway
    network            = local.common_vars.network
    network_subnet     = local.common_vars.network_subnet
    nameservers        = local.common_vars.nameservers
    searchdomain       = local.common_vars.searchdomain
  }
)
