data "coder_parameter" "vpc_id" {
  name         = "vpc_id"
  display_name = "VPC ID"
  description  = "The VPC to deploy the workspace in."
  mutable      = true
  default      = ""
}

data "coder_parameter" "subnet_id" {
  name         = "subnet_id"
  display_name = "Subnet ID"
  description  = "The subnet to deploy the workspace in."
  mutable      = true
  default      = ""
}