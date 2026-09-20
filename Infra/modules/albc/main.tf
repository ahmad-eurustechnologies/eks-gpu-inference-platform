resource "helm_release" "this" {
  name             = "aws-lbc"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = var.namespace
  create_namespace = true
  cleanup_on_fail  = true

  set = [for k, v in merge(var.values, local.helm_set) : {
    name  = k
    value = v
  }]
  depends_on = [aws_iam_role.this]
}
