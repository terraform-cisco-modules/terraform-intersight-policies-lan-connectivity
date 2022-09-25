<!-- BEGIN_TF_DOCS -->
# Fibre-Channel Pool Example

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

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
<!-- END_TF_DOCS -->