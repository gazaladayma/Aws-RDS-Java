# Existing MySQL database. Import this resource before applying changes.
resource "aws_db_instance" "java_app" {
  identifier     = "java-app-rds"
  engine         = "mysql"
  engine_version = "8.4.9"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  storage_type          = "gp2"
  storage_encrypted     = true
  max_allocated_storage = 1000
  copy_tags_to_snapshot = true

  db_name  = null
  username = var.db_username
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.java_app.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az                   = false
  publicly_accessible        = false
  backup_retention_period    = 1
  auto_minor_version_upgrade = true

  parameter_group_name = "default.mysql8.4"
  option_group_name    = "default:mysql-8-4"

  deletion_protection = false
  skip_final_snapshot = true

  lifecycle {
    prevent_destroy = true
  }
}
