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
