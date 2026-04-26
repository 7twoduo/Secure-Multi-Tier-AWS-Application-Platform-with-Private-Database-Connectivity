##           EC2 TO THE DATABASE FROM VPC 3 TO VPC 2 THROUGH VPC PEERING

########################################################
# Security Groups
########################################################

resource "aws_security_group" "ec2_alb" {
  name        = "${var.project_name}-ec2-alb-sg"
  description = "ALB security group"
  vpc_id      = module.project3-vpc.vpc_id # PLACEHOLDER: app VPC

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-ec2-alb-sg"
  })
}
# EC2 Security Group for EC2 App Instances
resource "aws_security_group" "ec2_app" {
  name        = "${var.project_name}-ec2-app-sg"
  description = "EC2 app instance security group"
  vpc_id      = module.project3-vpc.vpc_id # PLACEHOLDER: app VPC

  ingress {
    description     = "App traffic from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound from EC2 app"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-ec2-app-sg"
  })
}


# Iam role for ec2 instance profile
resource "aws_iam_role" "ec2_app" {
  name = "${var.project_name}-ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}
# Iam SSM instance Core
resource "aws_iam_role_policy_attachment" "ec2_app_ssm" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# IAM role for ec2 instance profile
resource "aws_iam_instance_profile" "ec2_app" {
  name = "${var.project_name}-ec2-app-instance-profile"
  role = aws_iam_role.ec2_app.name
}

# Application Load Balancer for EC2
resource "aws_lb" "ec2_app" {
  name               = "EC2-ALB-${var.project_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_alb.id]

  subnets = [
    module.project3-public-subnet.subnet_id,
    module.project3-public-subnet2.subnet_id
  ] 

  enable_deletion_protection = false

  tags = merge(local.tags, {
    Name = "${var.project_name}-ec2-alb"
  })
}

resource "aws_lb_target_group" "ec2_app" {
  name        = "${var.project_name}-ec2-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.project3-vpc.vpc_id # PLACEHOLDER: app VPC

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-ec2-tg"
  })
}

resource "aws_lb_listener" "ec2_http" {
  load_balancer_arn = aws_lb.ec2_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_app.arn
  }

  tags = local.tags
}


resource "aws_instance" "ec2_app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = module.project3-private-subnet.subnet_id # PLACEHOLDER: private app subnet
  vpc_security_group_ids = [aws_security_group.ec2_app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_app.name

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/templates/ec2_app_user_data.sh.tftpl", {
    app_port        = var.app_port
    db_host         = aws_db_instance.mysql.address
    db_port         = 3306
    db_name         = var.db_name
    db_user         = var.db_username
    db_password_b64 = base64encode(var.db_password)
  })

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(local.tags, {
    Name = "ec2-app${var.project_name}"
  })
}

resource "aws_lb_target_group_attachment" "ec2_app" {
  target_group_arn = aws_lb_target_group.ec2_app.arn
  target_id        = aws_instance.ec2_app.id
  port             = var.app_port
}


