resource "kubernetes_secret" "galaxy_config" {
  metadata {
    name = "galaxy-config"
    namespace = local.instance
  }
  data = {
    "workflow_schedulers.xml" = <<-EOF
      <macros>
          <xml name="workflow_schedulers">
          <!--
          List workflow scheduler handlers here to be included in the workflow_schedulers_conf.xml
          <handler id="" tags="schedulers" />
          -->
          %{ for i in range(var.scheduler_replicas) }
            <handler id="workflow-scheduler${i}" tags="schedulers" />
          %{ endfor }
          </xml>
      </macros>
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