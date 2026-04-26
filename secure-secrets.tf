
# Future Improvement, use secrets manager to store secrets, I'll do it another day.

/*
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/rds/mysql/app-runtime"
  description             = "Runtime database username and password for app workloads"
  recovery_window_in_days = 0

  tags = merge(local.tags, {
    Name = "${var.project_name}-db-runtime-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
  })
}

data "aws_iam_policy_document" "db_secret_runtime_read" {
  statement {
    sid    = "ReadOnlyDatabaseRuntimeSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      aws_secretsmanager_secret.db_credentials.arn
    ]
  }
}

resource "aws_iam_policy" "db_secret_runtime_read" {
  name        = "${var.project_name}-db-secret-runtime-read"
  description = "Allow app workloads to read only the DB runtime credential secret"
  policy      = data.aws_iam_policy_document.db_secret_runtime_read.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ec2_app_db_secret_runtime_read" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = aws_iam_policy.db_secret_runtime_read.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_db_secret_runtime_read" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.db_secret_runtime_read.arn
}

user_data = templatefile("${path.module}/templates/ec2_app_user_data.sh.tftpl", {
  app_port      = var.app_port
  aws_region    = var.aws_region
  db_host       = aws_db_instance.mysql.address
  db_port       = 3306
  db_name       = var.db_name
  db_secret_arn = aws_secretsmanager_secret.db_credentials.arn
})






environment = [
  {
    name  = "AWS_REGION"
    value = var.aws_region
  },
  {
    name  = "DB_HOST"
    value = aws_db_instance.mysql.address
  },
  {
    name  = "DB_PORT"
    value = "3306"
  },
  {
    name  = "DB_NAME"
    value = var.db_name
  },
  {
    name  = "DB_SECRET_ARN"
    value = aws_secretsmanager_secret.db_credentials.arn
  }
]
*/


