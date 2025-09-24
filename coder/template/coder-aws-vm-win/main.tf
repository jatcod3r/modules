terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        coder = {
            source = "coder/coder"
        }
    }
}

variable "show_builtin_vscode" {
    type = bool
    default = false
}

variable "show_builtin_vscode_insiders" {
    type = bool
    default = false
}

variable "show_builtin_web_terminal" {
    type = bool
    default = true
}

variable "show_builtin_ssh_helper" {
    type = bool
    default = false
}

variable "memory_monitoring" {
    type = object({
        threshold = optional(number, 80)
    })
    default = {}
}

variable "volume_monitoring" {
    type = object({
        threshold = optional(number, 80)
        path = optional(string, "")
    })
    default = {}
}

variable "home_mount_path" {
    type = string
    default = "/Users/ec2-user"
}

variable "subnet_id" {
    type = string
    default = ""
}

variable "vpc_security_group_ids" {
    type = list(string)
    default = []
}

variable "associate_public_ip_address" {
    type = bool
    default = false
}

variable "ami_id" {
    type = string
    default = ""
}

variable "pre_command" {
    type = string
    default = ""
}

variable "post_command" {
    type = string
    default = ""
}

variable "volume_size" {
    type = number
    default = 30
}

variable "coder_envs" {
    type = map(string)
    default = {}
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "instance_profile_name" {
    type = string
    default = null
}

variable "az_id" {
    type = string
    default = "a"

    validation {
        condition = contains(["a", "b", "c", "d", "e"], var.az_id)
        error_message = "'az_id' invalid. Must be either 'a', 'b', 'c', 'd', or 'e'."
    }   
}

variable "metadata_blocks" {
    type = list(object({
        display_name = string
        key = string
        order = optional(number, 1)
        script = string
        interval = optional(number, 10)
        timeout = optional(number, 1)
    }))
    default = []
}

variable "instance_type" {
    type = string
    default = "t3.large"
}

variable "ebs_optimized" {
    type = bool
    default = true
}

variable "instance_monitoring" {
    type = bool
    default = true
}

data "aws_region" "current" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

locals {
    volume_monitoring = try(var.volume_monitoring.path, false) == "" ? {
        threshold = var.volume_monitoring.threshold
        path = var.home_mount_path
    } : var.volume_monitoring
    ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.this.id
    availability_zone = "${data.aws_region.current.region}${var.az_id}"
    coder_envs = var.coder_envs
}

data "aws_ami" "this" {
    most_recent      = true
    owners           = ["amazon"]
    filter {
        name   = "name"
        values = ["Windows_Server-*-English-Full-Base-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
}

resource "coder_agent" "ec2-agent" {
    arch = "amd64"
    os = "windows"
    auth = "aws-instance-identity"
    env = var.coder_envs
    display_apps {
        vscode          = var.show_builtin_vscode
        vscode_insiders = var.show_builtin_vscode_insiders
        web_terminal    = var.show_builtin_web_terminal
        ssh_helper      = var.show_builtin_ssh_helper
    }
    dynamic "metadata" {
        for_each = var.metadata_blocks
        content {
            display_name = metadata.value.display_name
            key = metadata.value.key
            order = metadata.value.order
            script = metadata.value.script
            interval = metadata.value.interval
            timeout = metadata.value.timeout
        }
    }
    dynamic "resources_monitoring" {
        for_each = var.volume_monitoring != {} || var.memory_monitoring != {} ? [1] : []
        content {
            dynamic "memory" {
                for_each = var.memory_monitoring != {} ? [1] : []
                content {
                    enabled = true
                    threshold = var.memory_monitoring.threshold
                }
            }
            dynamic "volume" {
                for_each = var.volume_monitoring != {} ? [1] : []
                content {
                    enabled = true
                    threshold = local.volume_monitoring.threshold
                    path = local.volume_monitoring.path
                }
            }
        }
    }
}

resource "aws_instance" "this" {
    ami                         = local.ami_id
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    availability_zone           = var.subnet_id == "" ? local.availability_zone : null
    associate_public_ip_address = var.associate_public_ip_address
    vpc_security_group_ids      = var.vpc_security_group_ids
    iam_instance_profile        = var.instance_profile_name
    ebs_optimized               = var.ebs_optimized   
    monitoring                  = var.instance_monitoring

    user_data = <<-EOF
        <powershell>
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        ${join("\n", concat(
            var.pre_command == "" ? [] : [ var.pre_command ], 
            [ coder_agent.ec2-agent.init_script ], 
            var.post_command == "" ? [] : [ var.post_command ]
        ))}
        </powershell>
        <persist>true</persist>
    EOF

    root_block_device {
        volume_size = var.volume_size
        volume_type = "gp3"
        delete_on_termination = true
    }

    metadata_options {
        instance_metadata_tags = "enabled"
        http_tokens = "required"
    }

    lifecycle {
        ignore_changes = [ ami ]
    }

    tags = var.tags
}

resource "coder_agent_instance" "this" {
    agent_id    = coder_agent.ec2-agent.id
    instance_id = aws_instance.this.id
}

resource "aws_ec2_instance_state" "this" {
    instance_id = aws_instance.this.id
    state       = data.coder_workspace.me.start_count != 0 ? "running" : "stopped"
}

output "id" {
    value = aws_instance.this.id
}

output "arn" {
    value = aws_instance.this.arn
}

output "agent_id" {
    value = coder_agent.ec2-agent.id
}

output "agent_name" {
    value = "ec2-agent"
}