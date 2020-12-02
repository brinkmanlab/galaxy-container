#!/usr/bin/env bash
set -e
# This file is only necessary due to https://github.com/hashicorp/terraform/issues/4149

terraform apply -target=module.galaxy -auto-approve
terraform apply -target=module.admin_user -auto-approve
terraform apply -auto-approve
terraform output -json

echo "Run destroy.sh to shutdown and delete everything"