# One-time imports of existing resources into layers/ops state.
# Remove this file after successful `terraform apply`.

import {
  to = module.dependencies.module.checkout_elasticache_redis.aws_elasticache_subnet_group.default[0]
  id = "stage-retail-store-checkout"
}

import {
  to = module.dependencies.module.checkout_elasticache_redis.aws_elasticache_parameter_group.default[0]
  id = "stage-retail-store-checkout"
}

import {
  to = module.dependencies.module.dynamodb_carts.aws_dynamodb_table.this[0]
  id = "stage-retail-store-carts"
}

import {
  to = module.retail_app_eks.module.eks_cluster.module.kms.aws_kms_alias.this["cluster"]
  id = "alias/eks/stage-retail-store"
}

import {
  to = module.retail_app_eks.module.eks_cluster.aws_cloudwatch_log_group.this[0]
  id = "/aws/eks/stage-retail-store/cluster"
}

import {
  to = module.dependencies.aws_db_subnet_group.catalog
  id = "stage-retail-store-catalog-subnet"
}

import {
  to = module.dependencies.aws_db_subnet_group.orders
  id = "stage-retail-store-orders-subnet"
}

import {
  to = module.dependencies.aws_mq_broker.mq
  id = "b-c39da7bf-61c0-4ad2-b69c-2ab96eb16e63"
}
