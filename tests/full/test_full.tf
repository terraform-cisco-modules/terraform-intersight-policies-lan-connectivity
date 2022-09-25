terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
}

module "main" {
  source           = "../.."
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

data "intersight_fcpool_pool" "wwpn_pool" {
  depends_on = [
    module.main
  ]
  name = "default"
}

resource "test_assertions" "wwpn_pool" {
  component = "wwpn_pool"

  # equal "description" {
  #   description = "description"
  #   got         = data.intersight_fcpool_pool.wwpn_pool.description
  #   want        = "Demo WWPN Pool"
  # }
  # 
  # equal "name" {
  #   description = "name"
  #   got         = data.intersight_fcpool_pool.wwpn_pool.name
  #   want        = "default"
  # }

}