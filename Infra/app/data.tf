data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "terraform-backend-ahmad"
    key    = "Infra/EKS.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "platform_config" {
  backend = "s3"

  config = {
    bucket = "terraform-backend-ahmad"
    key    = "Infra/platform_config.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "base_k8s_services" {
  backend = "s3"

  config = {
    bucket = "terraform-backend-ahmad"
    key    = "Infra/base_k8s_services.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster" "eks" {
  name = data.terraform_remote_state.eks.outputs.cluster_name

}

data "aws_caller_identity" "current" {}