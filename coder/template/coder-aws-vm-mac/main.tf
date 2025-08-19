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
    default = "/home/coder"
}

variable "instance_type" {
    type = string
    default = "mac1.metal"
}

variable "subnet_id" {
    type = string
    default = ""
}

variable "az_id" {
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
    default = null
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
    default = 20
}

variable "tags" {
    type = map(string)
    default = {}
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

data "aws_ami" "this" {
    most_recent      = true
    ami_id = var.ami_id
    filter {
        name   = "source"
        values = ["amazon/amzn-ec2-macos-*"]
    }
}

data "aws_subnet" "this" {
    id = var.subnet_id
}

locals {
    volume_monitoring = try(var.volume_monitoring.path, false) == "" ? {
        threshold = var.volume_monitoring.threshold
        path = var.home_mount_path
    } : var.volume_monitoring
    ami_id = data.aws_ami.this.id
}

resource "coder_agent" "ec2-agent" {
    arch = "amd64"
    os = "darwin"

    display_apps {
        vscode          = var.show_builtin_vscode
        vscode_insiders = var.show_builtin_vscode_insiders
        web_terminal    = var.show_builtin_web_terminal
        ssh_helper      = var.show_builtin_ssh_helper
    }

    dynamic "metadata_blocks" {
        for_each = var.metadata_blocks
        content {
            display_name = metadata_blocks.value.display_name
            key = metadata_blocks.value.key
            order = metadata_blocks.value.order
            script = metadata_blocks.value.script
            interval = metadata_blocks.value.interval
            timeout = metadata_blocks.value.timeout
        }
    }

    dymamic "resource_monitoring" {
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

resource "aws_ec2_host" "this" {
    availability_zone = data.aws_subnet.this.availabilty_zone
    instance_type     = vc
    host_recovery     = "on"
}

resource "aws_instance" "mac" {
    ami                         = local.ami_id
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    associate_public_ip_address = var.associate_public_ip_address
    vpc_security_group_ids      = var.vpc_security_group_ids
    host_id                     = aws_ec2_host.this.id

    user_data = join("\n", [
        var.pre_command,
        coder_agent.ec2-agent.init_script,
        var.post_command
    ])
        
    root_block_device {
        volume_size = var.volume_size
        volume_type = "gp3"
        delete_on_termination = true
    }

    metadata_options {
        instance_metadata_tags = "enabled"
    }

    lifecycle {
        ignore_changes = [ ami ]
    }

    tags = var.tags
}

resource "aws_ec2_instance_state" "this" {
    instance_id = aws_instance.this.id
    state       = data.coder_workspace.me.start_count != 0 ? "running" : "stopped"
}

output "id" {
    value = aws_instance.mac.id
}

output "arn" {
    value = aws_instance.mac.arn
}

output "agent_id" {
    value = coder_agent.ec2-agent.id
}