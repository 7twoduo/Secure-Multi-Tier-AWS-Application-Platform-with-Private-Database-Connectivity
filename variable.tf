locals{
    tags = {
        Environment = "Production"
        Project     = "NetworkingProject"
    }
}
variable "aws_region" {
  description = "AWS Region to deploy resources in"
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  description = "The Project Name"
  type    = string
  default = "multi-vpc-peering"
}
###########################################         Database
###  Database Name
variable "db_name" {
  type    = string
  default = "labdb"
}

variable "db_username" {
  type    = string
  default = "labuser"
}

variable "db_password" {
  type      = string
  sensitive = true
  default = "jinosino22kisko"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

##################################### Container and ECS Variables #####################################


variable "container_port" {
  type    = number
  default = 8080
}

variable "image_tag" {
  type    = string
  default = "v1"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ecs_instance_desired" {
  type    = number
  default = 1
}

variable "ecs_instance_min" {
  type    = number
  default = 1
}

variable "ecs_instance_max" {
  type    = number
  default = 1
}

variable "app_port" {
  type    = number
  default = 8080
}










variable "key_name" {
  type    = string
  default = null
}




data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}