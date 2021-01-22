#!/usr/bin/env bash
# This file is only necessary due to https://github.com/hashicorp/terraform/issues/4149

terraform apply -target=module.cloud -auto-approve
terraform apply -target=module.galaxy -auto-approve
terraform apply -target=module.admin_user -auto-approve
terraform apply -auto-approve

echo "Run destroy.sh to shutdown and delete everything"