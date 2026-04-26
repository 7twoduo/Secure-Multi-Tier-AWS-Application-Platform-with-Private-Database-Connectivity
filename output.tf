output "ecr_name" {
  value = aws_ecr_repository.app.name
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = try(aws_ecs_service.app[0].name, null)
}

output "db_endpoint" {
  value = aws_db_instance.mysql.address
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "load_balancer_for_ecs" {
  value = aws_lb.app.dns_name
}

output "load_balancer_for_ec2" {
  value = aws_lb.ec2_app.dns_name
}
