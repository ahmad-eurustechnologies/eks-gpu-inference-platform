
resource "aws_cognito_user_pool_client" "this" {
  name         = "upload-api-client"
  user_pool_id = data.terraform_remote_state.platform_config.outputs.cognito_user_pool_id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = false
}

resource "aws_cognito_user" "me" {
  user_pool_id = data.terraform_remote_state.platform_config.outputs.cognito_user_pool_id
  username     = "ahmad"
}