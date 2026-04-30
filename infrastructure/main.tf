module "vpc" {
  source             = "./vpc"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "security_groups" {
  source       = "./security-groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source       = "./iam"
  project_name = var.project_name
  environment  = var.environment
}

module "s3" {
  source       = "./s3"
  project_name = var.project_name
  environment  = var.environment
}

module "ecr" {
  source       = "./ecr"
  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source               = "./rds"
  project_name         = var.project_name
  environment          = var.environment
  db_password          = var.db_password
  db_subnet_group_name = module.vpc.db_subnet_group_name
  rds_sg_id            = module.security_groups.rds_sg_id
}

module "eks" {
  source               = "./eks"
  project_name         = var.project_name
  environment          = var.environment
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  eks_nodes_role_arn   = module.iam.eks_nodes_role_arn
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  eks_cluster_sg_id    = module.security_groups.eks_cluster_sg_id
}

module "secrets_manager" {
  source       = "./secrets-manager"
  project_name = var.project_name
  environment  = var.environment
  db_password  = var.db_password
  rds_endpoint = module.rds.rds_endpoint
  db_name      = module.rds.rds_db_name
}

module "cloudwatch" {
  source       = "./cloudwatch"
  project_name = var.project_name
  environment  = var.environment
  alert_email  = "your-email@example.com"
}
