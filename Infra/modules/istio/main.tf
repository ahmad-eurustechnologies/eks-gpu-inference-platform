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

# ----------------------------------------------------------------------------
# DNS for the ingress gateway
#
# The AWS Load Balancer Controller provisions the NLB asynchronously once the
# Service exists, so the helm_release returning is not enough -- we have to wait
# for status.loadBalancer.ingress to be populated before we can read the
# hostname. Requires kubectl on the machine running terraform, which infra.sh
# already configures via `aws eks update-kubeconfig`.
# ----------------------------------------------------------------------------

resource "null_resource" "wait_for_nlb" {
  depends_on = [helm_release.istio_ingressgateway]

  triggers = {
    release = helm_release.istio_ingressgateway.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      for i in $(seq 1 60); do
        host=$(kubectl get svc istio-ingressgateway -n ${var.namespace} \
          -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
        if [ -n "$host" ]; then
          echo "load balancer ready: $host"
          exit 0
        fi
        echo "waiting for load balancer... ($i/60)"
        sleep 10
      done
      echo "timed out after 10 minutes waiting for the NLB" >&2
      exit 1
    EOT
  }
}

# Looked up by the tags the AWS Load Balancer Controller puts on the NLB it
# provisions for the gateway Service. Confirm them with:
#   aws elbv2 describe-tags --resource-arns <nlb-arn>
data "aws_lb" "istio_ingressgateway" {
  tags = {
    "service.k8s.aws/stack" = "${var.namespace}/istio-ingressgateway"
    "elbv2.k8s.aws/cluster" = var.eks_cluster_name
  }

  depends_on = [null_resource.wait_for_nlb]
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "gateway" {
  for_each = toset(var.gateway_hostnames)

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = data.aws_lb.istio_ingressgateway.dns_name
    zone_id                = data.aws_lb.istio_ingressgateway.zone_id
    evaluate_target_health = true
  }
}
