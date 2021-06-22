variable "ami" {
  type = map(any)
  default = {
    "us-east-2" = "ami-00399ec92321828f5"

  }
}


variable "count_instance" {
  default = "2"
}


variable "instance_type" {
  default = "t2.micro"
}


variable "aws_region" {
  default = "us-east-2"
}


variable "security_groups" {
  default = ["sg-ddcd0eae"]
}


variable "instance_tags" {
  type = list
  default = ["vm-1", "vm-2"]
}



variable "apache0" {
  default = <<-EOF
    #!/bin/bash
    sudo su
    apt-get install apache2 -y
    sudo chmod 777 /var/www/html/
    rm /var/www/html/index.html
    echo "<p>Hello vm1</p>" >> /var/www/html/index.html
    
    sudo systemctl enable apache2
    sudo systemctl start apache2
    apt-get update
    apt-get install mc -y
    EOF
}

variable "apache1" {
  default = <<-EOF
    #!/bin/bash
    sudo su
    apt-get install apache2 -y
    sudo chmod 777 /var/www/html/
    rm /var/www/html/index.html
    echo "<p>Hello vm1</p>" >> /var/www/html/index.html
    
    sudo systemctl enable apache2
    sudo systemctl start apache2
    apt-get update
    apt-get install mc -y
    EOF
}

