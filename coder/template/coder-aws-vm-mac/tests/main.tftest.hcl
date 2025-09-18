mock_provider "aws" {
    mock_data "aws_vpc" {
        defaults = {
            id         = "vpc-1234567890abcdef0"
            arn        = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-1234567890abcdef0"
            cidr_block = "172.31.0.0/16"
            default    = true
        }
    }
}

variables {
    ec2_user_password = "MockP@ssw0rd1234!"
}

run "create" {
    command = apply
}
