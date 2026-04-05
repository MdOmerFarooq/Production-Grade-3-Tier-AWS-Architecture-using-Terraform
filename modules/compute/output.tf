output "bastion_host_details" {
  value = {
    bastion_host_id        = aws_instance.bastion.id
    bastion_host_public_ip = aws_instance.bastion.public_ip
    bastion_host_tags      = aws_instance.bastion.tags["Name"]
    bastion_host_username  = "ubuntu"
    bastion_host_ssh_key   = var.key_name
  }
}

# external load balancer dns name output
output "external_alb_dns_name" {
  description = "The DNS name of the external load balancer"
  value       = aws_lb.external_alb.dns_name
}

output "external_alb_arn" {
  value = aws_lb.external_alb.arn
}

# internal load balancer dns name output
output "internal_alb_dns_name" {
  description = "The DNS name of the internal load balancer"
  value       = aws_lb.internal_alb.dns_name
}

output "internal_alb_arn" {
  value = aws_lb.internal_alb.arn
}

output "internal_alb_id" {
  description = "The ID of the Internal Load Balancer"
  value       = aws_lb.internal_alb.id
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

output "frontend_asg_name" {
  value = aws_autoscaling_group.frontend_asg.name
}

output "backend_asg_name" {
  value = aws_autoscaling_group.backend_asg.name
}

output "frontend_lt_id" {
  value = aws_launch_template.frontend_lt.id
}

output "backend_lt_id" {
  value = aws_launch_template.backend_lt.id
}