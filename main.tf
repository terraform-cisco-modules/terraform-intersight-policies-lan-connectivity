#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  for_each = {
    for v in [var.organization] : v => v if length(
      regexall("[[:xdigit:]]{24}", var.organization)
    ) == 0
  }
  name = each.value
}

data "intersight_iqnpool_pool" "iqn" {
  for_each = {
    for v in compact([var.iqn_pool]) : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

#____________________________________________________________
#
# Intersight UCS Server Profile(s) Data Source
# GUI Location: Profiles > UCS Server Profiles > {Name}
#____________________________________________________________

data "intersight_server_profile" "profiles" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.Profile" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight UCS Server Profile Template(s) Data Source
# GUI Location: Templates > UCS Server Profile Templates > {Name}
#__________________________________________________________________

data "intersight_server_profile_template" "templates" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.ProfileTemplate" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight LAN Connectivity Policy
# GUI Location: Policies > Create Policy > LAN Connectivity
#__________________________________________________________________

resource "intersight_vnic_lan_connectivity_policy" "lan_connectivity" {
  depends_on = [
    data.intersight_iqnpool_pool.iqn,
    data.intersight_server_profile.profiles,
    data.intersight_server_profile_template.templates,
    data.intersight_organization_organization.org_moid
  ]
  description         = var.description != "" ? var.description : "${var.name} LAN Connectivity Policy."
  azure_qos_enabled   = var.enable_azure_stack_host_qos
  iqn_allocation_type = var.iqn_allocation_type
  name                = var.name
  placement_mode      = var.vnic_placement_mode
  static_iqn_name     = var.iqn_static_identifier
  target_platform     = var.target_platform
  organization {
    moid = length(
      regexall("[[:xdigit:]]{24}", var.organization)
      ) > 0 ? var.organization : data.intersight_organization_organization.org_moid[
      var.organization].results[0
    ].moid
    object_type = "organization.Organization"
  }
  dynamic "iqn_pool" {
    for_each = toset(compact([var.iqn_pool]))
    content {
      moid = length(
        regexall("[[:xdigit:]]{24}", iqn_pool.value)
      ) > 0 ? iqn_pool.value : data.intersight_iqnpool_pool.iqn[iqn_pool.value].moid
    }
  }
  dynamic "profiles" {
    for_each = { for v in var.profiles : v.name => v }
    content {
      moid = length(regexall("server.ProfileTemplate", profiles.value.object_type)
        ) > 0 ? data.intersight_server_profile_template.templates[profiles.value.name].results[0
      ].moid : data.intersight_server_profile.profiles[profiles.value.name].results[0].moid
      object_type = profiles.value.object_type
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}


#_________________________________________________________________________
#
# LAN Connectivity Policy - Add vNIC(s)
# GUI Location: Configure > Policies > Create Policy > LAN Connectivity
#_________________________________________________________________________

locals {
  # Loop to Split vNICs defined as a Pair
  vnics = flatten([
    for v in var.vnics : [
      for s in range(length(v.names)) : {
        cdn_source                      = v.cdn_source
        cdn_value                       = length(v.cdn_values) > 0 ? element(v.cdn_values, s) : ""
        enable_failover                 = length(v.names) == 1 ? true : false
        ethernet_adapter_policy         = v.ethernet_adapter_policy
        ethernet_network_control_policy = v.ethernet_network_control_policy
        ethernet_network_group_policy   = v.ethernet_network_group_policy
        ethernet_network_policy         = v.ethernet_network_policy
        ethernet_qos_policy             = v.ethernet_qos_policy
        iscsi_boot_policy               = v.iscsi_boot_policy
        mac_address_allocation_type     = v.mac_address_allocation_type
        mac_address_pool                = length(v.mac_address_pools) > 0 ? element(v.mac_address_pools, s) : ""
        mac_address_static              = length(v.mac_address_statics) > 0 ? element(v.mac_address_statics, s) : ""
        name                            = element(v.names, s)
        placement_pci_link              = v.placement_pci_link
        placement_pci_order             = element(v.placement_pci_order, s)
        placement_slot_id               = v.placement_slot_id
        placement_switch_id = length(compact(
          [v.placement_switch_id])
        ) > 0 ? v.placement_switch_id : index(v.names, element([v.names], s)) == 0 ? "A" : "B"
        placement_uplink_port                  = v.placement_uplink_port
        usnic_adapter_policy                   = v.usnic_adapter_policy
        usnic_class_of_service                 = v.usnic_class_of_service
        usnic_number_of_usnics                 = v.usnic_number_of_usnics
        vmq_enable_virtual_machine_multi_queue = v.vmq_enable_virtual_machine_multi_queue
        vmq_enabled                            = v.vmq_enabled
        vmq_number_of_interrupts               = v.vmq_number_of_interrupts
        vmq_number_of_sub_vnics                = v.vmq_number_of_sub_vnics
        vmq_number_of_virtual_machine_queues   = v.vmq_number_of_virtual_machine_queues
        vmq_vmmq_adapter_policy                = v.vmq_vmmq_adapter_policy
      }
    ]
  ])

  ethernet_adapter_policies = toset(compact(flatten([
    for v in local.vnics : [v.ethernet_adapter_policy, v.usnic_adapter_policy]]))
  )
  ethernet_network_policies = toset(compact([for v in local.vnics : v.ethernet_network_policy]))
  ethernet_network_control_policies = toset(
    compact([for v in local.vnics : v.ethernet_network_control_policy])
  )
  ethernet_network_group_policies = toset(
    compact([for v in local.vnics : v.ethernet_network_group_policy])
  )
  ethernet_qos_policies = toset(compact([for v in local.vnics : v.ethernet_qos_policy]))
  iscsi_boot            = toset(compact([for v in local.vnics : v.iscsi_boot_policy]))
  mac_pools             = toset(compact([for v in local.vnics : v.mac_address_pool]))
}

data "intersight_fabric_eth_network_control_policy" "ethernet_network_control" {
  for_each = {
    for v in local.ethernet_network_control_policies : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_fabric_eth_network_group_policy" "ethernet_network_group" {
  for_each = {
    for v in local.ethernet_network_group_policies : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_macpool_pool" "mac" {
  for_each = {
    for v in local.mac_pools : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_vnic_eth_adapter_policy" "ethernet_adapter" {
  for_each = {
    for v in local.ethernet_adapter_policies : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
}

data "intersight_vnic_eth_network_policy" "ethernet_network" {
  for_each = {
    for v in local.ethernet_network_policies : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_vnic_eth_qos_policy" "ethernet_qos" {
  for_each = {
    for v in local.ethernet_qos_policies : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_vnic_iscsi_boot_policy" "iscsi_boot" {
  for_each = {
    for v in local.iscsi_boot : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

resource "intersight_vnic_eth_if" "vnics" {
  depends_on = [
    data.intersight_fabric_eth_network_control_policy.ethernet_network_control,
    data.intersight_fabric_eth_network_group_policy.ethernet_network_group,
    data.intersight_vnic_eth_adapter_policy.ethernet_adapter,
    data.intersight_vnic_eth_network_policy.ethernet_network,
    data.intersight_vnic_eth_qos_policy.ethernet_qos,
    data.intersight_vnic_iscsi_boot_policy.iscsi_boot,
    intersight_vnic_lan_connectivity_policy.lan_connectivity
  ]
  for_each         = { for v in local.vnics : v.name => v }
  failover_enabled = each.value.enable_failover
  mac_address_type = each.value.mac_address_allocation_type
  name             = each.key
  order            = each.value.placement_pci_order
  static_mac_address = length(regexall("STATIC", each.value.mac_address_allocation_type)
  ) > 0 ? each.value.mac_address_static : null
  cdn {
    value     = each.value.cdn_source == "user" ? each.value.cdn_value : each.key
    nr_source = each.value.cdn_source
  }
  eth_adapter_policy {
    moid = length(
      regexall("[[:xdigit:]]{24}", each.value.ethernet_adapter_policy)
      ) > 0 ? each.value.ethernet_adapter_policy : data.intersight_vnic_eth_adapter_policy.ethernet_adapter[
      each.value.ethernet_adapter_policy
    ].results[0].moid
  }
  eth_qos_policy {
    moid = length(
      regexall("[[:xdigit:]]{24}", each.value.ethernet_qos_policy)
      ) > 0 ? each.value.ethernet_qos_policy : data.intersight_vnic_eth_qos_policy.ethernet_qos[
      each.value.ethernet_qos_policy
    ].results[0].moid
  }
  fabric_eth_network_control_policy {
    moid = length(
      regexall("[[:xdigit:]]{24}", each.value.ethernet_network_control_policy)
      ) > 0 ? each.value.ethernet_network_control_policy : data.intersight_fabric_eth_network_control_policy.ethernet_network_control[
      each.value.ethernet_network_control_policy
    ].results[0].moid
  }
  lan_connectivity_policy {
    moid = intersight_vnic_lan_connectivity_policy.lan_connectivity.moid
  }
  placement {
    id        = each.value.placement_slot_id
    pci_link  = each.value.placement_pci_link
    switch_id = each.value.placement_switch_id
    uplink    = each.value.placement_uplink_port
  }
  usnic_settings {
    cos      = each.value.usnic_class_of_service
    nr_count = each.value.usnic_number_of_usnics
    usnic_adapter_policy = length(
      regexall("[a-zA-Z0-9]+", each.value.usnic_adapter_policy)
      ) > 0 ? length(
      regexall("[[:xdigit:]]{24}", each.value.usnic_adapter_policy)
      ) > 0 ? each.value.usnic_adapter_policy : data.intersight_vnic_eth_adapter_policy.ethernet_adapter[
      each.value.usnic_adapter_policy
    ].results[0].moid : ""
  }
  vmq_settings {
    enabled             = each.value.vmq_enabled
    multi_queue_support = each.value.vmq_enable_virtual_machine_multi_queue
    num_interrupts      = each.value.vmq_number_of_interrupts
    num_vmqs            = each.value.vmq_number_of_virtual_machine_queues
    num_sub_vnics       = each.value.vmq_number_of_sub_vnics
    vmmq_adapter_policy = length(
      regexall("[a-zA-Z0-9]+", each.value.vmq_vmmq_adapter_policy)
      ) > 0 ? length(
      regexall("[[:xdigit:]]{24}", each.value.vmq_vmmq_adapter_policy)
      ) > 0 ? each.value.vmq_vmmq_adapter_policy : data.intersight_vnic_eth_adapter_policy.ethernet_adapter[
      each.value.vmq_vmmq_adapter_policy
    ].results[0].moid : ""
  }
  dynamic "eth_network_policy" {
    for_each = { for v in compact([each.value.ethernet_network_policy]) : v => v }
    content {
      moid = length(
        regexall("[[:xdigit:]]{24}", eth_network_policy.value)
        ) > 0 ? eth_network_policy.value : data.intersight_vnic_eth_network_policy.ethernet_network[
        eth_network_policy.value
      ].results[0].moid
    }
  }
  dynamic "fabric_eth_network_group_policy" {
    for_each = { for v in compact([each.value.ethernet_network_group_policy]) : v => v }
    content {
      moid = length(
        regexall("[[:xdigit:]]{24}", fabric_eth_network_group_policy.value)
        ) > 0 ? fabric_eth_network_group_policy.value : data.intersight_fabric_eth_network_group_policy.ethernet_network_group[
        fabric_eth_network_group_policy.value
      ].results[0].moid
    }
  }
  dynamic "iscsi_boot_policy" {
    for_each = { for v in compact([each.value.iscsi_boot_policy]) : v => v }
    content {
      moid = data.intersight_vnic_iscsi_boot_policy.iscsi_boot[
        iscsi_boot_policy.value
      ].results[0].moid

    }
  }
  dynamic "mac_pool" {
    for_each = {
      for v in compact(
        [each.value.mac_address_pool]
      ) : v => v if each.value.mac_address_allocation_type == "POOL"
    }
    content {
      moid = length(
        regexall("[[:xdigit:]]{24}", mac_pool.value)
      ) > 0 ? mac_pool.value : data.intersight_macpool_pool.mac[mac_pool.value].results[0].moid
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
