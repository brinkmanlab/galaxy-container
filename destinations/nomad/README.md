# Nomad Deployment Module
<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_nomad"></a> [nomad](#provider\_nomad) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | List of email addresses for Galaxy admin users | `set(string)` | <pre>[<br>  "admin@brinkmanlab.ca"<br>]</pre> | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Galaxy application container name | `string` | `null` | no |
| <a name="input_config_dir"></a> [config\_dir](#input\_config\_dir) | Path to galaxy configuration folder within container | `string` | `null` | no |
| <a name="input_data_dir"></a> [data\_dir](#input\_data\_dir) | Path to user data within container | `string` | `null` | no |
| <a name="input_db_conf"></a> [db\_conf](#input\_db\_conf) | Database configuration overrides | <pre>object({<br>    scheme = string<br>    host   = string<br>    name   = string<br>    user   = string<br>    pass   = string<br>  })</pre> | `null` | no |
| <a name="input_db_data_volume_name"></a> [db\_data\_volume\_name](#input\_db\_data\_volume\_name) | Database volume name | `string` | `null` | no |
| <a name="input_db_image"></a> [db\_image](#input\_db\_image) | MariaDB image name | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database container name | `string` | `null` | no |
| <a name="input_debug"></a> [debug](#input\_debug) | Enabling will put the deployment into a mode suitable for debugging | `bool` | `false` | no |
| <a name="input_email"></a> [email](#input\_email) | Email address to send automated emails from | `string` | n/a | yes |
| <a name="input_extra_job_mounts"></a> [extra\_job\_mounts](#input\_extra\_job\_mounts) | Extra mounts passed to job\_conf for jobs | `set(string)` | `[]` | no |
| <a name="input_extra_mounts"></a> [extra\_mounts](#input\_extra\_mounts) | Map of mount configurations to add to app and worker containers keyed on volume name | <pre>map(object({<br>    volume_id = string<br>    path = string<br>    read_only = bool<br>  }))</pre> | `{}` | no |
| <a name="input_galaxy_app_image"></a> [galaxy\_app\_image](#input\_galaxy\_app\_image) | Galaxy app server image name | `string` | `null` | no |
| <a name="input_galaxy_conf"></a> [galaxy\_conf](#input\_galaxy\_conf) | Galaxy configuration overrides | `map(string)` | `{}` | no |
| <a name="input_galaxy_root_volume_name"></a> [galaxy\_root\_volume\_name](#input\_galaxy\_root\_volume\_name) | Galaxy root volume name | `string` | `null` | no |
| <a name="input_galaxy_web_image"></a> [galaxy\_web\_image](#input\_galaxy\_web\_image) | Galaxy web server image name | `string` | `null` | no |
| <a name="input_id_secret"></a> [id\_secret](#input\_id\_secret) | Salt used to make Galaxy Ids unpredictable | `string` | `""` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag for galaxy\_web and galaxy\_app image | `string` | `"latest"` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Unique deployment instance identifier | `string` | `""` | no |
| <a name="input_job_destinations"></a> [job\_destinations](#input\_job\_destinations) | XML list of <destination> tags | `string` | `""` | no |
| <a name="input_limits"></a> [limits](#input\_limits) | List of limits to add to the job\_conf.xml. id is optional and can be set as an empty string. | <pre>list(object({<br>    type  = string<br>    tag   = string<br>    value = string<br>    id    = string<br>  }))</pre> | `[]` | no |
| <a name="input_mail_name"></a> [mail\_name](#input\_mail\_name) | SMTP server name | `string` | `"mail"` | no |
| <a name="input_mail_port"></a> [mail\_port](#input\_mail\_port) | Port to connect to SMTP server | `number` | `587` | no |
| <a name="input_managed_config_dir"></a> [managed\_config\_dir](#input\_managed\_config\_dir) | Path to galaxy managed configuration folder on persistent storage | `string` | `null` | no |
| <a name="input_master_api_key"></a> [master\_api\_key](#input\_master\_api\_key) | Galaxy master API key | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Instance of nomad\_namespace to provision instance resources under | `any` | `null` | no |
| <a name="input_nfs_server"></a> [nfs\_server](#input\_nfs\_server) | External ID to NFS server volume containing user data | `string` | `""` | no |
| <a name="input_plugins"></a> [plugins](#input\_plugins) | XML list of <plugin> tags | `string` | `""` | no |
| <a name="input_root_dir"></a> [root\_dir](#input\_root\_dir) | Path to galaxy root folder within container | `string` | `null` | no |
| <a name="input_static_tool_data_tables"></a> [static\_tool\_data\_tables](#input\_static\_tool\_data\_tables) | List of static tool data table loc files to load. Paths are relative to the value of `tool_data_path` in the galaxy config | <pre>list(object({<br>    name = string<br>    path = string<br>    allow_duplicate_entries = bool<br>    comment_char = string<br>    columns = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_tool_containers"></a> [tool\_containers](#input\_tool\_containers) | Mapping of tool IDs to tool containers | `map(string)` | `{}` | no |
| <a name="input_tool_mappings"></a> [tool\_mappings](#input\_tool\_mappings) | Tool ID to destination mappings. See roles/galaxy\_app/defaults/main/job\_conf.yml within the module root for destinations. | `map(string)` | `{}` | no |
| <a name="input_user_data_volume_name"></a> [user\_data\_volume\_name](#input\_user\_data\_volume\_name) | User data volume name | `string` | `null` | no |
| <a name="input_app_gid"></a> [app\_gid](#input\_app\_gid) | GID of Galaxy process | `number` | `null` | no |
| <a name="input_app_group"></a> [app\_group](#input\_app\_group) | Group name of Galaxy process | `string` | `null` | no |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Port Galaxy app server is listening from | `number` | `null` | no |
| <a name="input_app_uid"></a> [app\_uid](#input\_app\_uid) | UID of Galaxy process | `number` | `null` | no |
| <a name="input_app_user"></a> [app\_user](#input\_app\_user) | User name of Galaxy process | `string` | `null` | no |
| <a name="input_visualizations"></a> [visualizations](#input\_visualizations) | Set of URLs to tarballs to unpack into visualizations folder | `set(string)` | `[]` | no |
| <a name="input_web_name"></a> [web\_name](#input\_web\_name) | Galaxy web server container name | `string` | `null` | no |
| <a name="input_worker_name"></a> [worker\_name](#input\_worker\_name) | Galaxy worker container name | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_name"></a> [app\_name](#output\_app\_name) | n/a |
| <a name="output_config_dir"></a> [config\_dir](#output\_config\_dir) | n/a |
| <a name="output_data_dir"></a> [data\_dir](#output\_data\_dir) | n/a |
| <a name="output_db_conf"></a> [db\_conf](#output\_db\_conf) | n/a |
| <a name="output_db_data_volume_name"></a> [db\_data\_volume\_name](#output\_db\_data\_volume\_name) | n/a |
| <a name="output_db_image"></a> [db\_image](#output\_db\_image) | n/a |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | n/a |
| <a name="output_galaxy_app_image"></a> [galaxy\_app\_image](#output\_galaxy\_app\_image) | n/a |
| <a name="output_galaxy_root_volume_name"></a> [galaxy\_root\_volume\_name](#output\_galaxy\_root\_volume\_name) | n/a |
| <a name="output_galaxy_web_image"></a> [galaxy\_web\_image](#output\_galaxy\_web\_image) | n/a |
| <a name="output_id_secret"></a> [id\_secret](#output\_id\_secret) | n/a |
| <a name="output_master_api_key"></a> [master\_api\_key](#output\_master\_api\_key) | n/a |
| <a name="output_root_dir"></a> [root\_dir](#output\_root\_dir) | n/a |
| <a name="output_user_data_volume_name"></a> [user\_data\_volume\_name](#output\_user\_data\_volume\_name) | n/a |
| <a name="output_app_gid"></a> [app\_gid](#output\_app\_gid) | n/a |
| <a name="output_app_port"></a> [app\_port](#output\_app\_port) | n/a |
| <a name="output_app_uid"></a> [app\_uid](#output\_app\_uid) | n/a |
| <a name="output_web_name"></a> [web\_name](#output\_web\_name) | n/a |
| <a name="output_worker_name"></a> [worker\_name](#output\_worker\_name) | n/a |

## Resources

| Name | Type |
|------|------|
| [nomad_job.galaxy_app](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/job) | resource |
| [nomad_job.galaxy_web](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/job) | resource |
| [nomad_job.galaxy_worker](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/job) | resource |
| [nomad_namespace.galaxy](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/namespace) | resource |
| [nomad_volume.user_data](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/volume) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.id_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.master_api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
<!-- END_TF_DOCS -->