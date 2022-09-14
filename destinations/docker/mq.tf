resource "docker_image" "mq" {
  name = local.mq_image
  keep_locally = var.debug
}

resource "docker_container" "rabbitmq" {
  name       = "${local.mq_name}${local.name_suffix}"
  image      = docker_image.mq.latest
  hostname   = local.mq_name
  domainname = local.mq_name
  restart    = "unless-stopped"
  must_run   = true
  mounts {
    source = docker_volume.mq_data.name
    target = "/var/lib/rabbitmq"
    type   = "volume"
  }
  upload {
    file = "/etc/rabbitmq/enabled_plugins"
    content = "[rabbitmq_amqp1_0,rabbitmq_web_dispatch,rabbitmq_prometheus,rabbitmq_management_agent]."
  }
  networks_advanced {
    name    = local.network
    aliases = [local.mq_name]
  }
}