locals {
  common_hcl_vars = {
    namespace = local.namespace.name
    user_data = nomad_volume.user_data.id
  }

  web_vars = merge(local.common_hcl_vars, {
    name = local.web_name
    image = local.galaxy_web_image
    tag = var.image_tag
    master_api_key = local.master_api_key
    data_dir = local.data_dir
  })

  app_vars = merge(local.common_hcl_vars, {
    name = local.app_name
    image = local.galaxy_app_image
    tag = var.image_tag
    app_port = local.app_port
    configs = local.configs
  })

  worker_vars = merge(local.common_hcl_vars, {
    name = local.worker_name
    image = local.galaxy_app_image
    tag = var.image_tag
    root_dir = local.root_dir
    config_dir = local.config_dir
    app_port = local.app_port
    envs = merge({for key, value in local.galaxy_conf: "GALAXY_CONFIG_OVERRIDE_${key}" => value}, {
      NOMAD_ENABLED   = "True"
      NOMAD_NAMESPACE = local.namespace.name
      NOMAD_VOLUMES   = "${nomad_volume.user_data.id}:${local.data_dir}${length(var.extra_job_mounts) > 0 ? "," : ""}${join(",", var.extra_job_mounts)}"
      NOMAD_DEFAULT_IMAGE_TAG = var.image_tag
      NOMAD_ADDR = "TODO"
      NOMAD_TOKEN = "TODO"
      NOMAD_REGION = "TODO"
      NOMAD_CLIENT_CERT = "TODO path"
      NOMAD_CLIENT_KEY = "TODO path"
    }, {"CWD" : local.root_dir}),
    extra_mounts = var.extra_mounts
    configs = local.configs
  })
}

resource "nomad_namespace" "galaxy" {
  count = var.namespace == null ? 1 : 0
  name        = local.instance
  description = "Galaxy deployment"
}

resource "nomad_volume" "user_data" {
  namespace = local.namespace.name
  type            = "csi"
  plugin_id       = "TODO"
  volume_id       = "user_data"
  name            = "Galaxy user data store"
  external_id     = var.nfs_server
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"

  mount_options {
    fs_type = "ext4"
  }
}

resource "nomad_job" "galaxy_web" {
  depends_on = [nomad_job.galaxy_app]
  jobspec = templatefile("${abspath(path.module)}/web.hcl2", local.web_vars)

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}

resource "nomad_job" "galaxy_app" {
  depends_on = [nomad_job.upgrade_db, nomad_job.visualizations-fix]
  jobspec = templatefile("${abspath(path.module)}/app.hcl2", local.app_vars)

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}

resource "nomad_job" "galaxy_worker" {
  depends_on = [nomad_job.upgrade_db]
  jobspec = templatefile("${abspath(path.module)}/worker.hcl2", local.worker_vars)

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}