data "intersight_organization_organization" "org_moid" {
  name = "terratest"
}

module "mac_pool" {
  source           = "terraform-cisco-modules/pools-mac/intersight"
  version          = ">=1.0.5"
  assignment_order = "sequential"
  mac_blocks = [
    {
      from = "00:25:B5:F0:00:00"
      size = 1000
    }
  ]
  name         = var.name
  organization = "terratest"
}

module "ethernet_adapter" {
  source  = "terraform-cisco-modules/policies-ethernet-adapter/intersight"
  version = ">=1.0.2"

  adapter_template = "VMware"
  name             = var.name
  organization     = "terratest"
}

module "ethernet_network_group" {
  source  = "terraform-cisco-modules/policies-ethernet-network-control/intersight"
  version = ">=1.0.2"

  cdp_enable   = true
  name         = var.name
  organization = "terratest"
}

module "ethernet_network_group" {
  source  = "terraform-cisco-modules/policies-ethernet-network-group/intersight"
  version = ">=1.0.2"

  allowed_vlans = "1-5"
  name          = var.name
  organization  = "terratest"
  native_vlan   = 5
}

module "ethernet_qos" {
  source  = "terraform-cisco-modules/policies-ethernet-qos/intersight"
  version = ">=1.0.2"

  name         = var.name
  organization = "terratest"
  priority     = "Platinum"
}

module "main" {
  source                      = "../.."
  description                 = "${var.name} LAN Connectivity Policy."
  enable_azure_stack_host_qos = false
  iqn_allocation_type         = "None"
  moids                       = true
  name                        = var.name
  organization                = data.intersight_organization_organization.org_moid.results[0].moid
  policies = {
    ethernet_adapter = {
      "${var.name}" = {
        moid = module.ethernet_adapter.moid
      }
    }
    ethernet_network_control = {
      "${var.name}" = {
        moid = module.ethernet_network_control.moid
      }
    }
    ethernet_network_group = {
      "${var.name}" = {
        moid = module.ethernet_network_group.moid
      }
    }
    ethernet_qos = {
      "${var.name}" = {
        moid = module.ethernet_qos.moid
      }
    }
  }
  pools = {
    mac = {
      "${var.name}" = {
        moid = module.mac_pool.moid
      }
    }
  }
  target_platform     = "FIAttached"
  vnic_placement_mode = "custom"
  vnics = [
    {
      cdn_source                      = "vnic"
      ethernet_adapter_policy         = var.name
      ethernet_network_control_policy = var.name
      ethernet_network_group_policy   = var.name
      ethernet_qos_policy             = var.name
      mac_address_allocation_type     = "POOL"
      mac_address_pools               = [var.name, var.name]
      names                           = ["MGMT-A", "MGMT-B"]
      placement_pci_order             = [2, 3]
      placement_slot_id               = ["MLOM"]
    }
  ]
}

output "ethernet_adapter" {
  value = module.ethernet_adapter.moid
}

output "ethernet_network_control" {
  value = module.ethernet_network_control.moid
}

output "ethernet_network_group" {
  value = module.ethernet_network_group.moid
}

output "ethernet_qos" {
  value = module.ethernet_qos.moid
}

output "mac_pool" {
  value = module.mac_pool.moid
}

output "MGMT-A" {
  value = module.main.vnics["MGMT-A"]
}