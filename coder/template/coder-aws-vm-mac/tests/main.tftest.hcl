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
            id         = "h-0385a99d0e4b20cbb"
            arn        = "arn:aws:ec2:us-east-1:123456789012:host/h-0385a99d0e4b20cbb"\
            instance_type = "mac2.metal"
        }
    }
}

run "create" {
    command = apply
}
