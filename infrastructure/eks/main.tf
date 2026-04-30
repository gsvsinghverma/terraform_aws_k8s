resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = var.eks_cluster_role_arn
  version  = "1.28"

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    security_group_ids      = [var.eks_cluster_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = true  # Jump server access k liye
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = { Name = "${var.project_name}-eks", Environment = var.environment }

  depends_on = [var.eks_cluster_role_arn]
}

# Node Group - AZ-1a
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.eks_nodes_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 4
  }

  update_config {
    max_unavailable = 1
  }

  tags = { Name = "${var.project_name}-node-group" }
}
