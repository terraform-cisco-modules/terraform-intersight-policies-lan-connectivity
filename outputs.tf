#____________________________________________________________
#
# Collect the moid of the LAN Connectivity Policy
#____________________________________________________________

output "moid" {
  description = "LAN Connectivity Policy Managed Object ID (moid)."
  value       = intersight_vnic_lan_connectivity_policy.lan_connectivity.moid
}

output "vnics" {
  description = "LAN Connectivity Policy vNIC(s) Moid(s)."
  value = {
    for v in sort(keys(intersight_vnic_eth_if.vnics)
    ) : v => intersight_vnic_eth_if.vnics[v].moid
  }
}
