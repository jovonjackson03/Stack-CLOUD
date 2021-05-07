#Put Object in Web Bucket
resource "aws_s3_bucket_object" "object1" {
	bucket = aws_s3_bucket.web_bucket.id
	key    = "index.html"
	source = "C:/Apps/terraform/tf/index.html"
	acl = "public-read-write"
	force_destroy = true
}

resource "aws_s3_bucket_object" "object2" {
	bucket = aws_s3_bucket.web_bucket.id
	key    = "error.html"
	source = "C:/Apps/terraform/tf/error.html"
	acl = "public-read-write"
	force_destroy = true
}

resource "aws_s3_bucket_object" "object3" {
	bucket = aws_s3_bucket.web_bucket.id
	key    = "Stack_IT_Logo.png"
	source = "C:/Apps/terraform/tf/Stack_IT_Logo.png"
	acl = "public-read-write"
	force_destroy = true
}


