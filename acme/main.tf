terraform {
    required_providers {
        acme = {
            source  = "vancluever/acme"
            version = ">= 2.8.0"
        }
        tls = {
            source  = "hashicorp/tls"
            version = ">= 4.0.0"
        }
    }
}

variable "cloudflare_api_token" {
    type = string
    sensitive = true
}

variable "acme_server_url" {
    type = string
    sensitive = true
}

variable "acme_registration_email" {
    type = string
    sensitive = true
}

variable "common_name" {
    type = string
    sensitive = true
}

variable "wildcard_name" {
    type = string
    sensitive = true
}

provider "acme" {
  server_url = var.acme_server_url
}

resource "acme_registration" "reg" {
  email_address   = var.acme_registration_email
}

resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "req" {
  private_key_pem = tls_private_key.cert_private_key.private_key_pem
  dns_names       = [var.common_name, var.wildcard_name]

  subject {
    common_name = var.common_name
  }
}

resource "acme_certificate" "this" {
  account_key_pem         = acme_registration.reg.account_key_pem
  certificate_request_pem = tls_cert_request.req.cert_request_pem
  min_days_remaining      = 30
  revoke_certificate_on_destroy = true
  revoke_certificate_reason = "cessation-of-operation"
  dns_challenge {
    provider = "cloudflare"
    config = {
        CF_DNS_API_TOKEN = var.cloudflare_api_token
    }
  }
}

output "private_key_pem" {
    value     = tls_private_key.cert_private_key.private_key_pem
    sensitive = true
}

output "certificate_pem" {
    value     = acme_certificate.this.certificate_pem
    sensitive = true
}