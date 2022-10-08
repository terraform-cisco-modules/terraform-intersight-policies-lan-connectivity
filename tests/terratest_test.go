package test

import (
	"fmt"
	"os"
	"testing"

	iassert "github.com/cgascoig/intersight-simple-go/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFull(t *testing.T) {
	//========================================================================
	// Setup Terraform options
	//========================================================================

	// Generate a unique name for objects created in this test to ensure we don't
	// have collisions with stale objects
	uniqueId := random.UniqueId()
	instanceName := fmt.Sprintf("test-policies-lan-con-%s", uniqueId)

	// Input variables for the TF module
	vars := map[string]interface{}{
		"apikey":        os.Getenv("IS_KEYID"),
		"secretkeyfile": os.Getenv("IS_KEYFILE"),
		"name":          instanceName,
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./full",
		Vars:         vars,
	})

	//========================================================================
	// Init and apply terraform module
	//========================================================================
	defer terraform.Destroy(t, terraformOptions) // defer to ensure that TF destroy happens automatically after tests are completed
	terraform.InitAndApply(t, terraformOptions)
	ethernet_adapter := terraform.Output(t, terraformOptions, "ethernet_adapter")
	ethernet_network_control := terraform.Output(t, terraformOptions, "ethernet_network_control")
	ethernet_network_group := terraform.Output(t, terraformOptions, "ethernet_network_group")
	ethernet_qos := terraform.Output(t, terraformOptions, "ethernet_qos")
	mac_pool := terraform.Output(t, terraformOptions, "mac_pool")
	moid := terraform.Output(t, terraformOptions, "moid")
	vnic := terraform.Output(t, terraformOptions, "MGMT-A")
	assert.NotEmpty(t, ethernet_adapter, "TF module ethernet_adapter moid output should not be empty")
	assert.NotEmpty(t, ethernet_network_control, "TF module ethernet_network_control moid output should not be empty")
	assert.NotEmpty(t, ethernet_network_group, "TF module ethernet_network_group moid output should not be empty")
	assert.NotEmpty(t, ethernet_qos, "TF module ethernet_qos moid output should not be empty")
	assert.NotEmpty(t, mac_pool, "TF module mac_pool moid output should not be empty")
	assert.NotEmpty(t, moid, "TF module moid output should not be empty")
	assert.NotEmpty(t, vnic, "TF module vnic moid output should not be empty")

	// Input variables for the TF module
	vars2 := map[string]interface{}{
		"ethernet_adapter":         ethernet_adapter,
		"ethernet_network_control": ethernet_network_control,
		"ethernet_network_group":   ethernet_network_group,
		"ethernet_qos":             ethernet_qos,
		"lan_connectivity":         moid,
		"mac_pool":                 mac_pool,
		"name":                     instanceName,
		"vnic_name":                "MGMT-A",
	}

	//========================================================================
	// Make Intersight API call(s) to validate module worked
	//========================================================================

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedJSONTemplate := `
{
	"Name":        "{{ .name }}",
	"Description": "{{ .name }} LAN Connectivity Policy.",

	"AzureQosEnabled": false,
	"IqnAllocationType": "None",
	"IqnPool": null,
	"PlacementMode": "custom",
	"StaticIqnName": "",
	"TargetPlatform": "FIAttached"
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/vnic/LanConnectivityPolicies/%s", moid), expectedJSONTemplate, vars2)

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedVNICTemplate := `
{
  "Name":        "{{ .vnic_name }}",

  "Cdn": {
    "ClassId": "vnic.Cdn",
    "ObjectType": "vnic.Cdn",
    "Source": "vnic",
    "Value": "{{ .vnic_name }}"
  },
  "EthAdapterPolicy": {
    "ClassId": "mo.MoRef",
    "Moid": "{{ .ethernet_adapter }}",
    "ObjectType": "vnic.EthAdapterPolicy",
    "link": "https://www.intersight.com/api/v1/vnic/EthAdapterPolicies/{{ .ethernet_adapter }}"
  },
  "EthQosPolicy": {
    "ClassId": "mo.MoRef",
    "Moid": "{{ .ethernet_qos }}",
    "ObjectType": "vnic.EthQosPolicy",
    "link": "https://www.intersight.com/api/v1/vnic/EthQosPolicies/{{ .ethernet_qos }}"
  },
  "FabricEthNetworkControlPolicy": {
    "ClassId": "mo.MoRef",
    "Moid": "{{ .ethernet_network_control }}",
    "ObjectType": "fabric.EthNetworkControlPolicy",
    "link": "https://www.intersight.com/api/v1/fabric/EthNetworkControlPolicies/{{ .ethernet_network_control }}"
  },
  "FabricEthNetworkGroupPolicy": [
    {
      "ClassId": "mo.MoRef",
      "Moid": "{{ .ethernet_network_group }}",
      "ObjectType": "fabric.EthNetworkGroupPolicy",
      "link": "https://www.intersight.com/api/v1/fabric/EthNetworkGroupPolicies/{{ .ethernet_network_group }}"
    }
  ],
  "FailoverEnabled": false,
  "IscsiBootPolicy": null,
  "IscsiIpV4AddressAllocationType": "None",
  "IscsiIpV4Config": {
    "ClassId": "ippool.IpV4Config",
    "Gateway": "",
    "Netmask": "",
    "ObjectType": "ippool.IpV4Config",
    "PrimaryDns": "",
    "SecondaryDns": ""
  },
  "IscsiIpv4Address": "",
  "LanConnectivityPolicy": {
    "ClassId": "mo.MoRef",
    "Moid": "{{ .lan_connectivity }}",
    "ObjectType": "vnic.LanConnectivityPolicy",
    "link": "https://www.intersight.com/api/v1/vnic/LanConnectivityPolicies/{{ .lan_connectivity }}"
  },
  "LcpVnic": null,
  "MacAddress": "",
  "MacAddressType": "POOL",
  "MacPool": {
    "ClassId": "mo.MoRef",
    "Moid": "{{ .mac_pool }}",
    "ObjectType": "macpool.Pool",
    "link": "https://www.intersight.com/api/v1/macpool/Pools/{{ .mac_pool }}"
  },
  "Order": 2,
  "Placement": {
    "AutoPciLink": false,
    "AutoSlotId": false,
    "ClassId": "vnic.PlacementSettings",
    "Id": "MLOM",
    "ObjectType": "vnic.PlacementSettings",
    "PciLink": 0,
    "SwitchId": "A",
    "Uplink": 0
  },
  "StandbyVifId": 0,
  "StaticMacAddress": "",
  "UsnicSettings": {
    "ClassId": "vnic.UsnicSettings",
    "Cos": 5,
    "Count": 0,
    "ObjectType": "vnic.UsnicSettings",
    "UsnicAdapterPolicy": ""
  },
  "VifId": 0,
  "VmqSettings": {
    "ClassId": "vnic.VmqSettings",
    "Enabled": false,
    "MultiQueueSupport": false,
    "NumInterrupts": 16,
    "NumSubVnics": 64,
    "NumVmqs": 4,
    "ObjectType": "vnic.VmqSettings",
    "VmmqAdapterPolicy": ""
	}
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/vnic/EthIfs/%s", vnic), expectedVNICTemplate, vars2)
}
