# ─────────────────────────────────────────────────────────────────
# EC2 Launch — Method 3b: Terraform
# Amazon Linux 2023 + Nginx
# SV Technologies — sv-technologies.in
# ─────────────────────────────────────────────────────────────────

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ── Latest Amazon Linux 2023 AMI ─────────────────────────────────
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ── Default VPC ──────────────────────────────────────────────────
data "aws_vpc" "default" {
  default = true
}

# ── Security Group ────────────────────────────────────────────────
resource "aws_security_group" "web" {
  name        = "nginx-ec2-tf-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "nginx-ec2-tf-sg"
  }
}

# ── EC2 Instance ──────────────────────────────────────────────────
resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Hello from EC2!</h1><p>Launched via Terraform</p>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name = "nginx-ec2-terraform"
  }
}
