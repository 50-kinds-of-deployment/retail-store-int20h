data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

locals {
  security_groups_active = !var.opentelemetry_enabled
  tags                   = data.terraform_remote_state.bootstrap.outputs.tags
}

module "vpc" {
  source = "../../../lib/vpc"

  environment_name = var.environment_name

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.environment_name}" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.environment_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }

  tags = local.tags
}

module "retail_app_eks" {
  source = "../../../lib/eks"

  providers = {
    kubernetes.cluster = kubernetes
    kubernetes.addons  = kubernetes
    helm               = helm
  }

  environment_name      = var.environment_name
  cluster_version       = "1.33"
  vpc_id                = module.vpc.inner.vpc_id
  vpc_cidr              = module.vpc.inner.vpc_cidr_block
  subnet_ids            = module.vpc.inner.private_subnets
  opentelemetry_enabled = var.opentelemetry_enabled
  tags                  = local.tags

  istio_enabled = var.istio_enabled
}

module "dependencies" {
  source = "../../../lib/dependencies"

  environment_name = var.environment_name
  tags             = local.tags

  vpc_id     = module.vpc.inner.vpc_id
  subnet_ids = module.vpc.inner.private_subnets

  catalog_security_group_id  = local.security_groups_active ? aws_security_group.catalog.id : module.retail_app_eks.node_security_group_id
  orders_security_group_id   = local.security_groups_active ? aws_security_group.orders.id : module.retail_app_eks.node_security_group_id
  checkout_security_group_id = local.security_groups_active ? aws_security_group.checkout.id : module.retail_app_eks.node_security_group_id
}

resource "aws_security_group" "catalog" {
  name        = "${var.environment_name}-catalog"
  description = "Security group for catalog component"
  vpc_id      = module.vpc.inner.vpc_id

  ingress {
    description = "Allow inbound HTTP API traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [module.vpc.inner.vpc_cidr_block]
  }

  ingress {
    description = "Allow inbound Istio healthchecks"
    from_port   = 15020
    to_port     = 15021
    protocol    = "tcp"
    cidr_blocks = [module.vpc.inner.vpc_cidr_block]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "orders" {
  name        = "${var.environment_name}-orders"
  description = "Security group for orders component"
  vpc_id      = module.vpc.inner.vpc_id

  ingress {
    description = "Allow inbound HTTP API traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [module.vpc.inner.vpc_cidr_block]
  }

  ingress {
    description = "Allow inbound Istio healthchecks"
    from_port   = 15020
    to_port     = 15021
    protocol    = "tcp"
    cidr_blocks = [module.vpc.inner.vpc_cidr_block]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "checkout" {
  name        = "${var.environment_name}-checkout"
  description = "Security group for checkout component"
  vpc_id      = module.vpc.inner.vpc_id

  ingress {
    description = "Allow inbound HTTP API traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [module.vpc.inner.vpc_cidr_block]
  }

  ingress {
    description = "Allow inbound Istio healthchecks"
    from_port   = 15020
    to_port     = 15021
    protocol    = "tcp"
    cidr_blocks = [module.vpc.inner.vpc_cidr_block]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}
