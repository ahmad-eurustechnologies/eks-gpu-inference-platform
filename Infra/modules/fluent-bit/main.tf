resource "helm_release" "this" {
  name             = "aws-for-fluent-bit"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-for-fluent-bit"
  namespace        = var.namespace
  create_namespace = true
  cleanup_on_fail  = true

  set = [for k, v in merge(var.values, local.helm_set) : {
    name  = k
    value = v
  }]
}
