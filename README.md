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
Note :- please change the details in terraform.tfvars according to your project_name


aws_region         = "ap-south-1"                       
project_name       = "myapp"                            
environment        = "production"                       
vpc_cidr           = "10.0.0.0/16"                      
availability_zones = ["ap-south-1a", "ap-south-1b"]     
db_password        = "YourStrongPassword123!"           



### 1️⃣ PHASE : Jump Server Setup


---

Step 1: Login on AWS Console and create ec2 Jump Server

AWS Console → EC2 → Launch Instance


- Name: jump-server                     
- AMI: Ubuntu 22.04 LTS                
- Instance Type: t3.medium              
- Region: ap-south-1 (Mumbai)          
- Security Group: port 22            
- Key Pair: new → download           



Create IAM Role For Jump Server and Attach
```bash
Step 1: create IAM Role
AWS Console → IAM → Roles → Create Role

Step 1: Trusted Entity
→ "AWS Service" select karo
→ "EC2" select karo
→ Next

Step 2: Permissions add
→ Search: "AdministratorAccess"
→ Checkbox  ✅
→ Next

Step 3: Role name
→ Role name: jump-server-role
→ Create Role ✅

Step 2: Attach Role On Jump Server


AWS Console → EC2 → Instances
→ Select Jump Server
→ Actions (on right top)
→ Security
→ Modify IAM Role
→ Dropdown  "jump-server-role" select
→ Update IAM Role ✅

Step 3: verify on Jump Server

# SSH  jump server
ssh -i "your-key.pem" ubuntu@<jump-server-ip>
```

# Test
```bash
aws sts get-caller-identity
```

if you get this output means all are ✅

```bash
json{
    "UserId": "AROA...",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/jump-server-role/i-..."
}
```


INSTALL All Packages on JUMP SERVER 


# 1. System Update
```bash
sudo apt update && sudo apt upgrade -y
```
# 2. AWS CLI Install
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws --version
```
# 3. Terraform Install
```bash
sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
terraform --version
```
# 4. kubectl Install
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```
# 5. Helm Install
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```
# 6. Docker Install
```bash
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
```
# 7. Git Install
```bash
sudo apt install git -y
```
# 8. eksctl Install
```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```

## 📁 Project Structure
---

### 2️⃣ PHASE : Jump Server Setup


Create folder structure on Jump Server:


```bash
mkdir -p ~/infrastructure
cd ~/infrastructure
```
# Folder structure
```bash
mkdir -p {vpc,eks,rds,s3,ecr,security-groups,iam,secrets-manager,cloudwatch,jump-server}
touch main.tf variables.tf outputs.tf terraform.tfvars providers.tf
```

```bash
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
### 4️⃣   PHASE : Terraform Run Commands
```bash
cd ~/infrastructure
```
# 1. Initialize
terraform init

# 2. Validate
terraform validate

# 3. Plan
terraform plan -out=tfplan

# 4. Apply (take 15-20 min)
terraform apply tfplan

# see Output
terraform output

### 5️⃣ PHASE : EKS Connect by Jump Server
# Kubeconfig update
aws eks update-kubeconfig --region ap-south-1 --name myapp-cluster

# Test
kubectl get nodes
kubectl get pods -A

### 6⃣ PHASE 6: Docker Image Build & ECR Push
# ECR login
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS \
  --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

# Image build
docker build -t myapp-app .

# Tag
docker tag myapp-app:latest \
  <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp-app:latest

# Push
docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp-app:latest

### 7⃣ PHASE 7: Jenkins + ArgoCD Setup


Jenkins Install (EKS)
# Jenkins namespace
kubectl create namespace jenkins

# Using Helm to Jenkins install
helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=LoadBalancer

# Password
kubectl exec --namespace jenkins -it svc/jenkins \
  -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password
  
ArgoCD Install
# ArgoCD namespace
kubectl create namespace argocd

# Install
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Service expose
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "LoadBalancer"}}'

# Password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

  
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
## 🔐 Security Best Practices

* ✅ **No hardcoded AWS keys**
* ✅ Uses **IAM Roles & IRSA**
* ✅ Sensitive files excluded via `.gitignore`
* ✅ Private subnets for EKS & RDS
* ✅ Security Groups properly scoped

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

