#Put Object in Web Bucket
resource "aws_s3_bucket_object" "object1" {
	bucket = aws_s3_bucket.web_bucket.id
	key    = "index.html"
	source = "C:/Apps/terraform/tf/STACK-S3-TF/index.html"
	acl = "public-read-write"
	force_destroy = true
	kms_key_id = aws_kms_key.mykey.arn
}

resource "aws_s3_bucket_object" "object2" {
	bucket = aws_s3_bucket.web_bucket.id
	key    = "error.html"
	source = "C:/Apps/terraform/tf/STACK-S3-TF/error.html"
	acl = "public-read-write"
	force_destroy = true
	kms_key_id = aws_kms_key.mykey.arn
}

resource "aws_s3_bucket_object" "object3" {
	bucket = aws_s3_bucket.web_bucket.id
	key    = "Stack_IT_Logo.png"
	source = "C:/Apps/terraform/tf/STACK-S3-TF/Stack_IT_Logo.png"
	acl = "public-read-write"
	force_destroy = true
	kms_key_id = aws_kms_key.mykey.arn
}


