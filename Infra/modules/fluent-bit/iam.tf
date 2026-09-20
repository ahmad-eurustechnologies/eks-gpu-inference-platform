data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {

  name = "fluent-bit-role-${local.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.cluster_oidc_issuer_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:aws-for-fluent-bit:aws-for-fluent-bit",

          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "this" {
  policy = file("${path.module}/../custom_policies/fluent-bit.json")
  name   = "fluent-bit-policy-${local.cluster_name}"
}



resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
