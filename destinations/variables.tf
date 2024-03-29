locals {
  ansible = yamldecode(file("${path.module}/../../vars.yml"))

  data_dir                = var.data_dir != null ? var.data_dir : local.ansible.paths.data
  root_dir                = var.root_dir != null ? var.root_dir : local.ansible.paths.root
  config_dir              = var.config_dir != null ? var.config_dir : local.ansible.paths.config
  managed_config_dir      = var.managed_config_dir != null ? var.managed_config_dir : local.ansible.paths.managed_config
  galaxy_web_image        = var.galaxy_web_image != null ? var.galaxy_web_image : "brinkmanlab/${local.ansible.containers.web.image}"
  galaxy_app_image        = var.galaxy_app_image != null ? var.galaxy_app_image : "brinkmanlab/${local.ansible.containers.app.image}"
  db_image                = var.db_image != null ? var.db_image : local.ansible.containers.db.image
  tusd_image              = var.tusd_image != null ? var.tusd_image : local.ansible.containers.tusd.image
  galaxy_root_volume_name = var.galaxy_root_volume_name != null ? var.galaxy_root_volume_name : local.ansible.volumes.galaxy_root.name
  user_data_volume_name   = var.user_data_volume_name != null ? var.user_data_volume_name : local.ansible.volumes.user_data.name
  db_data_volume_name     = var.db_data_volume_name != null ? var.db_data_volume_name : local.ansible.volumes.db_data.name
  web_name                = var.web_name != null ? var.web_name : local.ansible.containers.web.name
  app_name                = var.app_name != null ? var.app_name : local.ansible.containers.app.name
  worker_name             = var.worker_name != null ? var.worker_name : local.ansible.containers.worker.name
  celery_worker_name      = var.celery_worker_name != null ? var.celery_worker_name : local.ansible.containers.celery_worker.name
  celery_beat_name        = var.celery_beat_name != null ? var.celery_beat_name : local.ansible.containers.celery_beat.name
  db_name                 = var.db_name != null ? var.db_name : local.ansible.containers.db.name
  tusd_name               = var.tusd_name != null ? var.tusd_name : local.ansible.containers.tusd.name
  app_port                = var.app_port != null ? var.app_port : local.ansible.app.port
  app_uid                 = var.app_uid != null ? var.app_uid : local.ansible.app.uid
  app_gid                 = var.app_gid != null ? var.app_gid : local.ansible.app.gid
  app_user                = var.app_user != null ? var.app_user : local.ansible.app.user
  app_group               = var.app_group != null ? var.app_group : local.ansible.app.group

  mail_name = var.mail_name != null ? var.mail_name : regex("(?m)^mail.*hostname=(?P<mail_name>[^ ]+)", file("${path.root}/galaxy/inventory.ini")).mail_name
  mail_port = var.mail_port != null ? var.mail_port : regex("(?m)^mail.*port=(?P<mail_port>[^ ]+)", file("${path.root}/inventory.ini")).mail_port

  db_conf = var.db_conf != null ? var.db_conf : {
    scheme = "postgresql"
    host   = local.db_name
    name   = "galaxy"
    user   = "galaxy"
    pass   = random_password.db_password[0].result
  }
  master_api_key     = var.master_api_key != "" ? var.master_api_key : random_password.master_api_key.result
  id_secret          = var.id_secret != "" ? var.id_secret : random_password.id_secret.result
  common_galaxy_conf = {
    database_connection             = "${local.db_conf.scheme}://${local.db_conf.user}:${local.db_conf.pass}@${local.db_conf.host}/${local.db_conf.name}"
    master_api_key                  = local.master_api_key
    id_secret                       = local.id_secret
    email_from                      = var.email
    error_email_to                  = var.email
    container_resolvers_config_file = "${local.config_dir}/container_resolvers_conf.yml"
  }
  admin_users_conf = length(var.admin_users) == 0 ? {} : {
    admin_users = join(",", var.admin_users)
  }
  galaxy_conf = merge(local.common_galaxy_conf, local.admin_users_conf, local.destination_galaxy_conf, var.galaxy_conf)
  macros      = {
    "tool_mapping.xml"     = <<EOF
<?xml version="1.0"?>
<macros>
    <xml name="tool_mapping">
    <!--
    List tool mappings here to be included in the job_conf.xml
    <tool id="" destination="" />
    -->
    %{for k, v in var.tool_mappings}
      <tool id="${k}" destination="${v}" />
    %{endfor}
    </xml>
</macros>
EOF
    "job_destinations.xml" = <<EOF
<?xml version="1.0"?>
<macros>
    <xml name="plugins">
      ${var.plugins}
    </xml>
    <xml name="job_destinations">
      ${var.job_destinations}
    </xml>
</macros>
EOF
    "limits.xml"           = <<EOF
<?xml version="1.0"?>
<macros>
    <xml name="limits">
    %{for limit in var.limits}
      <limit type="${limit.type}"%{if limit.id != ""} ${limit.id}%{endif}%{if limit.tag != ""} tag="${limit.tag}"%{endif}>${limit.value}</limit>
    %{endfor}
    </xml>
</macros>
EOF
  }
  configs = {
    "tool_data_table_conf.xml"     = <<EOF
<?xml version="1.0"?>
<tables>
  %{for table in var.static_tool_data_tables}
  <table name="${table.name}" comment_char="${table.comment_char}" allow_duplicate_entries="${table.allow_duplicate_entries ? "True" : "False"}">
      <columns>${join(",", table.columns)}</columns>
      <file path="${table.path}" />
  </table>
  %{endfor}
</tables>
EOF
    # See https://github.com/galaxyproject/galaxy/commit/46fc861fb666f698290e6417a640d34626d10629#diff-466bfb1ecf19ceb83fd1f7918e1f087db3013582f5e7dc8f79263d6912dbc4b0R131
    "container_resolvers_conf.yml" = <<EOF
%{~if length(var.tool_containers) > 0~}
- type: mapping
  mappings:
    %{~for k, v in var.tool_containers~}
    - container_type: docker
      tool_id: "${k}"
      identifier: "${v}"
    %{~endfor~}
%{endif~}
- type: explicit
- type: mulled
  auto_install: "True"
EOF
  }
  viz_curl_cmd = join(" && ", [for url in var.visualizations : "curl -L '${url}' | tar -xvz -C '${local.managed_config_dir}/visualizations'"])
}

variable "db_conf" {
  type = object({
    scheme = string
    host   = string
    name   = string
    user   = string
    pass   = string
  })
  default     = null
  description = "Database configuration overrides"
}

resource "random_password" "db_password" {
  count   = var.db_conf == null ? 1 : 0
  length  = 16
  special = false
}

variable "master_api_key" {
  type        = string
  default     = ""
  description = "Galaxy master API key"
}

resource "random_password" "master_api_key" {
  #count = var.master_api_key == "" ? 1 : 0
  length  = 32
  special = false
}

variable "galaxy_conf" {
  type        = map(string)
  default     = {}
  description = "Galaxy configuration overrides"
}

resource "random_password" "id_secret" {
  #count = var.id_secret == "" ? 1 : 0
  length = 32
}

variable "id_secret" {
  type        = string
  default     = ""
  description = "Salt used to make Galaxy Ids unpredictable"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Tag for galaxy_web and galaxy_app image"
}

variable "tusd_tag" {
  type        = string
  default     = "latest"
  description = "Tag for tusproject/tusd docker image"
}

variable "instance" {
  type        = string
  default     = ""
  description = "Unique deployment instance identifier"
}

variable "data_dir" {
  type        = string
  default     = null
  description = "Path to user data within container"
}

variable "root_dir" {
  type        = string
  default     = null
  description = "Path to galaxy root folder within container"
}

variable "config_dir" {
  type        = string
  default     = null
  description = "Path to galaxy configuration folder within container"
}

variable "managed_config_dir" {
  type        = string
  default     = null
  description = "Path to galaxy managed configuration folder on persistent storage"
}

variable "galaxy_web_image" {
  type        = string
  default     = null
  description = "Galaxy web server image name"
}

variable "galaxy_app_image" {
  type        = string
  default     = null
  description = "Galaxy app server image name"
}

variable "db_image" {
  type        = string
  default     = null
  description = "MariaDB image name"
}

variable "tusd_image" {
  type        = string
  default     = null
  description = "TUSd image name"
}

variable "galaxy_root_volume_name" {
  type        = string
  default     = null
  description = "Galaxy root volume name"
}

variable "user_data_volume_name" {
  type        = string
  default     = null
  description = "User data volume name"
}

variable "db_data_volume_name" {
  type        = string
  default     = null
  description = "Database volume name"
}

variable "web_name" {
  type        = string
  default     = null
  description = "Galaxy web server container name"
}

variable "app_name" {
  type        = string
  default     = null
  description = "Galaxy application container name"
}

variable "worker_name" {
  type        = string
  default     = null
  description = "Galaxy worker container name"
}

variable "celery_worker_name" {
  type        = string
  default     = null
  description = "Galaxy celery worker container name"
}

variable "celery_beat_name" {
  type        = string
  default     = null
  description = "Galaxy celery beat container name"
}

variable "db_name" {
  type        = string
  default     = null
  description = "Database container name"
}

variable "tusd_name" {
  type        = string
  default     = null
  description = "TUSd container name"
}

variable "app_port" {
  type        = number
  default     = null
  description = "Port Galaxy app server is listening from"
}

variable "app_uid" {
  type        = number
  default     = null
  description = "UID of Galaxy process"
}

variable "app_gid" {
  type        = number
  default     = null
  description = "GID of Galaxy process"
}

variable "app_user" {
  type        = string
  default     = null
  description = "User name of Galaxy process"
}

variable "app_group" {
  type        = string
  default     = null
  description = "Group name of Galaxy process"
}

variable "mail_name" {
  type        = string
  default     = "mail"
  description = "SMTP server name"
}

variable "mail_port" {
  # TODO is it actually required to specify the port?
  type        = number
  default     = 587
  description = "Port to connect to SMTP server"
}

variable "admin_users" {
  type        = set(string)
  default     = ["admin@brinkmanlab.ca"]
  description = "List of email addresses for Galaxy admin users"
}

variable "email" {
  type        = string
  description = "Email address to send automated emails from"
}

variable "debug" {
  type        = bool
  default     = false
  description = "Enabling will put the deployment into a mode suitable for debugging"
}

variable "plugins" {
  type        = string
  default     = ""
  description = "XML list of <plugin> tags"
}

variable "job_destinations" {
  type        = string
  default     = ""
  description = "XML list of <destination> tags"
}

variable "tool_mappings" {
  type        = map(string)
  default     = {}
  description = "Tool ID to destination mappings. See roles/galaxy_app/defaults/main/job_conf.yml within the module root for destinations."
}

variable "limits" {
  type = list(object({
    type  = string
    tag   = string
    value = string
    id    = string
  }))
  default     = []
  description = "List of limits to add to the job_conf.xml. id is optional and can be set as an empty string."
}

variable "extra_job_mounts" {
  type        = set(string)
  default     = []
  description = "Extra mounts passed to job_conf for jobs"
}

variable "visualizations" {
  type        = set(string)
  default     = []
  description = "Set of URLs to tarballs to unpack into visualizations folder"
}

variable "static_tool_data_tables" {
  type = list(object({
    name                    = string
    path                    = string
    allow_duplicate_entries = bool
    comment_char            = string
    columns                 = list(string)
  }))
  default     = []
  description = "List of static tool data table loc files to load. Paths are relative to the value of `tool_data_path` in the galaxy config"
}

variable "tool_containers" {
  type        = map(string)
  default     = {}
  description = "Mapping of tool IDs to tool containers"
}

variable "extra_env" {
  type        = map(any)
  default     = {}
  description = "Additional environment variables for Galaxy containers"
}