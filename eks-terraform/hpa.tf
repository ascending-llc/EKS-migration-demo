
###############################################################
# HPA for wordpress frontend deployment
###############################################################

resource "kubernetes_horizontal_pod_autoscaler_v2" "wordpress-hpa" {
  metadata {
    name = "wordpress-hpa"
    namespace = "wordpress"
  }
  spec {
    min_replicas = 1
    max_replicas = 10
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "wordpress"
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
            type = "Utilization"
            average_utilization = 50
        }
      }
    }
  }
}