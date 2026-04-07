variable "vpc_cidr" {  
  description = "CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "db_port" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "max_frontend_ec2" {
  description = "Maximum number of EC2 instances in the frontend autoscaling group"
  type        = number
}

variable "min_frontend_ec2" {
  description = "Minimum number of EC2 instances in the frontend autoscaling group"
  type        = number
}

variable "frontend_desired_capacity" {
  description = "Desired number of EC2 instances in the frontend autoscaling group"
  type        = number
}

variable "max_backend_ec2" {
  description = "Maximum number of EC2 instances in the backend autoscaling group"
  type        = number
}

variable "min_backend_ec2" {
  description = "Minimum number of EC2 instances in the backend autoscaling group"
  type        = number
}

variable "backend_desired_capacity" {
  description = "Desired number of EC2 instances in the backend autoscaling group"
  type        = number
}

variable "ecr_registry_url" {
  description = "ECR registry URL e.g. 123456789012.dkr.ecr.ap-south-1.amazonaws.com"
  type        = string
}