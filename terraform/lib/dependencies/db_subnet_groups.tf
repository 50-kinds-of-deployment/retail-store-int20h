resource "aws_db_subnet_group" "catalog" {
  count = var.enable_rds ? 1 : 0

  name       = "${var.environment_name}-catalog-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.environment_name}-catalog-subnet" })
}

resource "aws_db_subnet_group" "orders" {
  count = var.enable_rds ? 1 : 0

  name       = "${var.environment_name}-orders-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.environment_name}-orders-subnet" })
}
