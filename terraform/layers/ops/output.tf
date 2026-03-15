output "configure_kubectl" {
  description = "Command to update kubeconfig for this cluster"
  value       = module.retail_app_eks.configure_kubectl
}

output "eks_cluster_id" {
  value = module.retail_app_eks.eks_cluster_id
}

output "cluster_endpoint" {
  value = module.retail_app_eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.retail_app_eks.cluster_certificate_authority_data
}

output "eks_oidc_issuer_url" {
  value = module.retail_app_eks.eks_oidc_issuer_url
}

output "cluster_blocker_id" {
  value = module.retail_app_eks.cluster_blocker_id
}

output "addons_blocker_id" {
  value = module.retail_app_eks.addons_blocker_id
}

output "adot_namespace" {
  value = module.retail_app_eks.adot_namespace
}

output "catalog_db_endpoint" { value = module.dependencies.catalog_db_endpoint }
output "catalog_db_port" { value = module.dependencies.catalog_db_port }
output "catalog_db_master_username" {
  value     = module.dependencies.catalog_db_master_username
  sensitive = true
}
output "catalog_db_master_password" {
  value     = module.dependencies.catalog_db_master_password
  sensitive = true
}

output "carts_dynamodb_table_name" { value = module.dependencies.carts_dynamodb_table_name }
output "carts_dynamodb_policy_arn" { value = module.dependencies.carts_dynamodb_policy_arn }

output "checkout_elasticache_primary_endpoint" { value = module.dependencies.checkout_elasticache_primary_endpoint }
output "checkout_elasticache_port" { value = module.dependencies.checkout_elasticache_port }

output "orders_db_endpoint" { value = module.dependencies.orders_db_endpoint }
output "orders_db_port" { value = module.dependencies.orders_db_port }
output "orders_db_database_name" { value = module.dependencies.orders_db_database_name }
output "orders_db_master_username" {
  value     = module.dependencies.orders_db_master_username
  sensitive = true
}
output "orders_db_master_password" {
  value     = module.dependencies.orders_db_master_password
  sensitive = true
}

output "mq_broker_endpoint" { value = module.dependencies.mq_broker_endpoint }
output "mq_user" {
  value     = module.dependencies.mq_user
  sensitive = true
}
output "mq_password" {
  value     = module.dependencies.mq_password
  sensitive = true
}

output "catalog_sg_id" { value = aws_security_group.catalog.id }
output "checkout_sg_id" { value = aws_security_group.checkout.id }
output "orders_sg_id" { value = aws_security_group.orders.id }
output "ui_sg_id" { value = aws_security_group.ui.id }

output "catalog_db_secret_arn" { value = module.dependencies.catalog_db_secret_arn }
output "orders_db_secret_arn" { value = module.dependencies.orders_db_secret_arn }
output "mq_secret_arn" { value = module.dependencies.mq_secret_arn }

output "external_secrets_policy_arn" { value = module.dependencies.external_secrets_policy_arn }
output "checkout_redis_secret_arn" { value = module.dependencies.checkout_redis_secret_arn }
