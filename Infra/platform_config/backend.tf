terraform {
  
  backend "s3" {
    bucket = "terraform-backend-ahmad"
    key    = "Infra/platform_config.tfstate"
    region = "us-east-1"
  }
  
}


provider "aws" {
  region = "us-east-1"


  default_tags {
    tags = {
      created_by = local.created_by
      
    }
  }
  
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}