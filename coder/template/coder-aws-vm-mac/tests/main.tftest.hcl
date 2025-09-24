mock_provider "aws" {
  mock_data "aws_vpc" {
    defaults = {
      id         = "vpc-1234567890abcdef0"
      arn        = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-1234567890abcdef0"
      cidr_block = "172.31.0.0/16"
      default    = true
    }
  }
  mock_data "aws_ec2_host" {
    defaults = {
      id            = "h-1234567890abcdef0"
      arn           = "arn:aws:ec2:us-east-1:123456789012:host/h-1234567890abcdef0"
      instance_type = "mac2.metal"
    }
  }
  mock_data "aws_ec2_instance_type" {
    defaults = {
      supported_architectures = ["arm64_mac"]
    }
  }
}

variables {
  ec2_user_password = "MockP@ssw0rd1234!"
}

run "create" {
  command = apply
}
