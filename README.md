<div align="center">

# 🔗 Secure Multi-Tier AWS Application Platform with Private Database Connectivity

**Production-inspired AWS networking project with VPC peering, ALB, EC2, ECS on EC2, Flask, Docker, Terraform, and RDS MySQL**

<br/>


<br/>
<br/>

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Amazon VPC](https://img.shields.io/badge/Amazon%20VPC-Networking-0EA5E9?style=for-the-badge)
![VPC Peering](https://img.shields.io/badge/VPC%20Peering-Private%20Connectivity-2563EB?style=for-the-badge)
![Application Load Balancer](https://img.shields.io/badge/Application%20Load%20Balancer-8C4FFF?style=for-the-badge)
![EC2](https://img.shields.io/badge/EC2-Compute-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![ECS](https://img.shields.io/badge/ECS%20on%20EC2-Containers-FF9900?style=for-the-badge&logo=amazonecs&logoColor=white)
![RDS](https://img.shields.io/badge/RDS%20MySQL-Database-527FFF?style=for-the-badge&logo=amazonrds&logoColor=white)
![Python](https://img.shields.io/badge/Python-Flask-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerized%20App-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![SSM](https://img.shields.io/badge/SSM-Private%20Access-16A34A?style=for-the-badge)
![Security Groups](https://img.shields.io/badge/Security%20Groups-Stateful%20Firewall-16A34A?style=for-the-badge)
![Infrastructure as Code](https://img.shields.io/badge/Infrastructure%20as%20Code-Automated-4F46E5?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production%20Inspired-success?style=for-the-badge)

</div>

---

## 📌 Overview

This project builds a **multi-VPC AWS application architecture** where application workloads in separate VPCs connect privately to a centralized RDS MySQL database through **VPC peering**.

The project includes two compute patterns:

1. **ECS on EC2** running a Dockerized Flask application.
2. **Standalone EC2** running a Flask application through user data and systemd.

Both application paths are placed behind Application Load Balancers and connect to a private MySQL database in a separate VPC.

The goal of this project is to demonstrate real AWS networking, private database connectivity, security group design, ALB troubleshooting, ECS on EC2 behavior, user-data bootstrapping, and Infrastructure as Code with Terraform.

---

## 🧠 Problem Statement

Many cloud environments separate applications and databases into different networks for security, isolation, and operational control.

However, this creates real engineering challenges:

- How do applications in one VPC privately reach a database in another VPC?
- How do security groups behave across VPC peering?
- How do ALBs forward traffic to private compute?
- How do ECS tasks differ from EC2 instances when connecting to databases?
- How do you troubleshoot timeouts, failed health checks, and container startup issues?
- How do you build this repeatably with Terraform?

This project answers those questions through a working AWS implementation.

---

## 🎯 Project Objective

Build a production-inspired AWS lab where:

- public users access applications through ALBs
- application workloads run privately
- database access stays private
- RDS is isolated in a separate VPC
- VPC peering enables private cross-VPC communication
- security groups control application-to-database access
- ECS and EC2 compute patterns are both tested
- Terraform provisions the environment repeatably

---

## 🏗️ Architecture Diagram

> Save your architecture image as:
>
> `Evidence/architecture-diagram.png`

<img width="1200" alt="Architecture Diagram" src="./Evidence/architecture-diagram.png" />

---

## 🔄 Architecture Flow

This project has two application paths that both reach the same private RDS MySQL database through VPC peering.

```text
                         ┌──────────────────────────┐
                         │          Users           │
                         └─────────────┬────────────┘
                                       │
                                       ▼
                         ┌──────────────────────────┐
                         │ Application Load Balancer │
                         │        Public Subnet      │
                         └─────────────┬────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                     │
                    ▼                                     ▼
      ┌─────────────────────────────┐       ┌─────────────────────────────┐
      │ ECS on EC2 Flask App         │       │ Standalone EC2 Flask App     │
      │ Private Subnet               │       │ Private Subnet               │
      │ Dockerized App Runtime       │       │ User Data + systemd Runtime  │
      └──────────────┬──────────────┘       └──────────────┬──────────────┘
                     │                                     │
                     └──────────────────┬──────────────────┘
                                        │
                                        ▼
                         ┌──────────────────────────┐
                         │      VPC Peering          │
                         │  Private Cross-VPC Route  │
                         └─────────────┬────────────┘
                                       │
                                       ▼
                         ┌──────────────────────────┐
                         │ Private RDS MySQL Database│
                         │       Database VPC        │
                         └──────────────────────────┘
```
## 🧰 Technology Stack

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Cloud%20Provider-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Amazon%20VPC-Networking-0EA5E9?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Application%20Load%20Balancer-Traffic%20Routing-8C4FFF?style=for-the-badge" />
  <img src="https://img.shields.io/badge/ECS%20on%20EC2-Container%20Orchestration-FF9900?style=for-the-badge&logo=amazonecs&logoColor=white" />
  <img src="https://img.shields.io/badge/EC2-Compute-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white" />
  <img src="https://img.shields.io/badge/ECR-Container%20Registry-FF9900?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Python-Flask-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-Containers-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/RDS%20MySQL-Database-527FFF?style=for-the-badge&logo=amazonrds&logoColor=white" />
  <img src="https://img.shields.io/badge/SSM-Private%20Access-16A34A?style=for-the-badge" />
  <img src="https://img.shields.io/badge/IAM%20%2B%20Security%20Groups-Security-DC2626?style=for-the-badge" />
</p>

| Category | Technologies |
|---|---|
| **Cloud Provider** | AWS |
| **Infrastructure as Code** | Terraform |
| **Networking** | Amazon VPC, Public/Private Subnets, Route Tables, Internet Gateway, NAT Gateway, VPC Peering |
| **Load Balancing** | Application Load Balancer, Target Groups, Health Checks |
| **Compute Pattern 1** | Amazon ECS on EC2, Auto Scaling Group, Capacity Provider |
| **Compute Pattern 2** | Amazon EC2, User Data, systemd, Gunicorn |
| **Container Registry** | Amazon ECR |
| **Application Runtime** | Python, Flask, Gunicorn |
| **Containerization** | Docker |
| **Database** | Amazon RDS for MySQL |
| **Private Access** | AWS Systems Manager Session Manager |
| **Security** | IAM Roles, Security Groups, Private Subnets, Least-Privilege Network Access |
| **Logging & Troubleshooting** | CloudWatch Logs, systemd Journals, Docker Logs, ALB Target Health |

## ✨ What This Project Demonstrates

<table>
  <tr>
    <td align="center" width="25%">
      <h3>🌐 Multi-VPC Networking</h3>
      Designing and deploying multiple AWS VPCs with isolated application and database layers.
    </td>
    <td align="center" width="25%">
      <h3>🔗 VPC Peering</h3>
      Enabling private communication between separate VPCs without exposing internal traffic to the public internet.
    </td>
    <td align="center" width="25%">
      <h3>🗄️ Cross-VPC App-to-DB Connectivity</h3>
      Connecting application workloads in one VPC to an RDS MySQL database in another VPC.
    </td>
    <td align="center" width="25%">
      <h3>⚖️ Application Load Balancing</h3>
      Routing public HTTP traffic through ALBs to private compute resources securely and reliably.
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <h3>📦 ECS on EC2</h3>
      Running containerized Flask applications on Amazon ECS using EC2-backed capacity.
    </td>
    <td align="center" width="25%">
      <h3>🖥️ EC2 Bootstrapping</h3>
      Using EC2 user data and systemd to automatically configure and launch an application at boot time.
    </td>
    <td align="center" width="25%">
      <h3>🐳 Docker + ECR Workflow</h3>
      Building a Docker image locally, tagging it correctly, and pushing it to Amazon ECR for deployment.
    </td>
    <td align="center" width="25%">
      <h3>🛢️ Private RDS Access</h3>
      Keeping the database private while still allowing approved application traffic over internal AWS networking.
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <h3>🛡️ Security Group Design</h3>
      Using source-based security group rules to tightly control traffic between ALBs, app tiers, and the database.
    </td>
    <td align="center" width="25%">
      <h3>🧱 Terraform Dependency Management</h3>
      Handling resource ordering and cross-resource dependencies, especially around peering and security rules.
    </td>
    <td align="center" width="25%">
      <h3>🩺 ALB Health Check Troubleshooting</h3>
      Diagnosing failed health checks, target group issues, and port mismatches that caused 502 errors.
    </td>
    <td align="center" width="25%">
      <h3>🧰 Real Infrastructure Debugging</h3>
      Troubleshooting real issues across containers, ports, database access, networking, and runtime behavior.
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <h3>🔐 SSM-Based Private Access</h3>
      Accessing private EC2 instances securely through AWS Systems Manager instead of exposing SSH publicly.
    </td>
    <td align="center" width="25%">
      <h3>📊 End-to-End Validation</h3>
      Verifying the stack through <code>/health</code>, <code>/info</code>, and <code>/dbcheck</code> application routes.
    </td>
    <td align="center" width="25%">
      <h3>🏗️ Production-Inspired Design</h3>
      Combining networking, security, compute, and database patterns that reflect real-world cloud environments.
    </td>
    <td align="center" width="25%">
      <h3>🚀 Practical Cloud Engineering</h3>
      Showing not just deployment, but the ability to design, build, test, and fix a complete AWS solution.
    </td>
  </tr>
</table>


## ✅ What This Builds

### 🌐 Networking
- Separate VPCs for the application and database layers
- Public and private subnets for tiered network segmentation
- VPC peering routes for private app-to-database communication

### ⚖️ Load Balancing
- Application Load Balancers for routing external traffic to application workloads

### 📦 Containerized Application
- ECS cluster using EC2-backed capacity
- ECS capacity provider backed by an Auto Scaling Group
- ECS task definition and ECS service for the containerized Flask application
- Dockerized Flask application image pushed to Amazon ECR

### 🖥️ Standalone Application
- Standalone EC2 Flask application deployed through user data

### 🗄️ Database
- Private RDS MySQL database

### 🔐 Security
- Security groups for the ALB, app workloads, ECS tasks, EC2 instances, and database access

### 🛠️ Operations & Validation
- SSM access for private instance troubleshooting without public SSH
- Health check and database validation endpoints


## 🧱 Core AWS Resources

| AWS Resource | Purpose |
|---|---|
| **Amazon VPC** | Creates isolated network boundaries for application and database environments. |
| **Public Subnets** | Place internet-facing ALBs where users can reach them. |
| **Private Subnets** | Host ECS, EC2, and RDS resources without direct public exposure. |
| **VPC Peering** | Enables private cross-VPC communication between application and database networks. |
| **Application Load Balancer** | Routes public HTTP traffic to healthy private application targets. |
| **Amazon EC2** | Runs the standalone Flask app and ECS container instances. |
| **Amazon ECS** | Orchestrates the Dockerized Flask app on EC2-backed capacity. |
| **Amazon ECR** | Stores and serves the Docker image used by ECS. |
| **Amazon RDS for MySQL** | Provides the private managed MySQL database backend. |
| **IAM** | Grants EC2, ECS, ECR, SSM, and logging permissions. |
| **Security Groups** | Restrict traffic between ALB, app workloads, and database. |
| **Systems Manager** | Enables private instance access without SSH exposure. |
| **CloudWatch Logs** | Captures application, ECS, Docker, and system logs for troubleshooting. |

## 📂 Project Structure

```text
PROJECT 1/
├── app/                          # Flask application source code
│   ├── app.py                    # Flask API with health and DB validation endpoints
│   ├── Dockerfile                # Container image definition
│   └── requirements.txt          # Python dependencies
│
├── Evidence/                     # Project screenshots and validation proof
│   ├── Evidence.md               # Deployment notes and testing evidence
│   └── architecture-diagram.png  # Architecture diagram
│
├── modules/                      # Reusable Terraform modules
│   ├── subnet/
│   │   ├── main.tf               # Subnet resources
│   │   ├── output.tf             # Subnet outputs
│   │   └── variable.tf           # Subnet variables
│   │
│   └── vpc/
│       ├── main.tf               # VPC resources
│       ├── output.tf             # VPC outputs
│       └── variable.tf           # VPC variables
│
├── scripts/                      # Build and deployment automation
│   ├── build_and_push_ecr.sh     # Builds Docker image and pushes it to ECR
│   ├── build_everything.sh       # Runs the full build/deploy workflow
│   └── destroy_everything.sh     # Destroys deployed infrastructure
│
├── templates/                    # EC2 and ECS bootstrap templates
│   ├── ec2_app_user_data.sh.tftpl # User data for standalone EC2 Flask app
│   └── ecs_user_data.sh.tftpl     # User data for ECS container instances
│
├── main-networking.tf            # Core networking resources
├── region-1.tf                   # Primary region infrastructure
├── region-2.tf                   # Secondary region / additional infrastructure
├── region-3.tf                   # Tertiary region / additional infrastructure
├── workflow.tf                   # Deployment workflow resources
├── variable.tf                   # Terraform input variables
├── output.tf                     # Terraform outputs
├── .terraform.lock.hcl           # Terraform provider lock file
└── terraform.tfstate             # Local Terraform state file
```

## 🖥️ Application Routes

The application exposes a small set of routes that help validate each layer of the deployment: the web app, the load balancer, the runtime environment, and the database connection.

| Route | Method | What It Tests | Description |
|---|---:|---|---|
| `/` | `GET` | Frontend + app runtime | Loads the visual dashboard page for the ECS or EC2 version of the app. |
| `/health` | `GET` | ALB health check + app availability | Returns a lightweight health response used to confirm the app is reachable. |
| `/info` | `GET` | Runtime metadata | Shows app mode, hostname, database host, database name, and database user. |
| `/dbcheck` | `GET` | App-to-database path | Opens a live MySQL connection and confirms the app can reach the private RDS database. |

```text
/          → Visual dashboard
/health    → Application health
/info      → Runtime metadata
/dbcheck   → RDS connectivity validation
```


## 🧪 Expected App Behavior

The Flask application exposes several validation routes to confirm that the workload is running correctly and can connect to the private RDS MySQL database.

---

### ✅ Health Check


GET /health

Expected response:
```http
{
  "status": "ok",
  "app_mode": "EC2 or ECS",
  "hostname": "instance-or-container-hostname"
}
```
This confirms that the Flask application is running successfully.

🗄️ Database Connectivity Check

GET /dbcheck

Expected response:
```http
{
  "status": "connected",
  "result": {
    "current_db": "labdb",
    "db_time": "timestamp"
  }
}
```
This confirms that the application can privately connect to the RDS MySQL database.

A visual dashboard that displays:

- **Application Mode** — identifies whether the app is running on EC2 or ECS
- **Hostname** — shows the instance or container hostname
- **Database Host** — displays the configured RDS database endpoint
- **Database Name** — shows the active MySQL database name
- **Database User** — shows the database user configured for the application
- **Available Routes** — lists the supported Flask endpoints
- **Test Buttons** — provides quick validation buttons for `/health`, `/info`, and `/dbcheck`

## 🚀 Quick Start

<table>
  <tr>
    <td width="50%" valign="top">

<h3>1️⃣ Manual Terraform Deployment</h3>

<h4>Clone the repository</h4>

<pre><code>git clone &lt;your-repository-url&gt;
cd &lt;your-project-folder&gt;</code></pre>

<h4>Review Terraform variables</h4>

<p>Before deploying, update:</p>

<pre><code>variable.tf</code></pre>

<p>Important variables:</p>

<pre><code>project_name
aws_region
instance_type
container_port
app_port
db_name
db_username
db_password
image_tag</code></pre>

<h4>Initialize Terraform</h4>

<pre><code>terraform init</code></pre>

<h4>Validate configuration</h4>

<pre><code>terraform validate</code></pre>

<h4>Review execution plan</h4>

<pre><code>terraform plan</code></pre>

<h4>Deploy base infrastructure</h4>

<pre><code>terraform apply -auto-approve</code></pre>

<h4>Build and push Docker image to ECR</h4>

<p>The ECS service depends on a Docker image being available in Amazon ECR.</p>

<pre><code>cd scripts
chmod +x build_and_push_ecr.sh
./build_and_push_ecr.sh</code></pre>

<p>The script should:</p>

<pre><code>1. Start Docker if needed
2. Build the local Docker image
3. Authenticate to Amazon ECR
4. Tag the image with the ECR repository URI
5. Push the image to Amazon ECR</code></pre>

<h4>Validate the image exists in ECR</h4>

<pre><code>aws ecr describe-images \
  --repository-name Secure-Multi-Tier-AWS-Application-Platform-with-Private-Database-Connectivity \
  --region us-east-1 \
  --query "imageDetails[].imageTags"</code></pre>

<h4>Re-apply Terraform to start ECS with the pushed image</h4>

<p>After the image exists in ECR, return to the project root and re-apply Terraform so the ECS service can launch using the uploaded image.</p>

<pre><code>cd ..
terraform init
terraform apply -auto-approve</code></pre>

</td>

<td width="50%" valign="top">

<h3>2️⃣ Automated Deployment</h3>

<h4>Clone the repository</h4>

<pre><code>git clone &lt;your-repository-url&gt;
cd &lt;your-project-folder&gt;</code></pre>

<h4>Review Terraform variables</h4>

<p>Before running the automated script, update:</p>

<pre><code>variable.tf</code></pre>

<p>Confirm these values are correct:</p>

<pre><code>project_name
aws_region
instance_type
container_port
app_port
db_name
db_username
db_password
image_tag</code></pre>

<h4>Run the automation script</h4>

<p>The <code>build_everything.sh</code> script performs the full deployment workflow.</p>

<pre><code>cd scripts
chmod +x build_everything.sh
./build_everything.sh</code></pre>

<h4>What the script does</h4>

<pre><code>1. Initializes Terraform
2. Applies the base AWS infrastructure
3. Creates the ECR repository
4. Builds the Docker image locally
5. Authenticates to Amazon ECR
6. Tags and pushes the image to ECR
7. Re-applies Terraform
8. Starts or refreshes the ECS service</code></pre>

<h4>Validate the deployment</h4>

<pre><code>curl http://&lt;alb-dns-name&gt;/health
curl http://&lt;alb-dns-name&gt;/dbcheck</code></pre>

<h4>Expected result</h4>

<pre><code>{
  "status": "connected"
}</code></pre>

<p>Use this method when you want the fastest path to deploy the infrastructure, upload the container image, and trigger ECS to run with the latest ECR image.</p>

</td>
  </tr>
</table>

## ⚙️ Manual vs Automated Deployment

This project supports two deployment paths: a manual Terraform workflow and an automated script-based workflow. Both reach the same final architecture, but the automated path reduces repeated commands, lowers the chance of human error, and speeds up the build-test-deploy cycle.

<table>
  <tr>
    <th width="25%">Deployment Method</th>
    <th width="25%">What You Do Manually</th>
    <th width="25%">Estimated Time</th>
    <th width="25%">Best Use Case</th>
  </tr>

  <tr>
    <td><b>Manual Deployment</b></td>
    <td>
      Run Terraform commands, build the Docker image, push to ECR, validate the image, then re-apply Terraform to start ECS.
    </td>
    <td>
      <b>15–30 minutes</b><br/>
      Depends on Docker startup, Terraform apply time, image upload speed, and troubleshooting.
    </td>
    <td>
      Best for learning, debugging, and understanding every step in the deployment workflow.
    </td>
  </tr>

  <tr>
    <td><b>Automated Deployment</b></td>
    <td>
      Run one script that handles Terraform initialization, infrastructure deployment, Docker build, ECR push, and Terraform re-apply.
    </td>
    <td>
      <b>5–10 minutes</b><br/>
      Most of the workflow runs without repeated manual commands.
    </td>
    <td>
      Best for repeatable deployments, faster testing, and reducing manual mistakes.
    </td>
  </tr>
</table>

---

## ⏱️ Time Savings Estimate

<table>
  <tr>
    <th>Workflow Step</th>
    <th>Manual Deployment</th>
    <th>Automated Deployment</th>
    <th>Automation Benefit</th>
  </tr>

  <tr>
    <td>Terraform initialization</td>
    <td>Manual command</td>
    <td>Handled by script</td>
    <td>Removes repeated setup steps</td>
  </tr>

  <tr>
    <td>Base infrastructure deployment</td>
    <td>Manual <code>terraform apply</code></td>
    <td>Handled by script</td>
    <td>Creates required AWS resources consistently</td>
  </tr>

  <tr>
    <td>Docker image build</td>
    <td>Manual script execution</td>
    <td>Included in automation</td>
    <td>Reduces context switching</td>
  </tr>

  <tr>
    <td>ECR authentication and image push</td>
    <td>Manual validation required</td>
    <td>Handled by script</td>
    <td>Prevents missing image/tag issues</td>
  </tr>

  <tr>
    <td>Second Terraform apply</td>
    <td>Must be remembered manually</td>
    <td>Handled automatically</td>
    <td>Ensures ECS can start with the uploaded image</td>
  </tr>

  <tr>
    <td>Total estimated time</td>
    <td><b>15–30 minutes</b></td>
    <td><b>5–10 minutes</b></td>
    <td><b>Saves roughly 50–70% of deployment time</b></td>
  </tr>
</table>

---

## 🚀 Why Automation Matters

<table>
  <tr>
    <td align="center" width="33%">
      <h3>⚡ Faster Deployments</h3>
      Automation reduces the number of manual commands required to build, push, and deploy the application.
    </td>
    <td align="center" width="33%">
      <h3>🧱 Repeatable Builds</h3>
      The same script can be run multiple times to recreate the workflow with consistent results.
    </td>
    <td align="center" width="33%">
      <h3>🛡️ Fewer Human Errors</h3>
      Automation helps avoid missed steps such as forgetting to push the ECR image or re-apply Terraform.
    </td>
  </tr>

  <tr>
    <td align="center" width="33%">
      <h3>🔁 Better Iteration</h3>
      Faster deployment cycles make it easier to test infrastructure, application changes, and networking updates.
    </td>
    <td align="center" width="33%">
      <h3>📦 Image-to-ECS Flow</h3>
      The script connects the Docker build, ECR push, and ECS deployment flow into one repeatable process.
    </td>
    <td align="center" width="33%">
      <h3>🏗️ Production-Like Workflow</h3>
      Real environments rely on automated deployment pipelines instead of repeated manual console or CLI steps.
    </td>
  </tr>
</table>

---

## 🧠 Key Takeaway

Manual deployment is useful for learning how each piece works. Automated deployment is better for speed, consistency, and repeatability.

```text
Manual Deployment
  → Best for learning and troubleshooting

Automated Deployment
  → Best for repeatable infrastructure delivery
```


🔁 ECS Deployment Flow
Docker image built locally
  ↓
Image pushed to ECR
  ↓
ECS task definition references ECR image
  ↓
ECS service launches task
  ↓
ECS task receives its own ENI and security group
  ↓
ALB forwards traffic to task
  ↓
Task connects to RDS over VPC peering


## 🖥️ EC2 Deployment Flow

```text
┌──────────────────────────────────────────────┐
│  🌐 1. User Request                           │
│  User sends traffic to the public endpoint   │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│  ⚖️ 2. Application Load Balancer              │
│  ALB receives traffic and routes requests    │
│  to healthy private EC2 targets              │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│  🖥️ 3. Private EC2 Instance                   │
│  EC2 launches inside a private subnet        │
│  with no direct public SSH access            │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│  ⚙️ 4. User Data Bootstrap                    │
│  Installs Python, Flask, PyMySQL,            │
│  Gunicorn, and required system packages      │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│  📦 5. Flask App Setup                        │
│  Application code is written to disk         │
│  during instance initialization              │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│  🚀 6. systemd + Gunicorn                     │
│  systemd starts and manages the Flask app    │
│  as a persistent Gunicorn service            │
└───────────────────────┬──────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────┐
│  🔐 7. Private Database Access                │
│  EC2 Flask app connects to RDS MySQL         │
│  privately over VPC peering                  │
└──────────────────────────────────────────────┘
```
## 🔐 Security Architecture

```text
🌐 Public Access
Internet → ALB:80
Only the Application Load Balancers are internet-facing.

        ↓

🧱 Private Application Access
ALB SG → App SG
Application workloads run in private subnets and only accept traffic from the ALB security group.

        ↓

🗄️ Private Database Access
App SG / ECS Task SG → DB SG:3306
The database security group allows MySQL traffic only from approved application security groups.

        ↓

🛠️ Administrative Access
IAM Role + SSM → Private EC2 Access
Private EC2 instances are accessed through AWS Systems Manager Session Manager.

No public SSH access is required.
```

## 🛡️ Security Group Design

| Security Group | Inbound Source | Port | Purpose |
|---|---|---:|---|
| **ALB SG** | Internet `0.0.0.0/0` | `80` | Allows public HTTP traffic to reach the Application Load Balancer |
| **EC2 App SG** | ALB SG | App Port | Allows the ALB to forward traffic to the standalone EC2 Flask app |
| **ECS Task SG** | ALB SG | App Port | Allows the ALB to forward traffic to ECS Flask tasks |
| **DB SG** | EC2 App SG | `3306` | Allows the EC2 Flask app to connect to RDS MySQL |
| **DB SG** | ECS Task SG | `3306` | Allows ECS tasks to connect to RDS MySQL |
| **ECS Instance SG** | No public inbound required | N/A | Supports ECS host outbound access and SSM-based administration |

> The database does not allow public access. MySQL traffic is only accepted from approved application security groups.

## 🧭 VPC Peering Design

This project uses **VPC peering** to enable private communication between the application VPCs and the database VPC.

The peering connection allows application workloads to reach the private RDS MySQL database without sending database traffic over the public internet.

---

### 🔁 Required Route Table Entries

Each side of the peering connection needs a route table entry.

| Route Table | Destination | Target |
|---|---|---|
| **Application VPC Route Table** | Database VPC CIDR | VPC Peering Connection |
| **Database VPC Route Table** | Application VPC CIDR | VPC Peering Connection |

---

### 🧱 Private Traffic Flow

```text
Application VPC
   ↓
VPC Peering Connection
   ↓
Database VPC
   ↓
Private RDS MySQL
```

---

### ⚠️ Terraform Dependency Note

When security group rules reference security groups across VPC peering, Terraform may try to create those rules before the peering connection and route table entries are fully ready.

To avoid dependency issues, add explicit `depends_on` relationships where needed.

```text
VPC Peering Connection
   ↓
Route Table Entries
   ↓
Cross-VPC Security Group Rules
```

This ensures that private routing exists before Terraform applies the database access rules.

This prevents race-condition style failures where the security group rule appears correct but connectivity does not work reliably.

## 🧪 Validation and Testing

Use the following commands to validate that the ALB, Flask application, and private RDS connectivity are working correctly.

---

### ✅ Test ALB Health Route

```bash
curl http://<alb-dns-name>/health
```

Expected result:

```json
{
  "status": "ok",
  "app_mode": "EC2 or ECS",
  "hostname": "instance-or-container-hostname"
}
```

---

### 🖥️ Test Application Dashboard

```bash
curl http://<alb-dns-name>/
```

Expected result:

The root route should return the application dashboard showing runtime details, database configuration values, and available test routes.

---

### 🗄️ Test Database Connectivity

```bash
curl http://<alb-dns-name>/dbcheck
```

Expected result:

```json
{
  "status": "connected"
}
```

This confirms that the application can reach the private RDS MySQL database through the private network path.

---

## 🔎 Debugging from SSM

Private EC2 instances are accessed through **AWS Systems Manager Session Manager**, not public SSH.

After connecting to the private EC2 instance through Session Manager, use the following commands to troubleshoot the application.

---

### ✅ Check Flask Service Status

```bash
sudo systemctl status flask-db-app --no-pager -l
```

---

### 📜 Check Flask Application Logs

```bash
sudo journalctl -u flask-db-app --no-pager -n 100
```

---

### 🌐 Check Listening Ports

```bash
sudo ss -lntp | grep -E ':80|:8080|:5000'
```

---

### 🧪 Test Local Health Route

```bash
curl -i http://127.0.0.1:8080/health
```

---

### 🗄️ Test Database Socket Connectivity

```bash
python - <<'PY'
import os
import socket

host = os.getenv("DB_HOST")
port = int(os.getenv("DB_PORT", "3306"))

s = socket.create_connection((host, port), timeout=5)
print("TCP connection to database succeeded")
s.close()
PY
```

This test confirms that the private EC2 instance can establish a TCP connection to the RDS database endpoint.

---

## 🧪 Debugging ECS Containers

Use these commands from the ECS container instance to inspect running containers and test database connectivity from inside the application container.

---

### 📦 List Running Docker Containers

```bash
sudo docker ps
```

---

### 🐳 Enter the Application Container

```bash
sudo docker exec -it <container-id> sh
```

---

### 🔐 Check Database Environment Variables

```bash
env | grep DB
```

---

### 🗄️ Test Database Connectivity from Inside the Container

```bash
python - <<'PY'
import os
import socket

host = os.getenv("DB_HOST")
port = int(os.getenv("DB_PORT", "3306"))

s = socket.create_connection((host, port), timeout=5)
print("TCP connection to database succeeded")
s.close()
PY
```

This confirms that the ECS task can reach the private RDS MySQL database through VPC peering and the configured security group rules.

---

## 🧩 Engineering Challenges and Fixes

| Problem | Root Cause | Fix |
|---|---|---|
| **ECS EC2 instance did not appear in the cluster** | ECS agent startup ordering issue | Deferred ECS startup until after cloud-init completed |
| **ECS task failed to pull image** | ECR image tag mismatch | Pushed the correct image tag to ECR and aligned it with the task definition |
| **Docker push failed** | Missing `AWS_REGION` variable | Defined `AWS_REGION` in the build script |
| **RDS connection timed out** | Database security group did not allow the actual source security group | Allowed inbound MySQL traffic from the ECS task SG and EC2 app SG |
| **Security group-only rule behaved inconsistently** | Terraform dependency order issue with VPC peering | Added explicit `depends_on` for peering and route resources |
| **ALB returned `502 Bad Gateway`** | Target was unhealthy due to incorrect app port or failed health check | Aligned the target group port, application port, health check path, and SG rules |
| **MySQL query failed** | SQL alias used a reserved-keyword-style name | Changed the alias to `db_time` |
| **Terraform ECS service recreation failed** | Old ECS service was still draining | Waited for the service to become inactive or temporarily used a new service name |

---

## 🏗️ Architecture Decisions

| Decision | Reason |
|---|---|
| **Use ALB as the public entry point** | Keeps compute resources private while still allowing controlled HTTP access |
| **Use private subnets for compute** | Reduces direct exposure of EC2 and ECS workloads |
| **Place RDS in a separate VPC** | Demonstrates database isolation and cross-VPC application access |
| **Use VPC peering** | Enables private IP communication without exposing the database publicly |
| **Use security-group-to-security-group database rules** | Provides tighter access control than broad CIDR-based rules |
| **Use SSM instead of SSH** | Avoids public SSH exposure and removes the need to manage SSH keys |
| **Use Terraform** | Makes the infrastructure repeatable, reviewable, and easier to rebuild |
| **Use `/dbcheck` route** | Provides simple application-level validation of database connectivity |

---

## 📈 Production Roadmap

This project is production-inspired but still a lab. The next improvements would make the platform more secure, reliable, automated, and observable.

---

### Phase 1 — Security Hardening

- Move database credentials to **AWS Secrets Manager**
- Add HTTPS using **AWS Certificate Manager**
- Redirect HTTP traffic to HTTPS
- Add **AWS WAF** in front of the Application Load Balancers
- Replace broad IAM permissions with tighter custom IAM policies
- Enable or verify **RDS encryption at rest**
- Add stricter outbound rules where practical
- Add least-privilege IAM policies for EC2, ECS, ECR, SSM, and logging

---

### Phase 2 — Reliability

- Enable **Multi-AZ RDS**
- Add Auto Scaling Groups for the EC2 application tier
- Run multiple ECS container instances across Availability Zones
- Enable ALB access logs
- Add CloudWatch alarms for ALB, ECS, EC2, and RDS
- Improve container-level logging
- Add health check tuning for more graceful deployments

---

### Phase 3 — CI/CD

- Add a GitHub Actions or Jenkins pipeline
- Automate Docker image build and ECR push
- Run `terraform fmt`, `terraform validate`, and `terraform plan` in CI
- Add container image scanning
- Add Terraform security scanning using Checkov or tfsec
- Add manual approval before production-style `terraform apply`
- Store Terraform state remotely in an S3 backend with state locking

---

### Phase 4 — Observability

- Add CloudWatch dashboards
- Enable VPC Flow Logs
- Add RDS performance monitoring
- Add synthetic health checks
- Forward logs to a SIEM or centralized logging platform
- Track application errors, ALB target health, database connections, and ECS task failures

---

## 🚧 Current Limitations

| Limitation | Current Status |
|---|---|
| **HTTPS** | Not implemented yet |
| **Secrets Manager** | Database credentials are not fully managed through Secrets Manager yet |
| **AWS WAF** | Not enabled yet |
| **Autoscaling** | Limited autoscaling coverage |
| **Region Design** | Currently designed as a single-region deployment |
| **CI/CD** | No formal pipeline yet |
| **Observability** | No full CloudWatch dashboard or centralized logging pipeline yet |

These limitations are acceptable for the current version because the main goal is to prove **private cross-VPC application-to-database connectivity** first.

---

## 🚀 Why This Project Matters

This project demonstrates practical cloud engineering beyond a basic “hello world” deployment.

It shows how to combine networking, compute, containers, load balancing, security groups, private database access, and Terraform into one working AWS architecture.

The value of this project is not just that the application works. The value is that it proves the ability to troubleshoot real infrastructure problems across multiple layers.

```text
Application
   ↓
Container
   ↓
EC2 Host
   ↓
Application Load Balancer
   ↓
Security Groups
   ↓
Route Tables
   ↓
VPC Peering
   ↓
RDS MySQL
   ↓
Terraform State and Dependencies
```

---

## ✨ What This Project Proves

| Area | Value Shown |
|---|---|
| **AWS Networking** | Multi-VPC routing and private connectivity |
| **Cloud Security** | Security group-based access control and private-by-default design |
| **Compute** | EC2 and ECS on EC2 deployment patterns |
| **Containers** | Docker image build, ECR push, and ECS runtime execution |
| **Infrastructure as Code** | Terraform-managed AWS deployment |
| **Troubleshooting** | Real debugging of ALB, ECS, RDS, ports, routes, and security groups |
| **Application Integration** | Flask application successfully reaches RDS through private networking |
| **Operational Access** | SSM-based private instance debugging without public SSH |

---

## ♻️ Cleanup

To avoid ongoing AWS charges, destroy the deployed infrastructure when testing is complete.

```bash
terraform destroy
```

After Terraform finishes, verify that the following resources were removed:

- Application Load Balancers
- NAT Gateways
- RDS instances
- EC2 instances
- ECS services
- ECS container instances
- ECR images
- VPC peering connections
- VPC routes and route tables
- Security groups
- CloudWatch log groups created during testing

> NAT Gateways, RDS instances, and running EC2 instances can continue generating charges if they are left active.

### ⚠️ Cleanup Troubleshooting

If `terraform destroy` takes too long or appears stuck on a resource such as an ECS service, the service may still be draining or waiting on attached resources.

Example:

```text
aws_ecs_service.app[0]: Still destroying...
```

If Terraform remains stuck for an extended period, manually delete the blocking resource from the AWS Console or AWS CLI, then re-run:

```bash
terraform destroy
```

If the resource was already deleted manually but Terraform is still stuck tracking it, remove that resource from the Terraform state.

First, find the resource name in state:

```bash
terraform state list
```

Then remove the deleted resource from state:

```bash
terraform state rm "resource_name_from_state"
```

Example:

```bash
terraform state rm "aws_ecs_service.app[0]"
```

After removing the stale resource from state, run destroy again:

```bash
terraform destroy
```

This allows Terraform to continue removing the remaining infrastructure cleanly.
👨‍💻 About the Author
<p align="center"> <img src="https://readme-typing-svg.demolab.com?font=Inter&weight=600&size=22&pause=1000&color=58A6FF&center=true&vCenter=true&width=760&lines=Cloud+Engineer+focused+on+AWS%2C+Terraform%2C+and+automation;Building+production-inspired+infrastructure+projects;Turning+cloud+concepts+into+real-world+implementations" alt="Typing SVG" /> </p> <p align="center"> I build hands-on cloud projects designed to reflect practical engineering work rather than simple demos. My focus is on <b>AWS infrastructure</b>, <b>Infrastructure as Code</b>, <b>automation</b>, <b>security-minded design</b>, and <b>real implementation patterns</b> that translate into production environments. </p> <p align="center"> <img src="https://img.shields.io/badge/AWS-Architecting-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white" /> <img src="https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" /> <img src="https://img.shields.io/badge/Cloud-Engineering-1F6FEB?style=for-the-badge" /> <img src="https://img.shields.io/badge/Automation-Building-success?style=for-the-badge" /> </p> <p align="center"> <a href="https://www.linkedin.com/in/gavin-fogwe/"> <img src="https://img.shields.io/badge/LinkedIn-Let's%20Connect-blue?style=for-the-badge&logo=linkedin" /> </a> <a href="https://github.com/gavinxenon0-arch"> <img src="https://img.shields.io/badge/GitHub-See%20More%20Projects-black?style=for-the-badge&logo=github" /> </a> <a href="https://gavinfogwe.win/"> <img src="https://img.shields.io/badge/Portfolio-Explore-orange?style=for-the-badge&logo=googlechrome&logoColor=white" /> </a> </p> ```

One thing to fix before publishing: save your diagram inside Evidence/architecture-diagram.png, or change the image path in the README to match your actual file name.