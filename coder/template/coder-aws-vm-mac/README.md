<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.9.0 |
| <a name="provider_coder"></a> [coder](#provider\_coder) | 2.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_instance_state.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_instance_state) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [coder_agent.ec2-agent](https://registry.terraform.io/providers/coder/coder/latest/docs/resources/agent) | resource |
| [coder_agent_instance.this](https://registry.terraform.io/providers/coder/coder/latest/docs/resources/agent_instance) | resource |
| [coder_script.open_mac](https://registry.terraform.io/providers/coder/coder/latest/docs/resources/script) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_host.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_host) | data source |
| [aws_ec2_instance_type.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [coder_workspace.me](https://registry.terraform.io/providers/coder/coder/latest/docs/data-sources/workspace) | data source |
| [coder_workspace_owner.me](https://registry.terraform.io/providers/coder/coder/latest/docs/data-sources/workspace_owner) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | n/a | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | n/a | `bool` | `false` | no |
| <a name="input_az_id"></a> [az\_id](#input\_az\_id) | n/a | `string` | `"a"` | no |
| <a name="input_coder_envs"></a> [coder\_envs](#input\_coder\_envs) | n/a | `map(string)` | `{}` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | n/a | `bool` | `true` | no |
| <a name="input_ec2_host_id"></a> [ec2\_host\_id](#input\_ec2\_host\_id) | n/a | `string` | `""` | no |
| <a name="input_ec2_user_password"></a> [ec2\_user\_password](#input\_ec2\_user\_password) | n/a | `string` | n/a | yes |
| <a name="input_home_mount_path"></a> [home\_mount\_path](#input\_home\_mount\_path) | n/a | `string` | `"/Users/ec2-user"` | no |
| <a name="input_instance_monitoring"></a> [instance\_monitoring](#input\_instance\_monitoring) | n/a | `bool` | `true` | no |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | n/a | `string` | `null` | no |
| <a name="input_memory_monitoring"></a> [memory\_monitoring](#input\_memory\_monitoring) | n/a | <pre>object({<br/>    threshold = optional(number, 80)<br/>  })</pre> | `{}` | no |
| <a name="input_metadata_blocks"></a> [metadata\_blocks](#input\_metadata\_blocks) | n/a | <pre>list(object({<br/>    display_name = string<br/>    key          = string<br/>    order        = optional(number, 1)<br/>    script       = string<br/>    interval     = optional(number, 10)<br/>    timeout      = optional(number, 1)<br/>  }))</pre> | `[]` | no |
| <a name="input_post_command"></a> [post\_command](#input\_post\_command) | n/a | `string` | `""` | no |
| <a name="input_pre_command"></a> [pre\_command](#input\_pre\_command) | n/a | `string` | `""` | no |
| <a name="input_show_builtin_ssh_helper"></a> [show\_builtin\_ssh\_helper](#input\_show\_builtin\_ssh\_helper) | n/a | `bool` | `false` | no |
| <a name="input_show_builtin_vscode"></a> [show\_builtin\_vscode](#input\_show\_builtin\_vscode) | n/a | `bool` | `false` | no |
| <a name="input_show_builtin_vscode_insiders"></a> [show\_builtin\_vscode\_insiders](#input\_show\_builtin\_vscode\_insiders) | n/a | `bool` | `false` | no |
| <a name="input_show_builtin_web_terminal"></a> [show\_builtin\_web\_terminal](#input\_show\_builtin\_web\_terminal) | n/a | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_volume_monitoring"></a> [volume\_monitoring](#input\_volume\_monitoring) | n/a | <pre>object({<br/>    threshold = optional(number, 80)<br/>    path      = optional(string, "")<br/>  })</pre> | `{}` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | n/a | `number` | `20` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | n/a |
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END_TF_DOCS -->