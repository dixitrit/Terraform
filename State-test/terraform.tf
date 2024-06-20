terraform {
  required_version = ">= 1.2 "
  backend "s3" {
    #Remote Backend
    #Deployed Region of S3 bucket and dynamoDB
    region = "ca-central-1"

    #S3 Bucket name that we have created in 1 step
    bucket = "remote-backend-terra-bucket"

    #State file location on S3
    key    = "tf-state/main-backend.tfstate"

    #State-Locking
    #DynamoDB table name that we have created in 1 step
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
}

/*
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.46"
    }
  }
*/
}

