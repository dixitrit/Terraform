terraform {
  backend "s3" {
    bucket         = "ritesh-backend-test"
    key            = "data/Terraform/backend_project/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
