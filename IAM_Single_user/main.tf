resource "aws_iam_user" "dev-user" {
      name = "utkarsh"
      tags = {
       Description = "New Member",
       EC2-Permission = "EC2-readonly"
       S3-Permission = "S3-readonly"
       RDS-Permission = "RDS-readonly"
    }
}

resource "aws_iam_policy" "ec2-read" {
name = "EC2_readonly"
policy = <<EOF
{
          "Version" : "2012-10-17",
          "Statement" : [
            {
                "Effect" : "Allow",
                "Action" : [
                      "ec2:Describee*",
                      "ec2:Get*",
                      "ec2:List*"
                    ],
                "Resource" : "*"
           }
       ]
     }
EOF
}
resource "aws_iam_policy" "s3-read" {
    name = "s3-readonly"
    policy = file("s3-read_policy.json")
}

resource "aws_iam_user_policy_attachment" "utkarsh-ec2-read" {
    user = aws_iam_user.dev-user.name
    policy_arn = aws_iam_policy.ec2-read.arn
}

resource "aws_iam_user_policy_attachment" "utkarsh-s3-read" {
    user = aws_iam_user.dev-user.name
    policy_arn = aws_iam_policy.s3-read.arn
}

resource "aws_iam_user_policy_attachment" "utkarsh-RDS-read" {
   user = aws_iam_user.dev-user.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}
