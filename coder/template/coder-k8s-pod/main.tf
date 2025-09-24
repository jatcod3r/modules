terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    coder = {
      source = "coder/coder"
    }
  }
}

variable "name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "annotations" {
  type    = map(string)
  default = {}
}

variable "node_selector" {
  type    = map(string)
  default = {}
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = optional(string, "Equal")
    value    = string
    effect   = optional(string, "NoSchedule")
  }))
  default = []
}

variable "termination_grace_period_seconds" {
  type    = number
  default = 0
}

variable "container_image" {
  type    = string
  default = "codercom/enterprise-base:ubuntu"
}

variable "container_name" {
  type    = string
  default = "coder"
}

variable "container_image_pull_policy" {
  type    = string
  default = "Always"
}

variable "envs" {
  type    = map(string)
  default = {}
}

variable "envs_secret" {
  type = map(object({
    name = string
    key  = string
  }))
  default = {}
}

variable "cpu" {
  type        = number
  description = "CPU in m."
  default     = 250
}

variable "memory" {
  type        = number
  description = "Memory in GB."
  default     = 1
}

variable "user_id" {
  type    = number
  default = 1000
}

variable "fs_gid" {
  type    = number
  default = 1000
}

variable "run_as_root" {
  type    = bool
  default = false
}

variable "pre_command" {
  type        = string
  description = "Command(s) to run before the Coder initialization script."
  default     = ""
}

variable "post_command" {
  type        = string
  description = "Command(s) to run after the Coder initialization script."
  default     = ""
}
data "coder_workspace" "me" {}

resource "coder_agent" "agent" {
  arch = "amd64"
  os   = "linux"
  display_apps {
    vscode          = false
    vscode_insiders = false
    web_terminal    = true
    ssh_helper      = false
  }
}

locals {
  envs = merge({
    CODER_AGENT_TOKEN = try(coder_agent.agent.token, "")
  }, var.envs)
  envs_secret = merge({}, var.envs_secret)
  command = ["sh", "-c", join("\n", [
    var.pre_command,
    try(coder_agent.agent.init_script, ""),
    var.post_command
  ])]
}

resource "kubernetes_pod" "dev" {

  count = data.coder_workspace.me.start_count

  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    node_selector                    = var.node_selector
    termination_grace_period_seconds = var.termination_grace_period_seconds

    dynamic "toleration" {
      for_each = var.tolerations
      content {
        key      = toleration.value.key
        operator = toleration.value.operator
        value    = toleration.value.value
        effect   = toleration.value.effect
      }
    }

    container {
      name              = var.container_name
      image             = var.container_image
      image_pull_policy = var.container_image_pull_policy
      command           = local.command
      security_context {
        run_as_user                = var.user_id
        allow_privilege_escalation = var.run_as_root
        privileged                 = false
        read_only_root_filesystem  = false

      }
      resources {
        limits = {
          "cpu"    = "${var.cpu}m"
          "memory" = "${var.memory}Gi"
        }
      }
      dynamic "env" {
        for_each = local.envs
        content {
          name  = env.key
          value = env.value
        }
      }
      dynamic "env" {
        for_each = local.envs_secret
        content {
          name = env.key
          value_from {
            secret_key_ref {
              name = env.value.name
              key  = env.value.key
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [spec.0.container.0.env]
  }
}

output "agent_id" {
  value = coder_agent.agent.id
}

output "id" {
  value = try(kubernetes_pod.this[0].id, "")
}