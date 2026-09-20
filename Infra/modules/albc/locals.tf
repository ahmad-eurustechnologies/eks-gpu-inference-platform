locals {

  helm_set = {
    "serviceAccount.annotations.\\eks\\.amazonaws\\.com\\/role-arn" = aws_iam_role.this.arn
    "serviceAccount.create"                                         = "true",
    "serviceAccount.name"                                           = "aws-lbc",
    "clusterName"                                                   = var.eks_cluster_name
  }
}