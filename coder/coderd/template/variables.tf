variable "path" {
    type = string
    default = ""
}

variable "tf_vars" {
    type = map(string)
    default = {}
}

variable "provisioner_tags" {
    type = map(string)
    default = {}
}

variable "url" {
    type = string
    default = ""
}

variable "org_id" {
    type = string
}

variable "name" {
    type = string
}

variable "auth" {
    type = object({email = string, password = string})
    default = { email = "", password = "" }
}

variable "display_name" {
    type = string
}

variable "description" {
    type = string
    default = "No description"
}

variable "icon" {
    type = string
    default = "/emojis/1f4e6.png"
}

variable "require_active_version" {
    type = bool
    default = false
}