data "aws_region" "current" {}

resource "kubernetes_manifest" "upload_api_request_authentication" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "RequestAuthentication"
    metadata = {
      name      = "${local.upload_api_base_k8s_name}-jwt"
      namespace = local.namespace
    }
    spec = {
      selector = {
        matchLabels = {
          app = local.upload_api_base_k8s_name
        }
      }
      jwtRules = [
        {
          issuer  = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${data.terraform_remote_state.platform_config.outputs.cognito_user_pool_id}"
          jwksUri = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${data.terraform_remote_state.platform_config.outputs.cognito_user_pool_id}/.well-known/jwks.json"
        }
      ]
    }
  }

}

resource "kubernetes_manifest" "upload_api_authorization_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "${local.upload_api_base_k8s_name}-require-jwt"
      namespace = local.namespace
    }
    spec = {
      selector = {
        matchLabels = {
          app = local.upload_api_base_k8s_name
        }
      }
      action = "ALLOW"
      rules = [
        {
          from = [
            {
              source = {
                requestPrincipals = ["*"]
              }
            }
          ]
          when = [
            {
              key    = "request.auth.claims[cognito:username]"
              values = ["ahmad"]
            }
          ]
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.upload_api_request_authentication]
}