########################################
# Cluster basic setup
########################################
region = "us-east-1"
cluster_name = "eks-cluster-terraform-2"
cluster_version = "1.24"
cluster_endpoint_public_access = true              # Enable public&private endpoint
vpc_id = "vpc-0076d0b64d154ed76"
control_plane_subnet_ids = [ "subnet-0a9f5229a6db03185" , "subnet-042661bf6665a3846"]
subnet_ids = [ "subnet-0e0d79e95537345cd", "subnet-0086dbb3bda5619aa", "subnet-0c9d379d814da3162", "subnet-02364cc5caa606e85"]
cluster_enabled_log_types = ["audit", "api", "authenticator","controllerManager"]
#########################################
# aws_auth mapping
#########################################
cluster_admin_role = "arn:aws:iam::445362076974:role/AWSReservedSSO_AWSAdministratorAccess_8ad20b4ddc868601"

#########################################
# KMS key auth 
#########################################
key_owners = ["arn:aws:iam::445362076974:role/eks_creator",
"arn:aws:iam::445362076974:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AscendingPowerUserAccess_0187b639c6ef402a",
"arn:aws:iam::445362076974:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_8ad20b4ddc868601"]