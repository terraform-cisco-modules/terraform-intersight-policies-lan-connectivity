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
      enable_failover                 = false
      ethernet_adapter_policy         = "default"
      ethernet_network_control_policy = "default"
      ethernet_network_group_policy   = "default"
      ethernet_qos_policy             = "default"
      mac_address_allocation_type     = "POOL"
      mac_address_pool                = "default"
      name                            = "MGMT-A"
      placement_pci_link              = 0
      placement_pci_order             = 2
      placement_slot_id               = "MLOM"
      placement_switch_id             = "A"
    }
  ]
}
