provider "aws" {
   region = "ca-central-1"
}
resource "aws_eip" "elasticIP" {
  domain   = "vpc"
}
