terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

provider "docker" {
  registry_auth {
    address  = "https://index.docker.io/v1/"
    username = var.username
    password = var.password
  }
}

resource "docker_image" "sysbox" {
  name = "docker.io/${var.username}/sysbox-deploy-k8:latest"
  build {
    context    = "./"
    dockerfile = "Dockerfile"
  }
}