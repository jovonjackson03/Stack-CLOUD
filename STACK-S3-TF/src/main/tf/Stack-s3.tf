resource "aws_s3_bucket" "b" {
	bucket = "stackbucktf-jovon"
	acl = "public-read"

	tags = {
		Name	= "Stack CSA"
		Environment = "Production"
	}
}