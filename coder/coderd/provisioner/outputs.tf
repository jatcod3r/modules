output "provisioner_key_name" {
    description = "Coder Provisioner Key Name"
    value = var.provisioner_key_name == null ? random_id.provisioner_key_name.id : var.provisioner_key_name
}

output "provisioner_key_secret" {
    description = "Coder Provisioner Key Secret"
    value = coderd_provisioner_key.key.key
}

output "organization_name" {
    description = "Coder Organization Name"
    value = data.coderd_organization.org.id
}