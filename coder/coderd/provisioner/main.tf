data "coderd_organization" "org" {
  is_default = var.organization_name == null ? true : false
  name = var.organization_name == null ? null : var.organization_name
}

resource "random_id" "provisioner_key_name" {
  keepers = {
    # Generate a new ID only when a key is defined
    provisioner_key_name = "${var.provisioner_key_name}"
  }
  byte_length = 8
}

resource "coderd_provisioner_key" "key" {
    name = var.provisioner_key_name == null ? random_id.provisioner_key_name.id : var.provisioner_key_name
    organization_id = data.coderd_organization.org.id
}