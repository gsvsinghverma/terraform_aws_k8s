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

## ✅ Prerequisites (Before You Start)

| Requirement | Details |
|-------------|---------|
| AWS Account | With billing enabled |
| AWS Budget Alert | Set $50 alert to avoid surprise bills |
| Domain Name | For Route53 (optional) |
| GitHub Account | For CI/CD pipeline |
| Local Machine OS | Linux/Mac/Windows (WSL2) |

> ⚠️ **Cost Warning:** EKS (~$70/month) + RDS Aurora (~$50/month) 
> + NAT Gateway (~$30/month) = ~$150-200/month minimum.
> if you are using for  learning perpose so please run this command  `terraform destroy` !

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
→ "AWS Service" select
→ "EC2" select
→ Next

Step 2: Permissions add
→ Search: "AdministratorAccess"
→ Checkbox  ✅
→ Next

> ⚠️ **Security Note:** `AdministratorAccess` for learning/testing it is ok but 
> For Production use:
> - `AmazonEKSClusterPolicy`
> - `AmazonEC2ContainerRegistryFullAccess`  
> - `AmazonRDSFullAccess`
> - `AmazonS3FullAccess`

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

if you get this output means all are ok ✅

```bash
{
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
# 3. Docker Install
```bash
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
```
# 4. Git Install
```bash
sudo apt install git -y
```

# 5. kubectl Install
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --client
```
# 6. eksctl Install
```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```
# 7. Terraform Install
```bash
sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
terraform --version
```
# 8. Helm Install
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```



### 2️⃣ PHASE : Clone Run Commands
```bash
git clone https://github.com/gsvsinghverma/terraform_aws_k8s.git
cd terraform_aws_k8s
cd infrastructure
```
## 📁 Project Structure
---
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
### 3️⃣  PHASE : Terraform Run Commands
```bash
cd ~/infrastructure
```
# 1. Initialize
```bash
terraform init
```
# 2. Validate
```bash
terraform validate
```
# 3. Plan
```bash
terraform plan -out=tfplan
```
# 4. Apply (take 15-20 min)
```bash
terraform apply tfplan
```
# see Output
```bash
terraform output
```
### 4️⃣   PHASE :  EKS Connect by Jump Server

# Kubeconfig update
```bash
aws eks update-kubeconfig --region ap-south-1 --name myapp-cluster
```
# Test
```bash
kubectl get nodes
kubectl get pods -A
```
### 5️⃣ PHASE : Docker Image Build & ECR Push


# ECR login
```bash
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS \
  --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com
```
# Image build
```bash
docker build -t myapp-app .
```
# Tag
```bash
docker tag myapp-app:latest \
  <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp-app:latest
```
# Push
```bash
docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp-app:latest
```

> 💡 **CI/CD Role clarity:**
> - **GitHub Actions** = The code is automatically triggered when pushed.,
>   Builds Docker image, pushes to ECR
> - **Jenkins** = Optional alternative — works the same instead of GitHub Actions
> - **ArgoCD** = Deploys to EKS (GitOps)


### 6️⃣  PHASE : Jenkins + ArgoCD Setup


Jenkins Install (EKS)
# Jenkins namespace
```bash
kubectl create namespace jenkins
```
# Using Helm to Jenkins install
```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set controller.serviceType=LoadBalancer
```
# Password
```bash
kubectl exec --namespace jenkins -it svc/jenkins \
  -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password
  ```
ArgoCD Install

# ArgoCD namespace
```bash
kubectl create namespace argocd
```
# Install
```bash
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
# Service expose
```bash
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "LoadBalancer"}}'
```
# Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```
### 7️⃣ PHASE : Monitoring Setup (Prometheus + Grafana)

# Monitoring namespace
```bash
kubectl create namespace monitoring
```

# Helm repo add
```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update
```

# Install Prometheus + Grafana (kube-prometheus-stack)
```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.service.type=LoadBalancer
```
# Grafana password
```bash
kubectl --namespace monitoring get secret monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d
```

  
### 🔄 Terraform

```bash
terraform init      # Initialize
terraform plan      # Preview
terraform apply     # Deploy
terraform destroy   # Destroy
```

---

### 🔄 Kubectl

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl logs <pod-name> -n <namespace>
```

---

### 🔄 EKS update kubeconfig

```bash
aws eks update-kubeconfig --region ap-south-1 --name myapp-cluster
```

---

### 🔄 ECR login

```bash
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin \
  <account-id>.dkr.ecr.ap-south-1.amazonaws.com
```

---

### 🔄 Connect to EKS

```bash
aws eks update-kubeconfig --region ap-south-1 --name myapp-cluster
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
Code Push → GitHub Actions → Docker Build → ECR  → ArgoCD detects change → Deploy to EKS
```

## 🔄 Terraform Delete Command


Infrastructure Deletion Guide (Destroy Setup)

Correct Deletion Order

Step 1: Delete ArgoCD (First)

```bash
kubectl delete -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl delete namespace argocd
```
Step 2: Delete Jenkins

```bash
helm uninstall jenkins --namespace jenkins
helm uninstall monitoring -n monitoring
kubectl delete namespace jenkins
kubectl delete namespace monitoring
```

⚠️ Pre-Requisites Before Running terraform destroy
1. Disable RDS Deletion Protection (Required)

If deletion_protection = true, Terraform destroy will fail.

Disable it first:
```bash
aws rds modify-db-instance \
  --db-instance-identifier myapp-postgres \
  --no-deletion-protection \
  --apply-immediately
  ```
2. Empty S3 Bucket (Required)

Terraform cannot delete a non-empty S3 bucket.
```bash
aws s3 rm s3://your-bucket-name --recursive
```
3. (Optional) Delete Jump Server Manually



Step 3: Terraform Destroy (Delete All Resources)
```bash
cd ~/infrastructure
```
# Check what will be deleted
```bash
terraform plan -destroy
```
# Destroy infrastructure
```bash
terraform destroy
```
After running terraform destroy, Terraform will ask for confirmation:

```bash
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure.
  There is no undoing this. Only 'yes' will be accepted.

Enter a value: yes

Type yes to proceed.
```

Terraform Deletion Order (Automatic)

Terraform deletes resources in dependency order:

EKS Nodes        → deleted first
EKS Cluster      → deleted
RDS              → deleted
Secrets Manager  → deleted
ECR              → deleted
S3               → deleted
Security Groups  → deleted
NAT Gateway      → deleted
VPC              → deleted last

If your Jump Server is not managed by Terraform, delete it manually:

```bash
Go to AWS Console → EC2 → Instances
Select Jump Server
Click Instance State → Terminate Instance
Confirm ✅
Now Run Terraform Destroy
cd ~/infrastructure
```
```bash
terraform destroy
```
```

## 🚀 CI/CD Flow

1. Developer pushes code to GitHub  
2. Jenkins pipeline triggers  
3. Application build (JAR/WAR)  
4. Docker image build  
5. Push image to AWS ECR  
6. Update Kubernetes manifest  
7. Push changes to Git  
8. ArgoCD detects changes  
9. Deploy to AWS EKS  
10. Pods start  
11. Application runs  
12. Fetch secrets from AWS Secrets Manager  
13. Connect to RDS PostgreSQL  
14. Monitoring via CloudWatch
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

* Add Logging (ELK Stack / CloudWatch)
* Add Multi-region DR setup
* Add Auto Scaling policies

---

## 🛠️ Troubleshooting
|---------------------------------------------------------------------------------------|
| Problem                | Solution                                                     |
|------------------------|--------------------------------------------------------------|
| Terraform init` fails  | Check AWS credentials: `aws sts get-caller-identity`         |
| EKS nodes not joining  | Check Security Group rules for port 443                      |
| RDS connection refused | Check Private Subnet routing & SG rules                      |
| ArgoCD not syncing     | Check GitHub repo access & webhook                           |
| ECR push denied        | Re-run ECR login command                                     |
| Pods in Pending state  | Check node capacity: `kubectl describe pod <name>`           |
| Terraform destroy`fails| Disable RDS deletion protection first (already mentioned ✅) |
