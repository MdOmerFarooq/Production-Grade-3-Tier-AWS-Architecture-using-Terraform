output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "external_alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "frontend_ec2_sg_id" {
  value = aws_security_group.frontend_sg.id
}

output "internal_alb_sg_id" {
  value = aws_security_group.internal_alb_sg.id
}

output "backend_ec2_sg_id" {
  value = aws_security_group.backend_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}