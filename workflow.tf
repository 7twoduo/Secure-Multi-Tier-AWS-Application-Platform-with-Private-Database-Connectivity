######################################        CONTROLS TO TURN ON/OFF ECS SERVICE AND BOOTSTRAP IMAGE PUSH TO ECR

variable "enable_ecs_instance" {
  description = "This is to turn on EC2 on ECS Cluster so that the image builds."
  type    = bool
  default = true
}


variable "enable_ecs_service" {
  description = "This is to turn on ecs service which is a load balancer for ecr service."
  type    = bool
  default = false
}
