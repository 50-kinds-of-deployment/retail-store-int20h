module "catalog_rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  depends_on = [aws_db_subnet_group.catalog]

  identifier           = "${var.environment_name}-catalog"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  engine               = "mysql"
  engine_version       = "8.0.40"
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  storage_type          = "gp2"

  db_name                     = "catalog"
  username                    = "catalyst"
  password                    = random_string.catalog_db_master.result
  port                        = 3306
  manage_master_user_password = false
  vpc_security_group_ids      = [var.catalog_security_group_id]
  db_subnet_group_name        = "${var.environment_name}-catalog-subnet"
  publicly_accessible         = false
  skip_final_snapshot         = true
  backup_retention_period     = 1
  backup_window               = "03:00-04:00"
  maintenance_window          = "mon:04:00-mon:05:00"
  apply_immediately           = true
  multi_az                    = false

  tags = var.tags
}

resource "random_string" "catalog_db_master" {
  length  = 10
  special = false
}

resource "aws_secretsmanager_secret" "catalog_db_credentials" {
  name        = "${var.environment_name}-catalog-db-credentials"
  description = "Credentials for the Catalog database"

  recovery_window_in_days = 0 # Force deletion without recovery to ease destruction 
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "catalog_db_credentials" {
  secret_id = aws_secretsmanager_secret.catalog_db_credentials.id
  secret_string = jsonencode({
    username = "catalyst"
    password = random_string.catalog_db_master.result
    host     = module.catalog_rds.db_instance_endpoint
    port     = 3306
  })
}
