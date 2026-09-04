data "aws_acm_certificate" "this" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  chart            = "oci://gcr.io/istio-release/charts/base"
  version          = var.istio_version
  namespace        = var.namespace
  create_namespace = true
  cleanup_on_fail  = false

  set = [
    for k, v in var.istio_base_values : {
      name  = k
      value = v
    }
  ]
}

resource "helm_release" "istiod" {
  name             = "istiod"
  chart            = "oci://gcr.io/istio-release/charts/istiod"
  version          = var.istio_version
  namespace        = var.namespace
  create_namespace = true
  cleanup_on_fail  = false

  depends_on = [
    helm_release.istio_base
  ]

  set = [
    for k, v in var.istiod_values : {
      name  = k
      value = v
    }
  ]
}

resource "helm_release" "istio_ingressgateway" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = "istio-system"
  version    = var.istio_version
  depends_on = [helm_release.istiod, helm_release.istio_base]

  set = [
    {
      name  = "service.type"
      value = "LoadBalancer"
    },
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "external"
    },
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
      value = "ip"
    },
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internet-facing"
    },
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
      value = data.aws_acm_certificate.this.arn
    },
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
      value = "443"
      type  = "string"
    },
    {
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
      value = "tcp"
    }
  ]
}