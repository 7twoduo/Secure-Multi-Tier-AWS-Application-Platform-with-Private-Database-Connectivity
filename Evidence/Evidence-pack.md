# Evidence Pack

## Project

**Secure Multi-Tier AWS Application Platform with Private Database Connectivity**

## Purpose

This evidence pack documents the **final working state** of the AWS infrastructure and application stack.

It proves that the project was deployed, validated, and operational across the following layers:

- AWS networking
- VPC peering
- private routing
- security groups
- ECS on EC2
- standalone EC2 application hosting
- Application Load Balancers
- private RDS MySQL connectivity
- Terraform-based deployment

---

## Final Architecture Summary

```text
User
  ↓
Application Load Balancer
  ↓
Private Application Workload
  ├── ECS on EC2 Dockerized Flask App
  └── Standalone EC2 Flask App
  ↓
VPC Peering
  ↓
Private RDS MySQL Database
```

The architecture uses public Application Load Balancers as the entry points while keeping application workloads and the database in private subnets. The application layers connect to the private RDS database through VPC peering and controlled security group rules.

---

# 1. Architecture Evidence

## Architecture Diagram

This diagram shows the full application flow across the ALB layer, private compute layer, VPC peering path, and private RDS database.

![Architecture Diagram](./01-architecture/architecture-diagram.png)

---

# 2. Networking Evidence

## VPC List

This screenshot shows the VPCs used in the project.

Expected VPC layout:

| VPC | Purpose | CIDR |
|---|---|---|
| Project 1 VPC | ECS on EC2 application workload | `10.40.0.0/16` |
| Project 2 VPC | Private RDS database hub | `10.80.0.0/16` |
| Project 3 VPC | Standalone EC2 application workload | `10.120.0.0/16` |

![VPC List](./02-networking/vpc-list.png)

---

## Subnet List

This screenshot shows the public and private subnet layout used by the project.

The public subnets support the Application Load Balancers. The private subnets support ECS, EC2 application workloads, and the RDS database.

![Subnet List](./02-networking/project1-vpc-subnet.png)(./02-networking/project2-vpc-subnet.png)(./02-networking/project3-vpc-subnet.png)

---

## VPC Peering Active

This screenshot shows that the VPC peering connections are active.

Expected peering relationships:

| Peering Path | Purpose |
|---|---|
| Project 1 VPC ↔ Project 2 VPC | ECS application to RDS database |
| Project 3 VPC ↔ Project 2 VPC | EC2 application to RDS database |

![VPC Peering Active](./02-networking/vpc-peering-active.png)

---

## Project 1 Private Route Table

This screenshot shows the private route table for the ECS application VPC.

Expected routing behavior:

```text
Project 1 private subnet
  → Project 2 database VPC through VPC peering
  → Internet-bound traffic through NAT Gateway
```

![Project 1 Private Route Table](./02-networking/project1-private-route-table.png)

---

## Project 2 Private Route Table

This screenshot shows the private route table for the database VPC.

Expected routing behavior:

```text
Project 2 database VPC
  → Project 1 ECS VPC through VPC peering
  → Project 3 EC2 app VPC through VPC peering
```

This return routing is required so RDS can respond to application traffic from both application VPCs.

![Project 2 Private Route Table](./02-networking/project2-private-route-table.png)

---

## Project 3 Private Route Table

This screenshot shows the private route table for the standalone EC2 application VPC.

Expected routing behavior:

```text
Project 3 private subnet
  → Project 2 database VPC through VPC peering
  → Internet-bound traffic through NAT Gateway
```

![Project 3 Private Route Table](./02-networking/project3-private-route-table.png)

---

# 3. Security Evidence

## ALB Security Group

This screenshot shows the security group used by the public Application Load Balancer.

Expected behavior:

```text
Internet → ALB on HTTP port 80
ALB → private application targets
```

![ALB Security Group](./03-security/alb-security-group.png)

---

## ECS Task Security Group

This screenshot shows the security group attached to ECS tasks.

Expected behavior:

```text
ALB security group → ECS task security group on application port
ECS task security group → RDS security group on MySQL port 3306
```

![ECS Task Security Group](./03-security/ecs-task-security-group.png)

---

## EC2 App Security Group

This screenshot shows the security group attached to the standalone EC2 application instance.

Expected behavior:

```text
ALB security group → EC2 app security group on application port 8080
EC2 app security group → RDS security group on MySQL port 3306
```

![EC2 App Security Group](./03-security/ec2-app-security-group.png)

---

## Database Security Group

This screenshot shows the security group attached to the private RDS MySQL database.

Expected behavior:

```text
ECS task security group → DB security group on 3306
EC2 app security group → DB security group on 3306
```

The database should not allow broad public access in the final working state.

![Database Security Group](./03-security/database-security-group.png)

---

# 4. Database Evidence

## RDS Instance Running

This screenshot shows the RDS MySQL database in an available/running state.

![RDS Instance Running](./04-database/rds-instance-running.png)

---

## RDS Private Endpoint

This screenshot shows the RDS endpoint used by the application workloads.

The endpoint is reached privately from the application VPCs through VPC peering.

![RDS Private Endpoint](./04-database/rds-private-endpoint.png)

---

## RDS Subnet Group

This screenshot shows the RDS subnet group used for database placement.

Expected behavior:

```text
RDS is deployed in private database subnets.
Application workloads reach RDS through private routing.
```

![RDS Subnet Group](./04-database/rds-subnet-group.png)

---

# 5. ECS on EC2 Evidence

## ECS Cluster Active

This screenshot shows the ECS cluster created for the Dockerized Flask application.

![ECS Cluster Active](./05-ecs-on-ec2/ecs-cluster-active.png)

---

## ECS Container Instance Registered

This screenshot shows the EC2 container instance registered to the ECS cluster.

This proves the ECS agent successfully joined the cluster and can accept ECS task placement.

![ECS Container Instance Registered](./05-ecs-on-ec2/ecs-container-instance-registered.png)

---

## ECS Service Running

This screenshot shows the ECS service running and maintaining the desired task count.

![ECS Service Running](./05-ecs-on-ec2/ecs-service-running.png)

---

## ECS Task Running

This screenshot shows the ECS task in a running state.

![ECS Task Running](./05-ecs-on-ec2/ecs-task-running.png)

---

## ECS Task Networking

This screenshot shows the ECS task networking details.

Important evidence to capture:

- task ENI
- private subnet
- task security group
- private IP
- container status

![ECS Task Networking](./05-ecs-on-ec2/ecs-task-networking.png)

---

# 6. EC2 App Evidence

## EC2 Instance Running

This screenshot shows the standalone EC2 application instance in a running state.

![EC2 Instance Running](./06-ec2-app/ec2-instance-running.png)

---

## SSM Session Connected

This screenshot shows successful private access to the EC2 instance through AWS Systems Manager Session Manager.

This proves the instance can be managed without public SSH exposure.

![SSM Session Connected](./06-ec2-app/ssm-session-connected.png)

---

## systemd Service Running

This screenshot shows the Flask application running as a systemd service.

Expected status:

```text
Active: active (running)
```

![systemd Service Running](./06-ec2-app/systemd-service-running.png)

---

## App Listening on Port 8080

This screenshot shows the Flask/Gunicorn application listening on port `8080`.

Expected result:

```text
0.0.0.0:8080
```

This confirms the ALB can reach the application target on the correct port.

![App Listening on 8080](./06-ec2-app/app-listening-on-8080.png)

---

# 7. Load Balancer Evidence

## ECS ALB Active

This screenshot shows the Application Load Balancer used for the ECS application path.

![ECS ALB Active](./07-load-balancers/ecs-alb-active.png)

---

## ECS Target Group Healthy

This screenshot shows the ECS task registered as a healthy ALB target.

Expected status:

```text
Healthy
```

![ECS Target Group Healthy](./07-load-balancers/ecs-target-group-healthy.png)

---

## EC2 ALB Active

This screenshot shows the Application Load Balancer used for the standalone EC2 application path.

![EC2 ALB Active](./07-load-balancers/ec2-alb-active.png)

---

## EC2 Target Group Healthy

This screenshot shows the EC2 application instance registered as a healthy ALB target.

Expected status:

```text
Healthy
```

![EC2 Target Group Healthy](./07-load-balancers/ec2-target-group-healthy.png)

---

# 8. Application Validation Evidence

## ECS Dashboard

This screenshot shows the ECS-hosted application dashboard loading successfully through the ALB.

![ECS Dashboard](./08-application-validation/ecs-dashboard.png)

---

## ECS Health Check Success

This screenshot shows the ECS `/health` route returning a successful response.

Expected result:

```json
{
  "status": "ok"
}
```

![ECS Health Success](./08-application-validation/ecs-health-success.png)

---

## ECS Database Check Success

This screenshot shows the ECS `/dbcheck` route successfully connecting to the private RDS MySQL database.

Expected result:

```json
{
  "status": "connected"
}
```

![ECS DB Check Success](./08-application-validation/ecs-dbcheck-success.png)

---

## EC2 Dashboard

This screenshot shows the standalone EC2-hosted application dashboard loading successfully through the ALB.

![EC2 Dashboard](./08-application-validation/ec2-dashboard.png)

---

## EC2 Health Check Success

This screenshot shows the EC2 `/health` route returning a successful response.

Expected result:

```json
{
  "status": "ok"
}
```

![EC2 Health Success](./08-application-validation/ec2-health-success.png)

---

## EC2 Database Check Success

This screenshot shows the EC2 `/dbcheck` route successfully connecting to the private RDS MySQL database.

Expected result:

```json
{
  "status": "connected"
}
```

![EC2 DB Check Success](./08-application-validation/ec2-dbcheck-success.png)

---

# 9. ECR Evidence

## ECR Repository

This screenshot shows the ECR repository used to store the Docker image for the ECS application.

![ECR Repository](./09-ecr/ecr-repository.png)

---

## ECR Image Tag

This screenshot shows the Docker image tag pushed to ECR and used by the ECS task definition.

![ECR Image Tag](./09-ecr/ecr-image-tag.png)

---

# 10. Terraform Evidence

## Terraform Init Success

This screenshot shows Terraform initialization completed successfully.

![Terraform Init Success](./10-terraform/terraform-init-success.png)

---

## Terraform Apply Success

This screenshot shows Terraform successfully applied the infrastructure.

![Terraform Apply Success](./10-terraform/terraform-apply-success.png)

---

## Terraform Outputs

This screenshot shows useful Terraform outputs such as ALB DNS names, VPC IDs, subnet IDs, security group IDs, and RDS endpoint.

![Terraform Outputs](./10-terraform/terraform-outputs.png)

---

# Final Working-State Checklist

| Area | Evidence File | Status |
|---|---|---|
| Architecture diagram | `01-architecture/architecture-diagram.png` | Complete |
| VPCs created | `02-networking/vpc-list.png` | Complete |
| Subnets created | `02-networking/subnet-list.png` | Complete |
| VPC peering active | `02-networking/vpc-peering-active.png` | Complete |
| Project 1 private routing | `02-networking/project1-private-route-table.png` | Complete |
| Project 2 private routing | `02-networking/project2-private-route-table.png` | Complete |
| Project 3 private routing | `02-networking/project3-private-route-table.png` | Complete |
| ALB security group configured | `03-security/alb-security-group.png` | Complete |
| ECS task security group configured | `03-security/ecs-task-security-group.png` | Complete |
| EC2 app security group configured | `03-security/ec2-app-security-group.png` | Complete |
| DB security group configured | `03-security/database-security-group.png` | Complete |
| RDS running privately | `04-database/rds-instance-running.png` | Complete |
| ECS cluster active | `05-ecs-on-ec2/ecs-cluster-active.png` | Complete |
| ECS task running | `05-ecs-on-ec2/ecs-task-running.png` | Complete |
| EC2 app instance running | `06-ec2-app/ec2-instance-running.png` | Complete |
| EC2 app service running | `06-ec2-app/systemd-service-running.png` | Complete |
| App listening on 8080 | `06-ec2-app/app-listening-on-8080.png` | Complete |
| ECS ALB target healthy | `07-load-balancers/ecs-target-group-healthy.png` | Complete |
| EC2 ALB target healthy | `07-load-balancers/ec2-target-group-healthy.png` | Complete |
| ECS dashboard loads | `08-application-validation/ecs-dashboard.png` | Complete |
| ECS `/dbcheck` works | `08-application-validation/ecs-dbcheck-success.png` | Complete |
| EC2 dashboard loads | `08-application-validation/ec2-dashboard.png` | Complete |
| EC2 `/dbcheck` works | `08-application-validation/ec2-dbcheck-success.png` | Complete |
| ECR image exists | `09-ecr/ecr-image-tag.png` | Complete |
| Terraform apply succeeds | `10-terraform/terraform-apply-success.png` | Complete |

---

# Evidence Summary

This evidence pack confirms that the project reached a working final state.

The completed architecture demonstrates:

- public ALB access to private application workloads
- ECS on EC2 containerized deployment
- standalone EC2 application deployment
- private RDS MySQL database connectivity
- VPC peering between application and database networks
- security group-controlled database access
- SSM-based private instance access
- Terraform-managed infrastructure deployment
- working application validation through `/health` and `/dbcheck`

The key proof point is that both application paths can reach the private RDS database successfully without exposing the database publicly.

```text
ECS App → VPC Peering → RDS MySQL = Working
EC2 App → VPC Peering → RDS MySQL = Working
```