variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}
