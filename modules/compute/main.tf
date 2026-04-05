# creates a bastion host in the public subnet to allow secure ssh access to private instances
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[0]
  key_name      = var.key_name
  security_groups = [var.bastion_sg_id]

  tags = {
    Name = "${terraform.workspace}-bastion"
  }
}

# create launch template for frontend EC2 instances
resource "aws_launch_template" "frontend_lt" {
  name_prefix   = "${terraform.workspace}-frontend-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.frontend_sg_id]
  iam_instance_profile {
    name = aws_iam_instance_profile.frontend_profile.name
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y docker.io awscli
    systemctl start docker
    systemctl enable docker
    aws ecr get-login-password --region ${var.aws_region} | \
      docker login --username AWS --password-stdin ${var.ecr_registry_url}
    docker pull ${var.ecr_registry_url}/notes-frontend:latest
    docker run -d \
      --restart always \
      -p 80:80 \
      -e BACKEND_URL=http://${var.internal_alb_dns} \
      ${var.ecr_registry_url}/notes-frontend:latest
  EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${terraform.workspace}-frontend-instance"
    }
  }
}

# create target group for frontend instances
resource "aws_lb_target_group" "frontend_tg" {
  name     = "${terraform.workspace}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/" # The ALB will ping this path to see if the app is alive
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# create a ec2 autoscaling group for frontend instances
resource "aws_autoscaling_group" "frontend_asg" {
  name                      = "${terraform.workspace}-frontend-asg"
  max_size                  = var.max_frontend_ec2
  min_size                  = var.min_frontend_ec2
  desired_capacity          = var.frontend_desired_capacity
  vpc_zone_identifier = var.private_frontend_subnet_ids
  launch_template {
    id = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }
  health_check_type = "ELB"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.frontend_tg.arn]
  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-frontend-instance"
    propagate_at_launch = true
  }
}

# create ALB
resource "aws_lb" "external_alb" {
  name               = "${terraform.workspace}-external-alb"
  internal           = false # This makes it accessible from the internet
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids # Place it in the Public subnets
}

# Add the Listener: The "Ear" that listens for traffic
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# create launch template for backend EC2 instances
resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${terraform.workspace}-backend-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = var.backend_db_instance_profile
  }
  vpc_security_group_ids = [var.backend_sg_id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y docker.io awscli
    systemctl start docker
    systemctl enable docker
    aws ecr get-login-password --region ${var.aws_region} | \
      docker login --username AWS --password-stdin ${var.ecr_registry_url}
    docker pull ${var.ecr_registry_url}/notes-backend:latest
    docker run -d \
      --restart always \
      -p 5000:5000 \
      -e DB_HOST=${var.db_endpoint} \
      -e DB_PORT=${var.db_port} \
      -e DB_NAME=${var.db_name} \
      -e DB_USER=${var.db_username} \
      -e DB_SECRET_ARN=${var.db_secret_arn} \
      -e AWS_REGION=${var.aws_region} \
      ${var.ecr_registry_url}/notes-backend:latest
  EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${terraform.workspace}-backend-instance"
    }
  }
}

# create target group for backend instances
resource "aws_lb_target_group" "backend_tg" {
  name     = "${terraform.workspace}-backend-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# create a ec2 autoscaling group for backend instances
resource "aws_autoscaling_group" "backend_asg" {
  name                      = "${terraform.workspace}-backend-asg"
  max_size                  = var.max_backend_ec2
  min_size                  = var.min_backend_ec2
  desired_capacity          = var.backend_desired_capacity
  vpc_zone_identifier = var.private_backend_subnet_ids
  launch_template {
    id = aws_launch_template.backend_lt.id
    version = "$Latest"
  }
  health_check_type = "ELB"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.backend_tg.arn]
  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-backend-instance"
    propagate_at_launch = true
  }
}

# Create Internal ALB
resource "aws_lb" "internal_alb" {
  name               = "${terraform.workspace}-internal-alb"
  internal           = true # This makes it accessible only within the VPC
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_sg_id]
  subnets            = var.private_frontend_subnet_ids # Place it in the Private subnets
}

# Add the Listener: The "Ear" that listens for traffic
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_iam_role" "frontend_role" {
  name = "${terraform.workspace}-frontend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "frontend_ecr_policy" {
  name = "${terraform.workspace}-frontend-ecr-policy"
  role = aws_iam_role.frontend_role.id
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

resource "aws_iam_instance_profile" "frontend_profile" {
  name = "${terraform.workspace}-frontend-profile"
  role = aws_iam_role.frontend_role.name
}