resource "aws_iam_role" "external_dns_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
  name               = "external-dns"
}

data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-dns:external-dns"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "external_dns_iam_policy" {
  policy = file("Infra/modules/custom_policies/external_dns.json")
  name   = "external_dns_iam_policy"
}

resource "aws_iam_role_policy_attachment" "external_dns_role_attachment" {
  policy_arn = aws_iam_policy.external_dns_iam_policy.arn
  role       = aws_iam_role.external_dns_iam_role.name
}