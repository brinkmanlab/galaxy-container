resource "kubernetes_secret" "galaxy_config" {
  metadata {
    name = "galaxy-config"
    namespace = local.instance
  }
  data = {
    "workflow_schedulers.xml" = <<-EOF
      <?xml version="1.0"?>
      <workflow_schedulers default="core">
        <core id="core" />
        <handlers assign_with="db-preassign" default="schedulers">
          %{ for i in range(var.scheduler_replicas) }
            <handler id="workflow-scheduler${i}" tags="schedulers" />
          %{ endfor }
        </handlers>
      </workflow_schedulers>
    EOF
    "tool_mapping.xml" = <<-EOF
      <macros>
          <xml name="tool_mapping">
          <!--
          List tool mappings here to be included in the job_conf.xml
          Destinations include: default and big
          <tool id="" destination="" />
          -->
          </xml>
      </macros>
    EOF
  }
}