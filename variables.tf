# variables.tf

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["ca-central-1a", "ca-central-1b"]
}
