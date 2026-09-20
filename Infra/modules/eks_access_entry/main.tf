resource "aws_eks_access_entry" "this" {
  cluster_name  = var.eks_cluster_name
  principal_arn = data.aws_iam_role.this.arn
}

resource "aws_eks_access_policy_association" "this" {
  cluster_name  = var.eks_cluster_name
  principal_arn = data.aws_iam_role.this.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = length(var.namespaces) > 0 ? "namespace" : "cluster"
    namespaces = length(var.namespaces) > 0 ? var.namespaces : null
  }

  depends_on = [aws_eks_access_entry.this]
}
