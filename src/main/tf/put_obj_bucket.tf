#Put Object in Web Bucket
resource "aws_s3_bucket_object" "object1" {
	bucket = "s3-website-jovon"
	key    = "index.html"
	source = "C:/Apps/terraform/tf/index.html"
	acl = "public-read"
	force_destroy = true
	kms_key_id = aws_kms_key.mykey.arn
}

resource "aws_s3_bucket_object" "object2" {
	bucket = "s3-website-jovon"
	key    = "error.html"
	source = "C:/Apps/terraform/tf/error.html"
	acl = "public-read"
	force_destroy = true
	kms_key_id = aws_kms_key.mykey.arn
}

resource "aws_s3_bucket_object" "object3" {
	bucket = "s3-website-jovon"
	key    = "Stack_IT_Logo.png"
	source = "C:/Apps/terraform/tf/Stack_IT_Logo.png"
	acl = "public-read"
	force_destroy = true
	kms_key_id = aws_kms_key.mykey.arn
}


