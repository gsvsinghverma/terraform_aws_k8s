resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}/database/credentials"
  description = "RDS PostgreSQL credentials"
  tags        = { Name = "${var.project_name}-db-secret", Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "postgres"
    password = var.db_password
    host     = var.rds_endpoint
    port     = "5432"
    dbname   = var.db_name
  })
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.project_name}/app/secrets"
  description = "Application secrets"
  tags        = { Name = "${var.project_name}-app-secret" }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    jwt_secret    = "change-this-in-production"
    app_key       = "change-this-in-production"
  })
}
