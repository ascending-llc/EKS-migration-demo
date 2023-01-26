# Update local kubeconfig to use the correct cluster
resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
    }
}
###############################################################
# aws-ebs-csi-driver
###############################################################
resource "helm_release" "aws-ebs-csi-driver" {
  name       = "aws-ebs-csi-driver"
  namespace = "kube-system"


  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  set{
    name = "controller.serviceAccount.name"
    value = "${kubernetes_service_account_v1.ebs-csi-controller.metadata.0.name}"
  }
}

###############################################################
# kube-ops-view
###############################################################
resource "helm_release" "kube-ops-view" {
  name       = "kube-ops-view"

  repository = "https://christianknell.github.io/helm-charts"
  chart      = "kube-ops-view"

  set {
    name = "service.port"
    value = 90
  }
}

###############################################################
# Metrics Server
###############################################################
resource "helm_release" "eks-metrics-server" {
  name       = "eks-metrics-server"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

}