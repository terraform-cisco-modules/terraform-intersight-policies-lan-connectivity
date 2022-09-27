#____________________________________________________________
#
# LAN Connectivity Policy Variables Section.
#____________________________________________________________

variable "description" {
  default     = ""
  description = "Description for the Policy."
  type        = string
}

variable "enable_azure_stack_host_qos" {
  default     = false
  description = "Enabling AzureStack-Host QoS on an adapter allows the user to carve out traffic classes for RDMA traffic which ensures that a desired portion of the bandwidth is allocated to it."
  type        = bool
}

variable "iqn_allocation_type" {
  default     = "None"
  description = <<-EOT
    Allocation Type of iSCSI Qualified Name.  Options are:
    * None
    * Pool
    * Static
  EOT
  type        = string
}

variable "iqn_pool" {
  default     = ""
  description = "IQN Pool to Assign to the Policy."
  type        = string
}

variable "iqn_static_identifier" {
  default     = ""
  description = "User provided static iSCSI Qualified Name (IQN) for use as initiator identifiers by iSCSI vNICs."
  type        = string
}

variable "name" {
  default     = "lan_connectivity"
  description = "Name for the Policy."
  type        = string
}

variable "organization" {
  default     = "default"
  description = "Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/."
  type        = string
}

variable "profiles" {
  default     = []
  description = <<-EOT
    List of Profiles to Assign to the Policy.
    * name - Name of the Profile to Assign.
    * object_type - Object Type to Assign in the Profile Configuration.
      - server.Profile - For UCS Server Profiles.
      - server.ProfileTemplate - For UCS Server Profile Templates.
  EOT
  type = list(object(
    {
      name        = string
      object_type = optional(string, "server.Profile")
    }
  ))
}

variable "target_platform" {
  default     = "FIAttached"
  description = <<-EOT
    The platform for which the server profile is applicable. It can either be:
    * Standalone - a server that is operating independently
    * FIAttached - A Server attached to a Intersight Managed Domain.
  EOT
  type        = string
}

variable "tags" {
  default     = []
  description = "List of Tag Attributes to Assign to the Policy."
  type        = list(map(string))
}

variable "vnic_placement_mode" {
  default     = "custom"
  description = "The mode used for placement of vNICs on network adapters. It can either be auto or custom."
  type        = string
}

#____________________________________________________________
#
# LAN Connectivity - Add vNIC Variables Section.
#____________________________________________________________

variable "vnics" {
  default     = []
  description = <<-EOT
    List of VNICs to add to the LAN Connectivity Policy.
    * cdn_source - Default is vnic.  Source of the CDN. It can either be user specified or be the same as the vNIC name.
      1. user - Source of the CDN is specified by the user.
      2. vnic - Source of the CDN is the same as the vNIC name.
    * cdn_values - The CDN value(s) entered in case user defined mode.
    * ethernet_adapter_policy - The Name of the Ethernet Adapter Policy to Assign to the vNIC.
    * ethernet_network_control_policy - The Name of the Ethernet Network Control Policy to Assign to the vNIC.
    * ethernet_network_group_policy - The Name of the Ethernet Network Group Policy to Assign to the vNIC.  This Policy is for FIAttached Only.
    * ethernet_network_policy - The Name of the Ethernet Network Policy to Assign to the vNIC.  This is for Standalone Only.
    * ethernet_qos_policy - The Name of the Ethernet QoS Policy to Assign to the vNIC.
    * iscsi_boot_policy - The Name of the iSCSI Boot Policy to Assign to the vNIC.
    * mac_address_allocation_type - Default is POOL.  Type of allocation selected to assign a MAC address for the vnic.
      1. POOL - The user selects a pool from which the mac/wwn address will be leased for the Virtual Interface.
      2. STATIC - The user assigns a static mac/wwn address for the Virtual Interface.
    * mac_address_pool - The Name of the MAC Address Pool to Assign to the vNIC.
    * mac_address_static - The MAC address must be in hexadecimal format xx:xx:xx:xx:xx:xx.To ensure uniqueness of MACs in the LAN fabric, you are strongly encouraged to use thefollowing MAC prefix 00:25:B5:xx:xx:xx.
    * name - Name of the vNIC.
    * placement_pci_link - Default is 0.  The PCI Link used as transport for the virtual interface. All VIC adapters have a single PCI link except VIC 1385 which has two.
    * placement_pci_order: (default is [2, 3]) - The order in which the virtual interface is brought up. The order assigned to an interface should be unique for all the Ethernet and Fibre-Channel interfaces on each PCI link on a VIC adapter. The maximum value of PCI order is limited by the number of virtual interfaces (Ethernet and Fibre-Channel) on each PCI link on a VIC adapter. All VIC adapters have a single PCI link except VIC 1385 which has two.
    * placement_slot_id - Default is MLOM.  PCIe Slot where the VIC adapter is installed. Supported values are (1-15) and MLOM.
    * placement_switch_id - Default is None.  The fabric port to which the vNICs will be associated.
      1. A - Fabric A of the FI cluster.
      2. B - Fabric B of the FI cluster.
      3. None - Fabric Id is not set to either A or B for the standalone case where the server is not connected to Fabric Interconnects. The value 'None' should be used.
    * placement_uplink_port - Default is 0.  Adapter port on which the virtual interface will be created.  This attribute is for Standalone Servers Only.
    * usnic_adapter_policy - Name of the Ethernet Adapter Policy to Assign to the uSNIC Settings.
    * usnic_class_of_service -  Default is 5.  Class of Service to be used for traffic on the usNIC.  Valid Range is 0-6.
    * usnic_number_of_usnics -  Default is 0.  Number of usNIC interfaces to be created.  Range is 0-255.
    * vmq_enable_virtual_machine_multi_queue -  Default is false.  Enables Virtual Machine Multi-Queue feature on the virtual interface. VMMQ allows configuration of multiple I/O queues for a single VM and thus distributes traffic across multiple CPU cores in a VM.
    * vmq_enabled -Default is false.  Enables VMQ feature on the virtual interface.
    * vmq_number_of_interrupts -  Default is 16.  The number of interrupt resources to be allocated. Recommended value is the number of CPU threads or logical processors available in the server.  Range is 1-514.
    * vmq_number_of_sub_vnics -  Default is 64.  The number of sub vNICs to be created.  Range is 0-64.
    * vmq_number_of_virtual_machine_queues -  Default is 4.  The number of hardware Virtual Machine Queues to be allocated. The number of VMQs per adapter must be one more than the maximum number of VM NICs.  Range is 1-128.
    * vmq_vmmq_adapter_policy -  Ethernet Adapter policy to be associated with the VMQ vNICs. The Transmit Queue and Receive Queue resource value of VMMQ adapter policy should be greater than or equal to the configured number of sub vNICs.
  EOT
  type = list(object(
    {
      cdn_source                             = optional(string, "vnic")
      cdn_values                             = optional(list(string), [])
      ethernet_adapter_policy                = string
      ethernet_network_control_policy        = string
      ethernet_network_group_policy          = optional(string)
      ethernet_network_policy                = optional(string)
      ethernet_qos_policy                    = string
      iscsi_boot_policy                      = optional(string, "")
      mac_address_allocation_type            = optional(string, "POOL")
      mac_address_pools                      = optional(list(string), [])
      mac_address_static                     = optional(list(string), [])
      names                                  = list(string)
      placement_pci_link                     = optional(number, 0)
      placement_pci_order                    = optional(list(string), [2, 3])
      placement_slot_id                      = optional(string, "MLOM")
      placement_switch_id                    = optional(string, "A")
      placement_uplink_port                  = optional(number, 0)
      usnic_adapter_policy                   = optional(string, "")
      usnic_class_of_service                 = optional(number, 5)
      usnic_number_of_usnics                 = optional(number, 0)
      vmq_enable_virtual_machine_multi_queue = optional(bool, false)
      vmq_enabled                            = optional(bool, false)
      vmq_number_of_interrupts               = optional(number, 16)
      vmq_number_of_sub_vnics                = optional(number, 64)
      vmq_number_of_virtual_machine_queues   = optional(number, 4)
      vmq_vmmq_adapter_policy                = optional(string, "")
    }
  ))
}

