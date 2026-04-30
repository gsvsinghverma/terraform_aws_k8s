variable "project_name"        { type = string }
variable "environment"         { type = string }
variable "db_password"         { type = string; sensitive = true }
variable "db_subnet_group_name"{ type = string }
variable "rds_sg_id"           { type = string }
