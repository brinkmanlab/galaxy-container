# Admin user boostrap

This module configures an internal Galaxy provider to bootstrap the admin user and its API key using the master API key.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_galaxy.master"></a> [galaxy.master](#provider\_galaxy.master) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_email"></a> [email](#input\_email) | Email address (as specified in Galaxy admin\_users config) | `string` | n/a | yes |
| <a name="input_galaxy_url"></a> [galaxy\_url](#input\_galaxy\_url) | Galaxy server url | `string` | n/a | yes |
| <a name="input_master_api_key"></a> [master\_api\_key](#input\_master\_api\_key) | Galaxy master API key | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | Password of admin user | `string` | `""` | no |
| <a name="input_username"></a> [username](#input\_username) | Username of admin user | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | n/a |
| <a name="output_password"></a> [password](#output\_password) | n/a |

## Resources

| Name | Type |
|------|------|
| [galaxy_user.admin](https://registry.terraform.io/providers/brinkmanlab/galaxy/latest/docs/resources/user) | resource |
| [random_password.admin_user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
<!-- END_TF_DOCS -->