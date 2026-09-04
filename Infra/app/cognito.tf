resource "aws_cognito_user_pool" "this" {
  name = "portfolio-users"

  username_attributes = []

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "upload-api-client"
  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = false
}

resource "aws_cognito_user" "me" {
  user_pool_id = aws_cognito_user_pool.this.id
  username     = "ahmad"
}