# TODO:
# See about using S3 sync to create/replace the index.html file as proof of concept
# Automate DNS record creation
# Automate Let's encrypt cert acquisition

# ! use depends_on to make sure things are built in order of reference to other resources

# Specify the AWS CLI credentials to be used
# Need to see if there is a way to leverage AWS Secrets Manager on this step.
# Of course there is https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "C:\\Users\\Admin\\.aws\\credentials"
  profile                 = "Personal-us-east-1"
}
# Use module VPC to build infra that other services will be dependent on
module "vpc" {
  source = ".\\vpc"  
}
# Module EC2 is dependent on module VPC, this may not need to be explicitly defined
# but there's likely no harm in doing so.
# Security Group ID and Subnet ID are passed from the VPC Module
module "ec2" {
  source = ".\\ec2"
  tf_sg_id = "${module.vpc.tf_sg_id}"
  tf_subnet_id = "${module.vpc.tf_subnet_id}"
  depends_on = [
    module.vpc
  ]
}