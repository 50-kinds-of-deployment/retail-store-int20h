output "catalog_db_endpoint" {
  description = "Hostname (without port) for the catalog database"
  value       = split(":", module.catalog_rds.db_instance_endpoint)[0]
}

output "catalog_db_database_name" {
  description = "Database name for the catalog database"
  value       = "catalog"
}

output "catalog_db_master_password" {
  description = "Master password for the catalog database"
  value       = random_string.catalog_db_master.result
  sensitive   = true
}

output "catalog_db_master_username" {
  description = "Master username for the catalog database"
  value       = "catalyst"
  sensitive   = true
}

output "catalog_db_port" {
  description = "Port for the catalog database"
  value       = module.catalog_rds.db_instance_port
}

output "catalog_db_reader_endpoint" {
  description = "Hostname (without port) for the catalog database (read-only)"
  value       = split(":", module.catalog_rds.db_instance_endpoint)[0]
}

output "catalog_db_arn" {
  description = "ARN for the catalog database"
  value       = module.catalog_rds.db_instance_arn
}

output "orders_db_endpoint" {
  description = "Hostname (without port) for the orders database"
  value       = split(":", module.orders_rds.db_instance_endpoint)[0]
}

output "orders_db_database_name" {
  description = "Database name for the orders database"
  value       = "orders"
}

output "orders_db_master_password" {
  description = "Master password for the orders database"
  value       = random_string.orders_db_master.result
  sensitive   = true
}

output "orders_db_master_username" {
  description = "Master username for the orders database"
  value       = "postgres"
  sensitive   = true
}

output "orders_db_port" {
  description = "Port for the orders database"
  value       = module.orders_rds.db_instance_port
}

output "orders_db_reader_endpoint" {
  description = "Hostname (without port) for the orders database (read-only)"
  value       = split(":", module.orders_rds.db_instance_endpoint)[0]
}

output "orders_db_arn" {
  description = "ARN for the orders database"
  value       = module.orders_rds.db_instance_arn
}

output "carts_dynamodb_table_arn" {
  description = "ARN of the carts DynamoDB table"
  value       = module.dynamodb_carts.dynamodb_table_arn
}

output "carts_dynamodb_table_name" {
  description = "Name of the carts DynamoDB table"
  value       = module.dynamodb_carts.dynamodb_table_id
}

output "carts_dynamodb_policy_arn" {
  description = "ARN of IAM policy to access carts DynamoDB table"
  value       = aws_iam_policy.carts_dynamo.arn
}

output "mq_broker_id" {
  value       = aws_mq_broker.mq.id
  description = "AmazonMQ broker ID"
}

output "mq_broker_arn" {
  value       = aws_mq_broker.mq.arn
  description = "AmazonMQ broker ARN"
}

output "mq_broker_endpoint" {
  value       = aws_mq_broker.mq.instances[0].endpoints[0]
  description = "AmazonMQ broker endpoint"
}

output "mq_password" {
  value       = random_password.mq_password.result
  sensitive   = true
  description = "AmazonMQ Admin password."
}

output "mq_user" {
  value       = local.mq_default_user
  description = "AmazonMQ Admin user"
}

output "checkout_elasticache_arn" {
  value       = module.checkout_elasticache_redis.arn
  description = "Checkout Redis ElastiCache ARN."
}

output "checkout_elasticache_primary_endpoint" {
  value       = module.checkout_elasticache_redis.endpoint
  description = "Checkout Redis hostname"
}

output "checkout_elasticache_reader_endpoint" {
  value       = module.checkout_elasticache_redis.reader_endpoint_address
  description = "Checkout Redis reader hostname"
}

output "checkout_elasticache_port" {
  value       = module.checkout_elasticache_redis.port
  description = "Checkout Redis port"
}

output "catalog_db_secret_arn" {
  value       = aws_secretsmanager_secret.catalog_db_credentials.arn
  description = "ARN of the AWS Secrets Manager secret for Catalog DB credentials"
}

output "orders_db_secret_arn" {
  value       = aws_secretsmanager_secret.orders_db_credentials.arn
  description = "ARN of the AWS Secrets Manager secret for Orders DB credentials"
}

output "mq_secret_arn" {
  value       = aws_secretsmanager_secret.mq_credentials.arn
  description = "ARN of the AWS Secrets Manager secret for RabbitMQ credentials"
}
