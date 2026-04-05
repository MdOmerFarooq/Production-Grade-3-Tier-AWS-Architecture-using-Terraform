# creating a subnet group for our RDS instance
resource "aws_db_subnet_group" "db_subnet" {
  name       = "${terraform.workspace}-db-subnet-group"
  # This uses the list of IDs we passed in from the root module
  subnet_ids = var.private_db_subnet_ids 
  tags = {
    Name = "${terraform.workspace}-db-subnet-group"
  }
}

# Creating  RDS Instance (aws Secrets Manager will handle the password for us)
resource "aws_db_instance" "postgres" {
  identifier           = "${terraform.workspace}-database"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  
  db_name              = "${var.db_name}_${terraform.workspace}"
  username             = var.db_username

  # This tells AWS: "Create a secret for me and manage the password."
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [var.db_sg_id]
  
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
}

# creating an instance profile , role , policy and attaching the profile to backend EC2 instances to read the RDS secret from Secrets Manager

# 1. The IAM Role that EC2 instances will assume when the instance profile is attached to get permissions
resource "aws_iam_role" "backend_role" {
  name = "${terraform.workspace}-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 2. The IAM Policy (Permission to read the database secret)
resource "aws_iam_role_policy" "backend_secret_policy" {
  name = "${terraform.workspace}-backend-secret-policy"
  role = aws_iam_role.backend_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = aws_db_instance.postgres.master_user_secret[0].secret_arn
      }
    ]
  })
}

# another policy to allow backend EC2 instances to pull docker images from ECR
resource "aws_iam_role_policy" "backend_ecr_policy" {
  name = "${terraform.workspace}-backend-ecr-policy"
  role = aws_iam_role.backend_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
      Resource = "*"
    }]
  })
}

# 3. The Instance Profile 
resource "aws_iam_instance_profile" "backend_profile" {
  name = "${terraform.workspace}-backend-profile"
  role = aws_iam_role.backend_role.name
}