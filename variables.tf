variable "vpc_cidr" {  
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_port" {
  type = number
  default = 5432
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "max_frontend_ec2" {
  description = "Maximum number of EC2 instances in the frontend autoscaling group"
  type        = number
  default     = 4
}

variable "min_frontend_ec2" {
  description = "Minimum number of EC2 instances in the frontend autoscaling group"
  type        = number
  default     = 2
}

variable "frontend_desired_capacity" {
  description = "Desired number of EC2 instances in the frontend autoscaling group"
  type        = number
  default     = 2
}

variable "max_backend_ec2" {
  description = "Maximum number of EC2 instances in the backend autoscaling group"
  type        = number
  default     = 4
}

variable "min_backend_ec2" {
  description = "Minimum number of EC2 instances in the backend autoscaling group"
  type        = number
  default     = 2
}

variable "backend_desired_capacity" {
  description = "Desired number of EC2 instances in the backend autoscaling group"
  type        = number
  default     = 2
}

variable "ecr_registry_url" {
  description = "ECR registry URL e.g. 123456789012.dkr.ecr.ap-south-1.amazonaws.com"
  type        = string
}