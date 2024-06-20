resource "aws_instance" "ritesh" {
  instance_type = "t2.micro"
  ami = "ami-0f5d6de5da0f4ec33"
  subnet_id = "subnet-038ef531a79405264"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "ritesh-backend-test"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
 # billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
