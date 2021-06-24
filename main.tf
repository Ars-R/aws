# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_dns_hostnames
  enable_dns_support   = var.vpc_dns_support

  tags = {
    Owner = var.owner
    Name  = var.owner
  }
}
# Create a subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.sbn_cidr_block
  
  tags = {
    Owner = var.owner
    Name  = var.owner
  }
}

# Create security_group
resource "aws_security_group" "sg" {
  name        = "${var.owner}-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress = [{
    description      = "All traffic"
    protocol         = var.sg_ingress_proto
    from_port        = var.sg_ingress_http
    to_port          = var.sg_ingress_http
    cidr_blocks      = [var.sg_ingress_cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false

  }]

  egress = [{
    description      = "All traffic"
    protocol         = var.sg_egress_proto
    from_port        = var.sg_egress_all
    to_port          = var.sg_egress_all
    cidr_blocks      = [var.sg_egress_cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false

  }]

  tags = {
    Owner = var.owner
    Name  = var.owner

  }
}

# Create target_group

resource "aws_lb_target_group_attachment" "tg" {
  count            = var.count_instance
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(aws_instance.instance.*.id, count.index)
  port             = 80
}

resource "aws_lb_target_group" "tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    port     = 80
    protocol = "TCP"
  }
}


# Create (and display) an SSH key
variable "key_name" {}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

# Create instance
resource "aws_instance" "instance" {
  count = var.count_instance
  ami   = lookup(var.ami, var.aws_region)
  instance_type               = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  key_name      = aws_key_pair.generated_key.key_name
  
  user_data = var.apache0
  

  
  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name  = element(var.instance_tags, count.index)
    Batch = "5AM"
  }
}

# Create gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main"
  }
}

# Create route_table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Owner = var.owner
    Name  = var.owner
  }

}

# Create loadbalancer
resource "aws_lb" "lb" {
  name               = "lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.subnet.*.id
  }

  enable_deletion_protection = true

  tags = {
    Environment = "aws_lb"
  }
}


# Create listener

# in progress
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.id

  default_action {
    target_group_arn = aws_lb_target_group.example.id
    type             = "forward"
  }
}




/*
resource "aws_elb" "bar" {
  name               = "loadbalancer"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  security_groups    = var.security_groups
  # access_logs {
  #   bucket        = "foo"
  #   bucket_prefix = "bar"
  #   interval      = 60
  # }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # listener {
  #   instance_port      = 8000
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  # }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = aws_instance.foo.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 40
  connection_draining         = true
  connection_draining_timeout = 30

  tags = {
    Name = "loadbalancer"
  }
}
*/
