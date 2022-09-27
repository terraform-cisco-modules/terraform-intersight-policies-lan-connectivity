<!-- BEGIN_TF_DOCS -->
# Terraform Intersight Policies - LAN Connectivity
Manages Intersight LAN Connectivity Policies

Location in GUI:
`Policies` » `Create Policy` » `LAN Connectivity`

## Example

### main.tf
```hcl
module "lan_connectivity" {
  source  = "terraform-cisco-modules/policies-lan-connectivity/intersight"
  version = ">= 1.0.1"

  description                 = "default LAN Connectivity Policy."
  enable_azure_stack_host_qos = false
  iqn_allocation_type         = "None"
  name                        = "default"
  organization                = "default"
  vnic_placement_mode         = "custom"
  target_platform             = "FIAttached"
  vnics = [
    {
      cdn_source                      = "vnic"
      ethernet_adapter_policy         = "default"
      ethernet_network_control_policy = "default"
      ethernet_network_group_policy   = "default"
      ethernet_qos_policy             = "default"
      mac_address_allocation_type     = "POOL"
      mac_address_pools               = ["default", "default"]
      names                           = ["MGMT-A", "MGMT-B"]
      placement_pci_order             = [2, 3]
      placement_slot_id               = ["MLOM"]
    }
  ]
}
```

### provider.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
  required_version = ">=1.3.0"
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = var.secretkey
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

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

### Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

### Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey="<secret-key-file-location>""
```
<!-- END_TF_DOCS -->