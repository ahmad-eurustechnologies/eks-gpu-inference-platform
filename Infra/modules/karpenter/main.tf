resource "helm_release" "this" {
  name             = "karpenter"
  chart            = "oci://public.ecr.aws/karpenter/karpenter"
  version          = var.karpenter_version
  namespace        = var.namespace
  create_namespace = true
  cleanup_on_fail  = false

  set = [for k, v in merge(var.values, local.helm_set) : {
    name  = k
    value = v
  }]
}
