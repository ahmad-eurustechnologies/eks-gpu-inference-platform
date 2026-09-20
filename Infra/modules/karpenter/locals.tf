locals {

  helm_set = {
    "serviceAccount.annotations.\\eks\\.amazonaws\\.com\\/role-arn" = aws_iam_role.this.arn
    "replicas"                                                      = 1
    "settings.clusterName"                                          = var.eks_cluster_name
    "settings.clusterEndpoint"                                      = data.aws_eks_cluster.eks.endpoint
  }
}