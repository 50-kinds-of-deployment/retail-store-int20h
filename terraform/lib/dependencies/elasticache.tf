module "checkout_elasticache_redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.53.0"

  name                       = "${var.environment_name}-checkout"
  vpc_id                     = var.vpc_id
  instance_type              = "cache.t3.micro"
  subnets                    = var.subnet_ids
  transit_encryption_enabled = false
  tags                       = var.tags

  allowed_security_group_ids = concat(var.allowed_security_group_ids, [var.checkout_security_group_id])
}

resource "aws_secretsmanager_secret" "checkout_redis_credentials" {
  name        = "${var.environment_name}-checkout-redis-credentials"
  description = "Credentials for the Checkout Redis cache"

  recovery_window_in_days = 0 # Force deletion without recovery to ease destruction
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "checkout_redis_credentials" {
  secret_id = aws_secretsmanager_secret.checkout_redis_credentials.id
  secret_string = jsonencode({
    url = "redis://${module.checkout_elasticache_redis.endpoint}:${module.checkout_elasticache_redis.port}"
  })
}
