<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)
[![Tests](https://github.com/terraform-cisco-modules/terraform-intersight-policies-lan-connectivity/actions/workflows/terratest.yml/badge.svg)](https://github.com/terraform-cisco-modules/terraform-intersight-policies-lan-connectivity/actions/workflows/terratest.yml)

# Terraform Intersight Policies - LAN Connectivity
Manages Intersight LAN Connectivity Policies

Location in GUI:
`Policies` » `Create Policy` » `LAN Connectivity`

## Easy IMM

[*Easy IMM - Comprehensive Example*](https://github.com/terraform-cisco-modules/easy-imm-comprehensive-example) - A comprehensive example for policies, pools, and profiles.

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
  secretkey = fileexists(var.secretkeyfile) ? file(var.secretkeyfile) : var.secretkey
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
  default     = ""
  description = "Intersight Secret Key Content."
  sensitive   = true
  type        = string
}

variable "secretkeyfile" {
  default     = "blah.txt"
  description = "Intersight Secret Key File Location."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with the value of [your-api-key]
- Add variable secretkey with the value of [your-secret-file-content]

### Linux and Windows
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkeyfile="<secret-key-file-location>"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
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
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_enable_azure_stack_host_qos"></a> [enable\_azure\_stack\_host\_qos](#input\_enable\_azure\_stack\_host\_qos) | Enabling AzureStack-Host QoS on an adapter allows the user to carve out traffic classes for RDMA traffic which ensures that a desired portion of the bandwidth is allocated to it. | `bool` | `false` | no |
| <a name="input_iqn_allocation_type"></a> [iqn\_allocation\_type](#input\_iqn\_allocation\_type) | Allocation Type of iSCSI Qualified Name.  Options are:<br>* None<br>* Pool<br>* Static | `string` | `"None"` | no |
| <a name="input_iqn_pool"></a> [iqn\_pool](#input\_iqn\_pool) | IQN Pool to Assign to the Policy. | `string` | `""` | no |
| <a name="input_iqn_static_identifier"></a> [iqn\_static\_identifier](#input\_iqn\_static\_identifier) | User provided static iSCSI Qualified Name (IQN) for use as initiator identifiers by iSCSI vNICs. | `string` | `""` | no |
| <a name="input_moids"></a> [moids](#input\_moids) | Flag to Determine if pools and policies should be data sources or if they already defined as a moid. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_pools"></a> [pools](#input\_pools) | Map for Moid based Pool Sources. | `any` | `{}` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Map for Moid based Policies Sources. | `any` | `{}` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | List of Profiles to Assign to the Policy.<br>* name - Name of the Profile to Assign.<br>* object\_type - Object Type to Assign in the Profile Configuration.<br>  - server.Profile - For UCS Server Profiles.<br>  - server.ProfileTemplate - For UCS Server Profile Templates. | <pre>list(object(<br>    {<br>      name        = string<br>      object_type = optional(string, "server.Profile")<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_target_platform"></a> [target\_platform](#input\_target\_platform) | The platform for which the server profile is applicable. It can either be:<br>* Standalone - a server that is operating independently<br>* FIAttached - A Server attached to a Intersight Managed Domain. | `string` | `"FIAttached"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
| <a name="input_vnic_placement_mode"></a> [vnic\_placement\_mode](#input\_vnic\_placement\_mode) | The mode used for placement of vNICs on network adapters. It can either be auto or custom. | `string` | `"custom"` | no |
| <a name="input_vnics"></a> [vnics](#input\_vnics) | List of VNICs to add to the LAN Connectivity Policy.<br>* cdn\_source - Source of the CDN. It can either be user specified or be the same as the vNIC name.<br>  1. user - Source of the CDN is specified by the user.<br>  2. vnic: (default) - Source of the CDN is the same as the vNIC name.<br>* cdn\_values: (default is []) - The CDN value(s) entered in case user defined mode.<br>* ethernet\_adapter\_policy: (required) - The Name of the Ethernet Adapter Policy to Assign to the vNIC.<br>* ethernet\_network\_control\_policy: (required) - The Name of the Ethernet Network Control Policy to Assign to the vNIC.<br>* ethernet\_network\_group\_policy: (optional) - The Name of the Ethernet Network Group Policy to Assign to the vNIC.  This Policy is for FIAttached Only.<br>* ethernet\_network\_policy: (optional) - The Name of the Ethernet Network Policy to Assign to the vNIC.  This is for Standalone Only.<br>* ethernet\_qos\_policy: (required) - The Name of the Ethernet QoS Policy to Assign to the vNIC.<br>* iscsi\_boot\_policy: (optional) - The Name of the iSCSI Boot Policy to Assign to the vNIC.<br>* mac\_address\_allocation\_type: (optional) - Type of allocation selected to assign a MAC address for the vnic.<br>  1. POOL: (default) - The user selects a pool from which the mac/wwn address will be leased for the Virtual Interface.<br>  2. STATIC - The user assigns a static mac/wwn address for the Virtual Interface.<br>* mac\_address\_pool: (optional list) - The Name of the MAC Address Pool to Assign to the vNIC(s).<br>* mac\_address\_static: (optional list) - The MAC address must be in hexadecimal format xx:xx:xx:xx:xx:xx.To ensure uniqueness of MACs in the LAN fabric, you are strongly encouraged to use thefollowing MAC prefix 00:25:B5:xx:xx:xx.<br>* names - Name of the vNIC(s).<br>* placement\_pci\_link: (default is [0]) - The PCI Link used as transport for the virtual interface. All VIC adapters have a single PCI link except VIC 1385 which has two.<br>* placement\_pci\_order: (default is [2, 3]) - The order in which the virtual interface is brought up. The order assigned to an interface should be unique for all the Ethernet and Fibre-Channel interfaces on each PCI link on a VIC adapter. The maximum value of PCI order is limited by the number of virtual interfaces (Ethernet and Fibre-Channel) on each PCI link on a VIC adapter. All VIC adapters have a single PCI link except VIC 1385 which has two.<br>* placement\_slot\_id: (default is [MLOM]) - PCIe Slot where the VIC adapter is installed. Supported values are (1-15) and MLOM.<br>* placement\_switch\_id - The fabric port to which the vNICs will be associated.<br>  1. A - Fabric A of the FI cluster.<br>  2. B - Fabric B of the FI cluster.<br>  3. None: (default) - Fabric Id is not set to either A or B for the standalone case where the server is not connected to Fabric Interconnects. The value 'None' should be used.<br>* placement\_uplink\_port: (default is [0]) - Adapter port on which the virtual interface will be created.  This attribute is for Standalone Servers Only.<br>* usnic\_adapter\_policy - Name of the Ethernet Adapter Policy to Assign to the uSNIC Settings.<br>* usnic\_class\_of\_service: (default is 5) - Class of Service to be used for traffic on the usNIC.  Valid Range is 0-6.<br>* usnic\_number\_of\_usnics: (default is 0) - Number of usNIC interfaces to be created.  Range is 0-255.<br>* vmq\_enable\_virtual\_machine\_multi\_queue -  Default is false.  Enables Virtual Machine Multi-Queue feature on the virtual interface. VMMQ allows configuration of multiple I/O queues for a single VM and thus distributes traffic across multiple CPU cores in a VM.<br>* vmq\_enabled: (default is false) - Enables VMQ feature on the virtual interface.<br>* vmq\_number\_of\_interrupts: (default is 16) - The number of interrupt resources to be allocated. Recommended value is the number of CPU threads or logical processors available in the server.  Range is 1-514.<br>* vmq\_number\_of\_sub\_vnics: (default is 64) - The number of sub vNICs to be created.  Range is 0-64.<br>* vmq\_number\_of\_virtual\_machine\_queues: (default is 4) - The number of hardware Virtual Machine Queues to be allocated. The number of VMQs per adapter must be one more than the maximum number of VM NICs.  Range is 1-128.<br>* vmq\_vmmq\_adapter\_policy -  Ethernet Adapter policy to be associated with the VMQ vNICs. The Transmit Queue and Receive Queue resource value of VMMQ adapter policy should be greater than or equal to the configured number of sub vNICs. | <pre>list(object(<br>    {<br>      cdn_source                             = optional(string, "vnic")<br>      cdn_values                             = optional(list(string), [])<br>      ethernet_adapter_policy                = string<br>      ethernet_network_control_policy        = string<br>      ethernet_network_group_policy          = optional(string)<br>      ethernet_network_policy                = optional(string)<br>      ethernet_qos_policy                    = string<br>      iscsi_boot_policy                      = optional(string, "")<br>      mac_address_allocation_type            = optional(string, "POOL")<br>      mac_address_pools                      = optional(list(string), [])<br>      mac_address_static                     = optional(list(string), [])<br>      names                                  = list(string)<br>      placement_pci_link                     = optional(list(number), [0])<br>      placement_pci_order                    = optional(list(string), [2, 3])<br>      placement_slot_id                      = optional(list(string), ["MLOM"])<br>      placement_switch_id                    = optional(string, "A")<br>      placement_uplink_port                  = optional(list(number), [0])<br>      usnic_adapter_policy                   = optional(string, "")<br>      usnic_class_of_service                 = optional(number, 5)<br>      usnic_number_of_usnics                 = optional(number, 0)<br>      vmq_enable_virtual_machine_multi_queue = optional(bool, false)<br>      vmq_enabled                            = optional(bool, false)<br>      vmq_number_of_interrupts               = optional(number, 16)<br>      vmq_number_of_sub_vnics                = optional(number, 64)<br>      vmq_number_of_virtual_machine_queues   = optional(number, 4)<br>      vmq_vmmq_adapter_policy                = optional(string, "")<br>    }<br>  ))</pre> | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | LAN Connectivity Policy Managed Object ID (moid). |
| <a name="output_vnics"></a> [vnics](#output\_vnics) | LAN Connectivity Policy vNIC(s) Moid(s). |
## Resources

| Name | Type |
|------|------|
| [intersight_vnic_eth_if.vnics](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_eth_if) | resource |
| [intersight_vnic_lan_connectivity_policy.lan_connectivity](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_lan_connectivity_policy) | resource |
| [intersight_fabric_eth_network_control_policy.ethernet_network_control](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_eth_network_control_policy) | data source |
| [intersight_fabric_eth_network_group_policy.ethernet_network_group](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_eth_network_group_policy) | data source |
| [intersight_iqnpool_pool.iqn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/iqnpool_pool) | data source |
| [intersight_macpool_pool.mac](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/macpool_pool) | data source |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
| [intersight_server_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile) | data source |
| [intersight_server_profile_template.templates](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile_template) | data source |
| [intersight_vnic_eth_adapter_policy.ethernet_adapter](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/vnic_eth_adapter_policy) | data source |
| [intersight_vnic_eth_network_policy.ethernet_network](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/vnic_eth_network_policy) | data source |
| [intersight_vnic_eth_qos_policy.ethernet_qos](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/vnic_eth_qos_policy) | data source |
| [intersight_vnic_iscsi_boot_policy.iscsi_boot](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/vnic_iscsi_boot_policy) | data source |
<!-- END_TF_DOCS -->