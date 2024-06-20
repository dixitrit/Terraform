variable "region" {
   description = "AWS Deployment region"
   default = "ca-central-1"
}
variable "bucket_name" {
   type = string
   description = "Remote state Backup Bucket"
}
variable "table_name" {
   type = string
   description = "State locking DynamoDB Table"
}
variable "ami" {
    description = "Provide ami value"
}
