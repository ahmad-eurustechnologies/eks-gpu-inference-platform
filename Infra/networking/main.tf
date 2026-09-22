module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "Ahmad-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = {
    # "kubernetes.io/cluster/Ahmad-EKS" = "owned"
    "access" = "private"
  }

  public_subnet_tags = {
    # "kubernetes.io/cluster/Ahmad-EKS" = "owned"
    "access" = "public"
  }

}