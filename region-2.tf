# Database Security Group

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "MySQL DB security group"
  vpc_id      = module.project2-vpc.vpc_id

  ingress {
    description     = "MySQL from ECS EC2 instance for SSM testing"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_instance.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-db-sg"
  })
}
resource "aws_security_group_rule" "db_mysql_from_ecs_task" {
  type                     = "ingress"
  description              = "MySQL from ECS task SG over VPC peering"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ecs_task.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  depends_on = [ aws_vpc_peering_connection.vpc_2_to_vpc_1 ]
}

resource "aws_security_group_rule" "db_mysql_from_ec2" {
  type                     = "ingress"
  description              = "MySQL from ECS task SG over VPC peering"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ec2_app.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  depends_on = [ aws_vpc_peering_connection.vpc_2_to_vpc_3 ]
}

# Create DB Subnet Group for RDS to use private subnets
resource "aws_db_subnet_group" "mysql" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = [module.project2-private-subnet.subnet_id , module.project2-private-subnet2.subnet_id]

  tags = merge(local.tags, {
    Name = "${var.project_name}-db-subnets"
  })
}

############################################### DATABASE

# MySQL RDS Instance
resource "aws_db_instance" "mysql" {
  identifier             = "${var.project_name}-mysql"
  engine                 = "mysql"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  backup_retention_period = 0
  apply_immediately      = true

  tags = merge(local.tags, {
    Name = "${var.project_name}-mysql"
  })
}