provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
}

resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}

resource "aws_security_group" "https" {
  name        = "only-https"
  description = "Allow https traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_lb" "front_end" {
  # ...
}

resource "aws_lb_target_group" "front_end" {
  # ...
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "alb-example" {
  name        = "test-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
}

resource "aws_ec2_host" "test-ec2" {
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  host_recovery     = "on"
  auto_placement    = "on"
}

resource "aws_lb" "test-lb" {
  name               = "testing-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.https.id]
  subnets            = [aws_subnet.publicsubnet.id]

  enable_deletion_protection = true


  tags = {
    Environment = "production"
  }
}
