variable "project_name"          { type = string }
variable "environment"           { type = string }
variable "eks_cluster_role_arn"  { type = string }
variable "eks_nodes_role_arn"    { type = string }
variable "private_subnet_ids"    { type = list(string) }
variable "public_subnet_ids"     { type = list(string) }
variable "eks_cluster_sg_id"     { type = string }
