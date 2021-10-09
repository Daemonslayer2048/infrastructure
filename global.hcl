locals {
  namecheap_vars = yamldecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/common_vars/namecheap_vars.sops.yaml"))
}

inputs = {
  namecheap = local.namecheap_vars.namecheap
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents = <<EOT
    terraform {
      backend "s3" {}
    }
  EOT
}

remote_state {
  backend = "s3"
  config = {
    bucket         = get_env("AWS_S3_BUCKET")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = get_env("AWS_REGION")
    encrypt        = true
  }
}
