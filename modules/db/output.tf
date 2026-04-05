output "db_name" {
  value = aws_db_instance.postgres.db_name
}

output "db_hostname_endpoint" {
  value = aws_db_instance.postgres.address   # was .endpoint
}

output "db_port" {
  value = aws_db_instance.postgres.port
}

output "db_username" {
  description = "Master username"
  value = aws_db_instance.postgres.username
}

output "db_secret_arn" {
  description = "ARN of the secret containing the master user password"
  value = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.backend_profile.name
}