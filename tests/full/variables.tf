variable "apikey" {
  sensitive = true
}

variable "endpoint" {
  default = "intersight.com"
}

variable "name" {}

variable "secretkeyfile" {
  sensitive = true
}
