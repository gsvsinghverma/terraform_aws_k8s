output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_url" {
  value = module.ecr.ecr_repository_url
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "app_bucket_name" {
  value = module.s3.app_bucket_name
}

output "db_secret_arn" {
  value = module.secrets_manager.db_secret_arn
}
