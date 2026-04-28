######################################################## Security Groups, ECR, IAM Roles, ALB, RDS, ECS Cluster and Service
#  Application Load balancer Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB security group"
  vpc_id      = module.project1-vpc.vpc_id

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
    Name = "${var.project_name}-alb-sg"
  })
}


# ECS EC2 instance Security Group

resource "aws_security_group" "ecs_instance" {
  name        = "${var.project_name}-ecs-instance-sg"
  description = "ECS EC2 instance security group"
  vpc_id      = module.project1-vpc.vpc_id
  
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-ecs-instance-sg"
  })
}


# ECS Task Security Group

resource "aws_security_group" "ecs_task" {
  name        = "${var.project_name}-ecs-task-sg"
  description = "ECS task security group"
  vpc_id      = module.project1-vpc.vpc_id

  ingress {
    description     = "App traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }


  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-ecs-task-sg"
  })
}


#####################################################################  ECR Repository

# ECR Repository for application images
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-app"
  })
}

# ECS lifecycle policy

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


# EC2 IAM Instance Role

resource "aws_iam_role" "ecs_instance" {
  name = "${var.project_name}-ecs-instance-role"

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
# Attach Amazon EC2 container Service for EC2 Role
resource "aws_iam_role_policy_attachment" "ecs_instance_ecs" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
# Attach EC2 Container Registry Full Access for image pulling # I can limit this later for tighter access control
resource "aws_iam_role_policy_attachment" "ecs_instance_ecr" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
# Create Instance Profile for EC2 instances to use that assumes all the policies above
resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.project_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}
# Attach SSM Core Policy for managing the instances
resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}
# Attach AmazonECSTaskExecutionRolePolicy for ECS to pull images and write logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution_default" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# ECS Task Role - for application permissions (currently empty but can be expanded later)
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}



##################################################################  ALB
##################################################################
# Create Application Load Balancer in public subnets
resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [
    module.project1-public-subnet.subnet_id, module.project1-public-subnet2.subnet_id
  ]

  enable_deletion_protection = false

  tags = merge(local.tags, {
    Name = "${var.project_name}-alb"
  })
}
# Create Target Group for ECS tasks
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.project1-vpc.vpc_id

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
    Name = "${var.project_name}-tg"
  })
}
# Create ALB Listener for HTTP traffic on port 80 and forward to target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = local.tags
}







#################################################   ECS CLUSTER AND SERVICE
# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = merge(local.tags, {
    Name = "${var.project_name}-cluster"
  })
}


# ECS Launch Template for EC2 Instances in the cluster - using user data to bootstrap with Docker, ECS agent and pull app image from ECR
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project_name}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  vpc_security_group_ids = [aws_security_group.ecs_instance.id]

  user_data = base64encode(templatefile("${path.module}/templates/ecs_user_data.sh.tftpl", {
    cluster_name                = aws_ecs_cluster.main.name
    region                      = var.aws_region
    ecr_registry                = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com"
    ecr_repository_name         = aws_ecr_repository.app.name
    ecr_repository_url          = aws_ecr_repository.app.repository_url
    image_tag                   = var.image_tag
  }))

  monitoring {
    enabled = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.tags, {
      Name = "ecs-instance${var.project_name}"
    })
  }

  tags = local.tags
}
# enables the ecs cluster to automatically scale based on the metric "CPUUtilization" of the cluster and adds instances to the cluster as needed to maintain the desired capacity of the cluster
resource "aws_autoscaling_group" "ecs" {
  name                = "${var.project_name}-ecs-asg1"
  desired_capacity    = var.ecs_instance_desired
  min_size            = var.ecs_instance_min
  max_size            = var.ecs_instance_max
  vpc_zone_identifier = [module.project1-private-subnet.subnet_id,module.project1-public-subnet.subnet_id]
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = local.tags
}

# Capacity Provider for the ECS cluster
resource "aws_ecs_capacity_provider" "ecs" {
  name = "capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 10
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }
}
# Attach the capacity Provder to the ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.ecs.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs.name
    weight            = 1
    base              = 1
  }
}

# ECS Task Definition   Blueprint for the ECS Instances
resource "aws_ecs_task_definition" "app" {
  count = var.enable_ecs_service ? 1 : 0
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
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
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])

  tags = local.tags
}
# ECS Service, this runs your task definition as a container on whatever infrastructure you decide.
resource "aws_ecs_service" "app" {
  count = var.enable_ecs_service ? 1 : 0

  name                               = "${var.project_name}-service1"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.app[0].arn
  desired_count                      = 1
  health_check_grace_period_seconds  = 60
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200
  capacity_provider_strategy {
  capacity_provider = aws_ecs_capacity_provider.ecs.name
  weight            = 1
  base              = 1
}

  network_configuration {
    subnets          = [module.project1-private-subnet.subnet_id]
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_autoscaling_group.ecs,
    aws_ecs_cluster_capacity_providers.main,

    aws_security_group_rule.db_mysql_from_ecs_task,
    aws_route.vpc_2_to_vpc_1,
    aws_route.vpc_1_to_vpc_2
  ]

  tags = local.tags
  
}


#######################################       ec2 instance role and policies
# EC2 Instance for My ECS Cluster - using user data to bootstrap with Docker, ECS agent and pull app image from ECR
# resource "aws_instance" "ecs_container_instance" {
#   count = var.enable_ecs_instance ? 1 : 0

#   ami                    = data.aws_ssm_parameter.ecs_optimized_ami.value
#   instance_type          = var.instance_type
#   subnet_id              = module.project1-private-subnet.subnet_id
#   vpc_security_group_ids = [aws_security_group.ecs_instance.id]
#   iam_instance_profile   = aws_iam_instance_profile.ecs_instance.name
#   key_name               = var.key_name

#   user_data = templatefile("${path.module}/templates/ecs_user_data.sh.tftpl", {
#     cluster_name                = aws_ecs_cluster.main.name
#     enable_bootstrap_image_push = tostring(var.enable_bootstrap_image_push)
#     app_git_repo_url            = var.app_git_repo_url
#     region                      = var.aws_region
#     ecr_registry                = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com"
#     ecr_repository_name         = aws_ecr_repository.app.name
#     ecr_repository_url          = aws_ecr_repository.app.repository_url
#     image_tag                   = var.image_tag
#   })

#   metadata_options {
#     http_tokens = "required"
#   }

#   tags = merge(local.tags, {
#     Name = "${var.project_name}-ecs-instance"
#   }) 
#   depends_on = [ aws_ecr_repository.app, aws_ecs_cluster.main ]
# }