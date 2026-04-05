# Security group for bastion host

resource "aws_security_group" "bastion_sg" {
  name        = "${terraform.workspace}-bastion-sg"
  description = "Allow SSH to bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In prod, replace with your actual Home IP!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for Frontend ALB
resource "aws_security_group" "alb_sg" {
  name        = "${terraform.workspace}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# sg for frontend EC2 instances
resource "aws_security_group" "frontend_sg" {
    name        = "${terraform.workspace}-frontend-sg"
    vpc_id      = var.vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# sg for internal ALB
resource "aws_security_group" "internal_alb_sg" {
    name        = "${terraform.workspace}-internal-alb-sg"
    vpc_id      = var.vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.frontend_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# sg for backend EC2 instances
resource "aws_security_group" "backend_sg" {
    name        = "${terraform.workspace}-backend-sg"
    vpc_id      = var.vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.internal_alb_sg.id]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# sg for RDS but with terraform's best practices
resource "aws_security_group" "db_sg" {
  name        = "${terraform.workspace}-db-sg"
  description = "Security Group for Database Tier"
  vpc_id      = var.vpc_id
}

# Allow database traffic from backend tier
resource "aws_vpc_security_group_ingress_rule" "db_ingress_from_backend" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.backend_sg.id
  from_port                    = var.db_port # Dynamic based on your eventual choice
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  description                  = "Allow database traffic from backend tier"
}

# Allow SSH from bastion host to database (for maintenance)
resource "aws_vpc_security_group_ingress_rule" "db_ingress_from_bastion" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow database access from bastion host"
}


