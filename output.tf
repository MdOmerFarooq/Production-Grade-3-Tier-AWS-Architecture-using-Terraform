output "bastion_host_details" {
  value = module.compute_layer.bastion_host_details
}

output "frontend_alb_details" {
  value = {
    frontend_alb_dns_name = module.compute_layer.external_alb_dns_name
    frontend_alb_arn     = module.compute_layer.external_alb_arn
  }
}

output "internal_alb_details" {
  value = {
    internal_alb_dns_name = module.compute_layer.internal_alb_dns_name
    internal_alb_arn     = module.compute_layer.internal_alb_arn
  }
}

output "db_details" {
  value = {
    db_instance_endpoint = module.db_layer.db_hostname_endpoint
    db_instance_port     = module.db_layer.db_port
    db_instance_username = module.db_layer.db_username
    db_instance_name     = module.db_layer.db_name
    db_instance_secret_arn = module.db_layer.db_secret_arn
  }
}