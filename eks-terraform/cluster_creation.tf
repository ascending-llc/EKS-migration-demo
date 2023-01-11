#################################################################################
# This terraform template creates an EKS cluster with a self-mananged nodegroup 
# and one EKS-managed nodegroup. The cluster admin is set during cluster creation.
#################################################################################
provider "aws" {
  region = var.region
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token

}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.4.2"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {

    instance_type                          = "t3.small"
    update_launch_template_default_version = true
    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${var.cluster_name}" : "owned",
    }
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }

  }

  self_managed_node_groups = {
    sng-1 = {
      name         = "self-nodegroup-1"
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      min_size     = 1
      max_size     = 2
      desired_size = 1
      # Use spot instance for self managed node group
      instance_market_options = {market_type = "spot"}

    }

  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    mng-1 = {
      name         = "managed-nodegroup-1"
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.medium"]
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [

    {
      rolearn  = var.cluster_admin_role
      username = "Admin:{{SessionName}}"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = "test"
    Terraform   = "true"
  }
}
