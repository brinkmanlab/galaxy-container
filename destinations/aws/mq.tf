locals {
  mq_role_name = "galaxy-mq${local.name_suffix}"
}

#resource "aws_sqs_queue" "celery" {
#  name_prefix = "celery${local.name_suffix}"
#  lifecycle {
#    ignore_changes = [sqs_managed_sse_enabled]
#  }
#}
#
#resource "aws_sqs_queue" "galaxy-external" {
#  name_prefix = "galaxy-external${local.name_suffix}"
#  lifecycle {
#    ignore_changes = [sqs_managed_sse_enabled]
#  }
#}
#
#resource "aws_sqs_queue" "galaxy-internal" {
#  name_prefix = "galaxy-internal${local.name_suffix}"
#  lifecycle {
#    ignore_changes = [sqs_managed_sse_enabled]
#  }
#}

data "aws_iam_policy_document" "mq_assume_role_with_oidc" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(var.eks.cluster_oidc_issuer_url, "https://")}:sub"
      values   = [
        "system:serviceaccount:${local.namespace.id}:${local.app_name}",
        "system:serviceaccount:${local.namespace.id}:${local.worker_name}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(var.eks.cluster_oidc_issuer_url, "https://")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mq" {
  name_prefix        = local.mq_role_name
  assume_role_policy = data.aws_iam_policy_document.mq_assume_role_with_oidc.json
}

data "aws_iam_policy_document" "mq" {
  statement {
    effect  = "Allow"
    actions = [
      "sqs:*",
    ]

    resources = [
      "*"
      #  aws_sqs_queue.celery.arn,
      #  aws_sqs_queue.galaxy-external.arn,
      #  aws_sqs_queue.galaxy-internal.arn,
    ]
  }
}

resource "aws_iam_policy" "mq" {
  name_prefix = "mq"
  path        = "/${local.instance}/"
  description = "SQS Message Queue access policy"

  policy = data.aws_iam_policy_document.mq.json
}

resource "aws_iam_role_policy_attachment" "mq" {
  role       = aws_iam_role.mq.name
  policy_arn = aws_iam_policy.mq.arn
}