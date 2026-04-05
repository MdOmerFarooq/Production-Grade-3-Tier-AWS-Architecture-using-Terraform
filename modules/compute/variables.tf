variable "vpc_id" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "nat_gateway_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "bastion_sg_id" {
  type = string
}

variable "private_frontend_subnet_ids" {
  type = list(string)
}

variable "private_backend_subnet_ids" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "frontend_sg_id" {
  type = string
}

variable "internal_alb_sg_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}

variable "ami_id" {
  type = string
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

variable "backend_db_instance_profile" {
  description = "The Instance Profile to attach to backend EC2 instances for RDS secret access"
  type        = string
}

variable "aws_region" {
  type = string
}
variable "ecr_registry_url" {
  type = string
}
variable "internal_alb_dns" {
  type = string
}
variable "db_endpoint" {
  type = string
}
variable "db_port" {
  type = number
}
variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_secret_arn" {
  type = string
}