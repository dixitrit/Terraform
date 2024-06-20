resource "aws_iam_user" "new-users" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
  tags = {
    Description    = "New Members",
    EC2-Permission = "EC2-readonly"
    S3-Permission  = "S3-readonly"
    RDS-Permission = "RDS-readonly"
  }
}

resource "aws_iam_policy" "ec2-read" {
  name = "EC2_readonly"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3-read" {
  name   = "s3-readonly"
  policy = file("s3-read_policy.json")
}

resource "aws_iam_user_policy_attachment" "ec2-read-attach" {
  count      = length(var.user_names)
  user       = aws_iam_user.new-users[count.index].name
  policy_arn = aws_iam_policy.ec2-read.arn
}

resource "aws_iam_user_policy_attachment" "s3-read-attach" {
  count      = length(var.user_names)
  user       = aws_iam_user.new-users[count.index].name
  policy_arn = aws_iam_policy.s3-read.arn
}

resource "aws_iam_user_policy_attachment" "RDS-read-attach" {
  count      = length(var.user_names)
  user       = aws_iam_user.new-users[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}
