
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "daoqi-terreaform-state"
    key            = "global/s3/terraform-2.tfstate"
    region         = "us-east-1"
    shared_credentials_file = "$HOME/.aws/credentials"
    profile        = "445362076974_AWSAdministratorAccess"
  }
}