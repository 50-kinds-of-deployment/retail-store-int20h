resource "aws_iam_policy" "external_secrets" {
  name        = "${var.environment_name}-external-secrets"
  path        = "/"
  description = "IAM policy for External Secrets Operator to read from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = [
          aws_secretsmanager_secret.catalog_db_credentials.arn,
          aws_secretsmanager_secret.orders_db_credentials.arn,
          aws_secretsmanager_secret.mq_credentials.arn,
          aws_secretsmanager_secret.checkout_redis_credentials.arn
        ]
      }
    ]
  })
}
