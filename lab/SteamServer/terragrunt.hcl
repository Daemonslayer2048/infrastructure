terraform {
  source = "github.com/Daemonslayer2048/terraform-infrastructure-modules.git//external-vm?ref=v0.2.1"
}

locals {
  lab_vars = read_terragrunt_config(find_in_parent_folders("lab.hcl"))
  vm_vars  = yamldecode(file("./vm.yaml"))
}

include "root" {
  path = find_in_parent_folders("global.hcl")
}

generate = local.lab_vars.generate

inputs = merge(
  local.lab_vars.inputs,
  {
    template-name  = local.vm_vars.template-name
    node           = local.vm_vars.node
    vm-id          = local.vm_vars.vm-id
    vm-name        = local.vm_vars.vm-name
    cpu            = local.vm_vars.cpu
    mem            = local.vm_vars.mem
    disk0-size     = local.vm_vars.disk0-size
    tags           = local.vm_vars.tags
    unifi-note     = local.vm_vars.unifi-note
    desc           = local.vm_vars.desc
  }
)
