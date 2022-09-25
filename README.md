<!-- BEGIN_TF_DOCS -->
# Terraform Intersight Pools - WWNN or WWPN
Manages Intersight WWNN or WWPN Pools

Location in GUI:
`Pools` » `Create Pool` » `WWNN or WWPN`

## Example

### main.tf
```hcl
module "wwpn_pool" {
  source  = "scotttyso/pools-fc/intersight"
  version = ">= 1.0.1"

  assignment_order = "sequential"
  description      = "Demo WWPN Pool"
  id_blocks = [
    {
      from = "0:00:00:25:B5:00:00:00"
      size = 1000
    }
  ]
  name         = "default"
  organization = "default"
  pool_purpose = "WWPN"
}

```

### variables.tf
```hcl
variable "apikey" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
}

variable "endpoint" {
  default     = "https://intersight.com"
  description = "Intersight URL."
  type        = string
}

variable "secretkey" {
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}
```

### versions.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = var.secretkey
}
```

### Environment Variables

Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey=`cat <secret-key-file-location>`
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Intersight URL. | `string` | `"https://intersight.com"` | no |
| <a name="input_secretkey"></a> [secretkey](#input\_secretkey) | Intersight Secret Key. | `string` | n/a | yes |
| <a name="input_assignment_order"></a> [assignment\_order](#input\_assignment\_order) | Assignment order decides the order in which the next identifier is allocated.<br>  * sequential - Identifiers are assigned in a sequential order.<br>  * default - Assignment order is decided by the system. | `string` | `"default"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the Fiber-Channel Pool. | `string` | `""` | no |
| <a name="input_id_blocks"></a> [id\_blocks](#input\_id\_blocks) | List of WWxN's Configuration Parameters to Assign to the Fiber-Channel Pool.<br>  * from - Staring WWxN Address.  An Example is "20:00:00:25:B5:00:00:00".<br>  * size - Size of WWxN Pool.  An Example is 1000.<br>  * to - Ending WWxN Address.  An Example is "20:00:00:25:B5:00:03:E7".<br>  * IMPORTANT NOTE: You can only Specify `size` or `to` on initial creation.  This is a limitation of the API. | <pre>list(object(<br>    {<br>      from = string<br>      size = optional(number)<br>      to   = optional(string)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Fiber-Channel Pool. | `string` | `"default"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_pool_purpose"></a> [pool\_purpose](#input\_pool\_purpose) | What type of Fiber-Channel Pool is this.  Options are:<br>  * WWNN<br>  * WWPN | `string` | `"WWPN"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | WWxN Pool Managed Object ID (moid). |
## Resources

| Name | Type |
|------|------|
| [intersight_fcpool_pool.fc_pool](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
<!-- END_TF_DOCS -->