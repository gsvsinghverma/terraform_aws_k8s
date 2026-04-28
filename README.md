# Project – Production Ready AWS Infrastructure

## 📌 Overview

This project provides a **production-grade AWS infrastructure setup** using Infrastructure as Code (Terraform) and modern DevOps practices.

It includes a complete environment with:

* Kubernetes (EKS)
* Database (Aurora PostgreSQL)
* Storage (S3)
* Container Registry (ECR)
* CI/CD (GitHub Actions + ArgoCD)
* Load Balancing (AWS Load Balancer Controller)
* cloudwatch (Logs)
* secrets-manager (Credentails)
---

##  Architecture

```
Mumbai Region (ap-south-1)
├── VPC: 10.0.0.0/16
│   ├── AZ-1a
│   │   ├── Public Subnet (10.0.1.0/24) → Jump Server
│   │   ├── Private Subnet (10.0.3.0/24) → EKS Nodes
│   │   └── DB Subnet (10.0.5.0/24) → RDS
│   └── AZ-1b
│       ├── Public Subnet (10.0.2.0/24)
│       ├── Private Subnet (10.0.4.0/24) → EKS Nodes
│       └── DB Subnet (10.0.6.0/24) → RDS
├── EKS Cluster
├── ECR (Docker Registry)
├── S3 Bucket
├── RDS PostgreSQL (Multi-AZ)
├── CloudWatch
└── Secrets Manager
```

---

## ⚙️ Tech Stack

| Service        | Purpose                    |
| -------------- | -------------------------- |
| AWS IAM        | Roles & Permissions        |
| AWS EC2        | Bastion / Jump Server      |
| AWS EKS        | Kubernetes Cluster         |
| AWS VPC        | Networking                 |
| AWS S3         | File Storage               |
| AWS ECR        | Docker Registry            |
| AWS RDS Aurora | PostgreSQL DB              |
| AWS ALB        | Load Balancer              |
| Route53        | DNS                        |
| CloudFront     | CDN                        |
| Terraform      | Infrastructure as Code     |
| Helm           | Kubernetes Package Manager |
| ArgoCD         | GitOps Deployment          |

---

## 📁 Project Structure

```
~/infrastructure/
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── security-groups/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── iam/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── s3/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ecr/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── rds/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── eks/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── secrets-manager/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── cloudwatch/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

## 🔐 Security Best Practices

* ✅ **No hardcoded AWS keys**
* ✅ Uses **IAM Roles & IRSA**
* ✅ Sensitive files excluded via `.gitignore`
* ✅ Private subnets for EKS & RDS
* ✅ Security Groups properly scoped

---

## 🚀 Setup Instructions

### 1️⃣ Clone Repo

```bash
git clone https://github.com/your-username/demo_project_aws_k8s_argocd_helmchart.git
cd demo_project_aws_k8s_argocd_helmchart
```

---

### 2️⃣ Initialize Terraform

```bash
terraform init
```

---

### 3️⃣ Plan Infrastructure

```bash
terraform plan
```

---

### 4️⃣ Deploy Infrastructure

```bash
terraform apply
```

---

### 5️⃣ Generate Environment File

```bash
chmod +x generate-env.sh
./generate-env.sh
```

---

### 6️⃣ Connect to EKS

```bash
aws eks update-kubeconfig --region ap-south-1 --name gsv-eks-cluster
kubectl get nodes
```

---

## 📦 Deploy Application

Application deployment is handled via **Helm + ArgoCD**.

### Steps:

1. Push code to GitHub
2. CI builds Docker image
3. Push to ECR
4. ArgoCD auto-deploys to EKS

---

## 🔄 CI/CD Flow

```
Code Push → GitHub Actions → Docker Build → ECR
         → ArgoCD detects change → Deploy to EKS
```

---

## 🌐 Features

* ✅ Multi-AZ Highly Available VPC
* ✅ Private EKS Cluster
* ✅ Secure Aurora PostgreSQL
* ✅ Auto-scaling Node Group
* ✅ GitOps-based Deployment
* ✅ Automated Load Balancer via LBC

---

## 📊 Outputs

After deployment:

* EKS Cluster Name
* RDS Endpoint
* S3 Bucket Name
* ECR Repository URL

---

## ⚠️ Important Notes

* Do NOT commit:

  * `terraform.tfvars`
  * `.env`
  * `.tfstate`
* Always use IAM Roles (no access keys)

---

## 👨‍💻 Author

**Gaurav Singh Verma**

---

## ⭐ Future Improvements

* Add Monitoring (Prometheus + Grafana)
* Add Logging (ELK Stack / CloudWatch)
* Add Multi-region DR setup
* Add Auto Scaling policies

---

