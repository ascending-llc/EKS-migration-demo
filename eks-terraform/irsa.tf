locals {
  region = "us-east-1"

  tags = {
    IRSA = "true"
    Environment = "test"
    Terraform   = "true"
  }
}
##############################################################
# Create Service Account & secret
##############################################################

resource "kubernetes_service_account_v1" "ebs-csi-controller" {
  metadata {
    name = "ebs-csi-controller-irsa"
    namespace = "kube-system"
    annotations = {"eks.amazonaws.com/role-arn" = "${module.iam_eks_role_ebs.iam_role_arn}"}
  }
  secret {
    name = "${kubernetes_secret_v1.ebs-csi-controller.metadata.0.name}"
  }
  
}

resource "kubernetes_secret_v1" "ebs-csi-controller" {
  metadata {
    name = "ebs-csi-controller-irsa"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "ebs-csi-controller-irsa"
    }
  }
  
  # apply again if secret is not created at the first time
  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = false

}

# Service Account for AWS EFS driver
resource "kubernetes_service_account_v1" "efs-csi-controller" {
  metadata {
    name = "efs-csi-controller-irsa"
    namespace = "kube-system"
    annotations = {"eks.amazonaws.com/role-arn" = "${module.iam_eks_role_efs.iam_role_arn}"}
  }
  secret {
    name = "${kubernetes_secret_v1.efs-csi-controller.metadata.0.name}"
  }
  
}

resource "kubernetes_secret_v1" "efs-csi-controller" {
  metadata {
    name = "efs-csi-controller-irsa"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "efs-csi-controller-irsa"
    }
  }
  
  # apply again if secret is not created at the first time
  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = false

}

# Service Account for Cluster-Autoscaler
resource "kubernetes_service_account_v1" "irsa-cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler-irsa"
    namespace = "kube-system"
    annotations = {"eks.amazonaws.com/role-arn" = "${module.iam_eks_role_cluster_autoscaler.iam_role_arn}"}
  }
  secret {
    name = "${kubernetes_secret_v1.cluster-autoscaler.metadata.0.name}"
  }
}

#
resource "kubernetes_secret_v1" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler-irsa-secret"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "cluster-autoscaler-irsa"
    }
  }
  
  # apply again if secret is not created at the first time
  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = false

}

# ##############################################################
# # Create/Link IAM role with service account
# ##############################################################
module "iam_eks_role_ebs" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "ebs-csi-irsa-${module.eks.cluster_name}"

  attach_ebs_csi_policy = true

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-irsa"]
    }
  }

  tags = local.tags
}

module "iam_eks_role_efs" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "efs-csi-irsa-${module.eks.cluster_name}"

  attach_efs_csi_policy = true

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-irsa"]
    }
  }

  tags = local.tags
}


module "iam_eks_role_cluster_autoscaler" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "cluster-autoscaler-irsa-${module.eks.cluster_name}"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids = [module.eks.cluster_name]

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler-irsa"]
    }
  }

  tags = local.tags
}