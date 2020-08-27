locals {
  create_smtp = lookup(var.galaxy_conf, "email_from", "") != "" && lookup(var.galaxy_conf, "smtp_server", "") == "" ? 1 : 0
  smtp_conf = local.create_smtp == 1 ? {
    smtp_server   = "${local.mail_name}:${local.mail_port}"
    smtp_username = aws_iam_user.mail[0].name
    smtp_password = aws_iam_access_key.mail[0].ses_smtp_password_v4
  } : {}
}

resource "aws_iam_user" "mail" {
  count = local.create_smtp
  name  = "ses-smtp"
  path  = "/${local.instance}/"
}

data "aws_iam_policy_document" "mail" {
  statement {
    sid    = "SESSendEmail"
    effect = "Allow"
    actions = [
      "ses:SendRawEmail"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "mail" {
  count       = local.create_smtp
  name        = "ses-smtp"
  path        = "/${local.instance}/"
  description = "SES SMTP user policy"

  policy = data.aws_iam_policy_document.mail.json
}

resource "aws_iam_user_policy_attachment" "mail" {
  count      = local.create_smtp
  user       = aws_iam_user.mail[0].name
  policy_arn = aws_iam_policy.mail[0].arn
}

resource "aws_iam_access_key" "mail" {
  count = local.create_smtp
  user  = aws_iam_user.mail[0].name
}

resource "aws_ses_email_identity" "mail" {
  count = local.create_smtp
  email = var.email
}

## Register smtp in internal DNS
resource "kubernetes_service" "galaxy_mail" {
  depends_on = [var.eks]
  metadata {
    name      = local.mail_name
    namespace = local.instance
  }
  spec {
    type          = "ExternalName"
    external_name = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
  }
}