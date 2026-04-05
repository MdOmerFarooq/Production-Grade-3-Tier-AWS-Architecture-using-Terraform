module "networking_layer" {
  source = "./modules/Networking"
  vpc_cidr = var.vpc_cidr
  region = var.region
  availability_zones = var.availability_zones
}

module "security_layer" {
  source = "./modules/security"
  vpc_id = module.networking_layer.vpc_id
  db_port = var.db_port
  depends_on = [ module.networking_layer ]  
}

module "db_layer" {
  source = "./modules/db"
  vpc_id = module.networking_layer.vpc_id
  private_db_subnet_ids = module.networking_layer.private_db_subnet_ids
  db_sg_id = module.security_layer.db_sg_id
  db_name = "notes_app_db"
  db_username = "db_master_user"
}

# Lookup for latest Amazon ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "compute_layer" {
  source = "./modules/compute"
  vpc_id = module.networking_layer.vpc_id
  internet_gateway_id = module.networking_layer.internet_gateway_id
  nat_gateway_id = module.networking_layer.nat_gateway_id
  public_subnet_ids = module.networking_layer.public_subnet_ids
  bastion_sg_id = module.security_layer.bastion_sg_id
  private_frontend_subnet_ids = module.networking_layer.private_frontend_subnet_ids
  private_backend_subnet_ids = module.networking_layer.private_backend_subnet_ids
  availability_zones = var.availability_zones
  alb_sg_id = module.security_layer.external_alb_sg_id
  frontend_sg_id = module.security_layer.frontend_ec2_sg_id
  internal_alb_sg_id = module.security_layer.internal_alb_sg_id
  backend_sg_id = module.security_layer.backend_ec2_sg_id
  ami_id = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_name
  max_frontend_ec2 = var.max_frontend_ec2
  min_frontend_ec2 = var.min_frontend_ec2
  frontend_desired_capacity = var.frontend_desired_capacity
  max_backend_ec2 = var.max_backend_ec2
  min_backend_ec2 = var.min_backend_ec2
  backend_desired_capacity = var.backend_desired_capacity
  backend_db_instance_profile = module.db_layer.instance_profile_name
  aws_region       = var.region
  ecr_registry_url = var.ecr_registry_url
  internal_alb_dns = module.compute_layer.internal_alb_dns_name
  db_endpoint      = module.db_layer.db_hostname_endpoint
  db_port          = module.db_layer.db_port
  db_name          = module.db_layer.db_name
  db_username      = module.db_layer.db_username
  db_secret_arn    = module.db_layer.db_secret_arn
}
