# 🚀 Scalable MERN Stack Deployment (IaC Showcase)

This repository demonstrates the automated provisioning and deployment of a full-stack **MERN (MongoDB, Express, React, Node.js) application** onto **Amazon Web Services (AWS)** using modern Infrastructure-as-Code (IaC) tools.

It merges a high-quality MERN boilerplate (based on [mern-boilerplate](https://github.com/zulmy-azhary/mern-boilerplate)) with a production-ready, highly available infrastructure setup.

## 🎯 Infrastructure Overview (IaC)

The infrastructure layer is built to ensure **scalability, high availability, and automated management**.

### Key Infrastructure Technologies

| Tool/Technology | Use Case |
| :--- | :--- |
| **Terraform** | Provisioning core AWS resources: VPC components, Security Groups, IAM Roles, Auto Scaling Group (ASG), and an Application Load Balancer (ALB). |
| **Ansible** | Configuration management, running OS-level setup, installing dependencies (Node, MongoDB client), and deploying the MERN application code. |
| **AWS Auto Scaling** | Ensures application high availability and horizontal scaling; instances self-heal and automatically maintain a desired capacity. |
| **AWS ALB** | Distributes incoming HTTP traffic across the EC2 instances in the ASG. |
| **AWS CloudWatch** | Integrated for centralized logging and monitoring of EC2 instances. |

---

## ⚠️ CRITICAL SECURITY WARNING: Before You Run

To use this code, you **MUST** replace all placeholder values with your own secure configurations. **Never commit private keys or active credentials.**

### Essential Sanitization Steps

1.  **Delete/Exclude State File:** Ensure the local **`terraform.tfstate`** file is deleted and excluded from version control (via `.gitignore`).
2.  **Define SSH Key Path:** Update the `ssh_private_key_path` variable with the local path to **your own** private key file (`.pem`).
3.  **Replace AWS IDs:** Replace the placeholder `default` values for `vpc_id` and `subnet_ids` in `variables.tf` with the specific IDs from **your AWS environment**.

---

## ⚙️ Infrastructure Setup and Deployment

### Prerequisites

* **AWS Account:** With credentials configured (via CLI, environment variables, or IAM role).
* **Terraform:** Installed locally (version $>= 1.5.0$).
* **Ansible:** Installed locally.
* **SSH Key Pair:** An AWS EC2 Key Pair created in your target region.

### 1. Configure Variables

Create a `terraform.tfvars` file to define your environment-specific settings.

```hcl
# 🔑 Replace with the name of the Key Pair created in your AWS region
key_name               = "your-aws-key-name" 

# 🔑 Replace with the ABSOLUTE path to your local .pem file for Ansible SSH
ssh_private_key_path   = "/home/user/.ssh/your-key-file.pem" 

# 🌐 Replace with the specific IDs from your AWS account
vpc_id                 = "vpc-xxxxxxxxxxxxxxxxx"
subnet_ids             = [
  "subnet-xxxxxxxxxxxxxxxxx",
  "subnet-yyyyyyyyyyyyyyyyy",
  # ... include all desired subnet IDs ...
]


# Initialize providers and modules
terraform init

# Review the changes before applying
terraform plan

# Provision infrastructure and execute Ansible deployment
terraform apply


Outputs:
alb_dns = "yourloadbalancer link"