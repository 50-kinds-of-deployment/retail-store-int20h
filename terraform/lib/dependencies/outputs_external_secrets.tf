output "external_secrets_policy_arn" {
  description = "ARN of IAM policy to access AWS Secrets Manager for External Secrets Operator"
  value       = aws_iam_policy.external_secrets.arn
}
