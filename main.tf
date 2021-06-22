
resource "aws_subnet" "default" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.default.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}



resource "aws_instance" "foo" {
  count                       = var.count_instance
  
  ami                         = lookup(var.ami, var.aws_region)
  instance_type               = var.instance_type
  #instances = element(aws_instance.foo.*.id, count.index)
  associate_public_ip_address = true
  user_data = var.apache0
  
  #  network_interface {
  #    network_interface_id = aws_network_interface.foo.id
  #    device_index         = 0
  #  }

  
  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name  = element(var.instance_tags, count.index)
    Batch = "5AM"   
  } 

}







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
