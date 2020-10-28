resource "kubernetes_secret" "galaxy_config" {
  metadata {
    name = "galaxy-config"
    namespace = local.namespace.metadata.0.name
  }
  data = {
    "tool_mapping.xml" = <<-EOF
      <macros>
          <xml name="tool_mapping">
          <!--
          List tool mappings here to be included in the job_conf.xml
          <tool id="" destination="" />
          -->
          %{ for k, v in var.tool_mappings }
            <tool id="${k}" destination="${v}" />
          %{ endfor }
          </xml>
      </macros>
    EOF
    "job_destinations.xml" = <<-EOF
      <macros>
          <xml name="job_destinations">
          </xml>
      </macros>
    EOF
  }
}