#Create User
resource "aws_iam_user" "user" {
  name          = "stackuser1"
  path          = "/"
  force_destroy = true
  permissions_boundary          = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

##Create User login credentials
resource "aws_iam_user_login_profile" "log-prof" {
  user    = aws_iam_user.user.name
  pgp_key = "keybase:jovonjackson"
  password_reset_required = true
}

#Output Encrypted Password
output "password" {
  value = aws_iam_user_login_profile.log-prof.encrypted_password
}

#Create Group
resource "aws_iam_group" "group" {
  name = "stack-group"
}

#Create Policy with S3 EC2 IAM full access
resource "aws_iam_policy" "policy" {
  name        = "stack-iam_ec2_s3"
  description = "A policy that gives iam, ec2, and s3 access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    { 
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOF
}

#Attach Policy to Group
resource "aws_iam_policy_attachment" "stack-attach" {
  name       = "stack-attachment"
  groups     = [aws_iam_group.group.name]
  policy_arn = aws_iam_policy.policy.arn
}

#Add User to Group
resource "aws_iam_group_membership" "team" {
  name = "stack-group-membership"
  users = [aws_iam_user.user.name]
  group = aws_iam_group.group.name
}


/*
#Enable MFA
module "aws_mfa" {
  source = "trussworks/mfa/aws"
  iam_groups = aws_iam_group.group.name
  iam_users  = aws_iam_user.user.name
}
*/