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
  source       = "../.."
  organization = "default"
  name         = "test"
}
