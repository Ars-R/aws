terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  #required_version = ">= 0.14.9"
}

# Configure the AWS Provider
provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

# Create a VPC
#resource "aws_vpc" "example" {
#  cidr_block = "10.0.0.0/16"
#}


# Create a VPC
resource "aws_vpc" "default" {
  cidr_block = "172.16.0.0/16"

  #  tags = {
  #    Name = "tf-example"
  #  }
}


