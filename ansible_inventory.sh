#!/bin/bash
# Setup env
source ./envs.sh
base_config="all: \n  children:"

function check_requirements () {
  binaries=("jq" "yq" "terragrunt")
  for binary in $binaries; do
    if ! command -v $binary &> /dev/null; then
      case $binary in
        "jq")
          echo "The jq binary is missing, checkout the official site: https://stedolan.github.io/jq/"
          exit 1
        ;;
        "yq")
          echo "The yq binary is missing, checkout the official site: https://mikefarah.gitbook.io/yq/"
          exit 1
        ;;
        "terragrunt")
          echo "The terragrunt binary is missing, checkout the official site: https://terragrunt.gruntwork.io/"
          exit 1
        ;;
      esac
    fi
  done
}

function get_terragrunt_output () {
  raw_yaml=$(terragrunt run-all output -json \
    --terragrunt-log-level error | \
    jq -s | \
    yq ea
  )
  echo $raw_yaml
}

check_requirements
raw_yaml=$(get_terragrunt_output)

# Get all elements with a unique role tag
all_roles=$(echo $raw_yaml | yq e '.[].ansible_host.value.tags[] | select(.key == "role") | [.value] | unique | .[]' -)

for role in $all_roles; do
  for host in $(( $(echo $raw_yaml | yq ea '.[] | select(.ansible_host.value.tags[].value == "'$role'") | [.ansible_host] | length' -) - 1 )); do
    host_object=$(echo $raw_yaml | yq ea '.[] | select(.ansible_host.value.tags[].value == "'$role'") | [.ansible_host] | .['$host'].value' -)
    host_ip=$(echo $host_object | yq e '.ip' -)
    # Assign hostname
    base_config=$(echo -e "$base_config" | yq e '.all.children.'$role'.hosts."'$host_ip'".hostname = "'$(echo $host_object | yq e '.hostname' -)'"' -)
    # Assign domain name an search domain
    base_config=$(echo -e "$base_config" | yq e '.all.children.'$role'.hosts."'$host_ip'".domain = "'$(echo $host_object | yq e '.domain' -)'"' -)
    base_config=$(echo -e "$base_config" | yq e '.all.children.'$role'.hosts."'$host_ip'".dns.searchdomains[0] = "'$(echo $host_object | yq e '.domain' -)'"' -)
    # Add nameservers
    i=1
    num_servers=$(echo $host_object | yq e '.nameservers' - | wc -w )
    while [ "$i" -le "$num_servers" ]; do
      base_config=$(echo -e "$base_config" | yq e '.all.children.'$role'.hosts."'$host_ip'".dns.nameservers['$((i - 1))'] = "'$(echo $host_object | yq e '.nameservers' - | cut -d ' ' -f$i )'"' -)
      i=$(($i + 1))
    done
    # Add arbitrary tags
    i=0
    num_tags=$(( $(echo -e $host_object | yq e '.tags | length' -) - 1 ))
    while [ "$i" -le "$num_tags" ]; do
      if [ ! "$(echo -e $host_object | yq e '.tags['$i'].key' -)" = "role" ]; then
        base_config=$(echo -e "$base_config" | yq e '.all.children.'$role'.hosts."'$host_ip'"."'$(echo $host_object | yq e '.tags['$i'].key' -)'" = "'$(echo $host_object | yq e '.tags['$i'].value' -)'"' -)
      fi
      i=$(($i + 1))
    done
  done
done

echo -e "$base_config" | yq e -
