########################################
# Cluster basic setup
########################################
cluster_name = "eks-cluster-terraform-1"
cluster_version = "1.24"
cluster_endpoint_public_access = true              # Enable public&private endpoint
vpc_id = "vpc-0076d0b64d154ed76"
control_plane_subnet_ids = [ "subnet-0a9f5229a6db03185" , "subnet-042661bf6665a3846"]
subnet_ids = [ "subnet-0e0d79e95537345cd", "subnet-0086dbb3bda5619aa", "subnet-0c9d379d814da3162", "subnet-02364cc5caa606e85"]

#########################################
# aws_auth mapping
#########################################
cluster_admin_role = "arn:aws:iam::445362076974:role/AWSReservedSSO_AdministratorAccess_4791515236a6e2f7"