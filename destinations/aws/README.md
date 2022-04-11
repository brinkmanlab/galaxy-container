# AWS Galaxy Deployment Module
<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_k8s"></a> [k8s](#module\_k8s) | ../k8s | n/a |
| <a name="module_nfs_server"></a> [nfs\_server](#module\_nfs\_server) | ./storage | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | List of email addresses for Galaxy admin users | `set(string)` | <pre>[<br>  "admin@brinkmanlab.ca"<br>]</pre> | no |
| <a name="input_app_max_replicas"></a> [app\_max\_replicas](#input\_app\_max\_replicas) | Maximum number of app replicas | `number` | `10` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Galaxy application container name | `string` | `null` | no |
| <a name="input_config_dir"></a> [config\_dir](#input\_config\_dir) | Path to galaxy configuration folder within container | `string` | `null` | no |
| <a name="input_data_dir"></a> [data\_dir](#input\_data\_dir) | Path to user data within container | `string` | `null` | no |
| <a name="input_db_conf"></a> [db\_conf](#input\_db\_conf) | Database configuration overrides | <pre>object({<br>    scheme = string<br>    host   = string<br>    name   = string<br>    user   = string<br>    pass   = string<br>  })</pre> | `null` | no |
| <a name="input_db_data_volume_name"></a> [db\_data\_volume\_name](#input\_db\_data\_volume\_name) | Database volume name | `string` | `null` | no |
| <a name="input_db_image"></a> [db\_image](#input\_db\_image) | MariaDB image name | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database container name | `string` | `null` | no |
| <a name="input_debug"></a> [debug](#input\_debug) | Enabling will put the deployment into a mode suitable for debugging | `bool` | `false` | no |
| <a name="input_eks"></a> [eks](#input\_eks) | Instance of EKS module output state | `any` | n/a | yes |
| <a name="input_email"></a> [email](#input\_email) | Email address to send automated emails from | `string` | n/a | yes |
| <a name="input_extra_job_mounts"></a> [extra\_job\_mounts](#input\_extra\_job\_mounts) | Extra mounts passed to job\_conf for jobs | `set(string)` | `[]` | no |
| <a name="input_extra_mounts"></a> [extra\_mounts](#input\_extra\_mounts) | Map of mount configurations to add to app and worker containers keyed on volume name | <pre>map(object({<br>    claim_name = string<br>    path       = string<br>    read_only  = bool<br>  }))</pre> | `{}` | no |
| <a name="input_galaxy_app_image"></a> [galaxy\_app\_image](#input\_galaxy\_app\_image) | Galaxy app server image name | `string` | `null` | no |
| <a name="input_galaxy_conf"></a> [galaxy\_conf](#input\_galaxy\_conf) | Galaxy configuration overrides | `map(string)` | `{}` | no |
| <a name="input_galaxy_root_volume_name"></a> [galaxy\_root\_volume\_name](#input\_galaxy\_root\_volume\_name) | Galaxy root volume name | `string` | `null` | no |
| <a name="input_galaxy_web_image"></a> [galaxy\_web\_image](#input\_galaxy\_web\_image) | Galaxy web server image name | `string` | `null` | no |
| <a name="input_id_secret"></a> [id\_secret](#input\_id\_secret) | Salt used to make Galaxy Ids unpredictable | `string` | `""` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag for galaxy\_web and galaxy\_app image | `string` | `"latest"` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Unique deployment instance identifier | `string` | `""` | no |
| <a name="input_job_destinations"></a> [job\_destinations](#input\_job\_destinations) | XML list of <destination> tags | `string` | `""` | no |
| <a name="input_lb_annotations"></a> [lb\_annotations](#input\_lb\_annotations) | Annotations to pass to the ingress load-balancer (https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer) | `map(string)` | `{}` | no |
| <a name="input_limits"></a> [limits](#input\_limits) | List of limits to add to the job\_conf.xml. id is optional and can be set as an empty string. | <pre>list(object({<br>    type  = string<br>    tag   = string<br>    value = string<br>    id    = string<br>  }))</pre> | `[]` | no |
| <a name="input_mail_name"></a> [mail\_name](#input\_mail\_name) | SMTP server name | `string` | `"mail"` | no |
| <a name="input_mail_port"></a> [mail\_port](#input\_mail\_port) | Port to connect to SMTP server | `number` | `587` | no |
| <a name="input_managed_config_dir"></a> [managed\_config\_dir](#input\_managed\_config\_dir) | Path to galaxy managed configuration folder on persistent storage | `string` | `null` | no |
| <a name="input_master_api_key"></a> [master\_api\_key](#input\_master\_api\_key) | Galaxy master API key | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Instance of kubernetes\_namespace to provision instance resources under | `any` | `null` | no |
| <a name="input_nfs_server"></a> [nfs\_server](#input\_nfs\_server) | URL to NFS server containing user data | `string` | `""` | no |
| <a name="input_plugins"></a> [plugins](#input\_plugins) | XML list of <plugin> tags | `string` | `""` | no |
| <a name="input_root_dir"></a> [root\_dir](#input\_root\_dir) | Path to galaxy root folder within container | `string` | `null` | no |
| <a name="input_static_tool_data_tables"></a> [static\_tool\_data\_tables](#input\_static\_tool\_data\_tables) | List of static tool data table loc files to load. Paths are relative to the value of `tool_data_path` in the galaxy config | <pre>list(object({<br>    name = string<br>    path = string<br>    allow_duplicate_entries = bool<br>    comment_char = string<br>    columns = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_tool_containers"></a> [tool\_containers](#input\_tool\_containers) | Mapping of tool IDs to tool containers | `map(string)` | `{}` | no |
| <a name="input_tool_mappings"></a> [tool\_mappings](#input\_tool\_mappings) | Tool ID to destination mappings. See roles/galaxy\_app/defaults/main/job\_conf.yml within the module root for destinations. | `map(string)` | `{}` | no |
| <a name="input_user_data_volume_name"></a> [user\_data\_volume\_name](#input\_user\_data\_volume\_name) | User data volume name | `string` | `null` | no |
| <a name="input_uwsgi_gid"></a> [uwsgi\_gid](#input\_uwsgi\_gid) | GID of Galaxy process | `number` | `null` | no |
| <a name="input_uwsgi_group"></a> [uwsgi\_group](#input\_uwsgi\_group) | Group name of Galaxy process | `string` | `null` | no |
| <a name="input_uwsgi_port"></a> [uwsgi\_port](#input\_uwsgi\_port) | Port Galaxy UWSGI server is listening from | `number` | `null` | no |
| <a name="input_uwsgi_uid"></a> [uwsgi\_uid](#input\_uwsgi\_uid) | UID of Galaxy process | `number` | `null` | no |
| <a name="input_uwsgi_user"></a> [uwsgi\_user](#input\_uwsgi\_user) | User name of Galaxy process | `string` | `null` | no |
| <a name="input_visualizations"></a> [visualizations](#input\_visualizations) | Set of URLs to tarballs to unpack into visualizations folder | `set(string)` | `[]` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Instance of VPC module output state | `any` | n/a | yes |
| <a name="input_web_max_replicas"></a> [web\_max\_replicas](#input\_web\_max\_replicas) | Maximum number of web replicas | `number` | `10` | no |
| <a name="input_web_name"></a> [web\_name](#input\_web\_name) | Galaxy web server container name | `string` | `null` | no |
| <a name="input_worker_max_replicas"></a> [worker\_max\_replicas](#input\_worker\_max\_replicas) | Maximum number of worker replicas | `number` | `10` | no |
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
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Galaxy front-end HTTP endpoint |
| <a name="output_galaxy_app_image"></a> [galaxy\_app\_image](#output\_galaxy\_app\_image) | n/a |
| <a name="output_galaxy_root_volume_name"></a> [galaxy\_root\_volume\_name](#output\_galaxy\_root\_volume\_name) | n/a |
| <a name="output_galaxy_web_image"></a> [galaxy\_web\_image](#output\_galaxy\_web\_image) | n/a |
| <a name="output_id_secret"></a> [id\_secret](#output\_id\_secret) | n/a |
| <a name="output_master_api_key"></a> [master\_api\_key](#output\_master\_api\_key) | n/a |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Kubernetes namespace containing Galaxy resources |
| <a name="output_nfs_server"></a> [nfs\_server](#output\_nfs\_server) | AWS EFS domain name mounted by Galaxy |
| <a name="output_root_dir"></a> [root\_dir](#output\_root\_dir) | n/a |
| <a name="output_smtp_conf"></a> [smtp\_conf](#output\_smtp\_conf) | galaxy\_conf must have email\_from configured for this to not be empty |
| <a name="output_user_data_volume_name"></a> [user\_data\_volume\_name](#output\_user\_data\_volume\_name) | n/a |
| <a name="output_uwsgi_gid"></a> [uwsgi\_gid](#output\_uwsgi\_gid) | n/a |
| <a name="output_uwsgi_port"></a> [uwsgi\_port](#output\_uwsgi\_port) | n/a |
| <a name="output_uwsgi_uid"></a> [uwsgi\_uid](#output\_uwsgi\_uid) | n/a |
| <a name="output_web_name"></a> [web\_name](#output\_web\_name) | n/a |
| <a name="output_worker_name"></a> [worker\_name](#output\_worker\_name) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.galaxy_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_iam_access_key.mail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.mail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.mail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.mail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_ses_email_identity.mail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_email_identity) | resource |
| [kubernetes_namespace.instance](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.galaxy_db](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.galaxy_mail](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.id_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.master_api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_static.now](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.mail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
<!-- END_TF_DOCS -->