variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for project resources"
  type        = string
  default     = "java-app"
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
  default     = "jwt"
}

variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Initial RDS storage size in GiB"
  type        = number
  default     = 20
}

variable "app_instance_type" {
  description = "EC2 instance type for the application tier"
  type        = string
  default     = "t3.micro"
}

variable "app_min_size" {
  description = "Minimum number of application instances"
  type        = number
  default     = 2
}

variable "app_desired_capacity" {
  description = "Desired number of application instances"
  type        = number
  default     = 3
}

variable "app_max_size" {
  description = "Maximum number of application instances"
  type        = number
  default     = 4
}
