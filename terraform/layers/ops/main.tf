data "terraform_remote_state" "bootstrap" {
  backend = "s3"

  config = {
    bucket = "retail-store-tf-state-eu-central-1"
    key    = "stage/bootstrap/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  security_groups_active = !var.opentelemetry_enabled
  tags                   = data.terraform_remote_state.bootstrap.outputs.tags
}

module "vpc" {
  source = "../../lib/vpc"

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
  source = "../../lib/eks"

  providers = {
    kubernetes.cluster = kubernetes.cluster
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

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = module.retail_app_eks.name
  addon_name   = "aws-ebs-csi-driver"
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name = module.retail_app_eks.name
  addon_name   = "metrics-server"
}



module "dependencies" {
  source = "../../lib/dependencies"

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

  ingress {
    description = "Allow inbound MySQL traffic"
    from_port   = 3306
    to_port     = 3306
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

  ingress {
    description = "Allow inbound PostgreSQL traffic"
    from_port   = 5432
    to_port     = 5432
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

  ingress {
    description = "Allow all TCP from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description     = "Allow traffic from UI"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.ui.id]
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

resource "aws_security_group" "ui" {
  name        = "${var.environment_name}-ui"
  description = "Security group for ui component"
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
