resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-tf-log-bucket"
  acl    = "log-delivery-write"
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 20
}

resource "aws_s3_bucket" "b" {
	bucket = "stackbucktf-jovon"

	acl    = "public-read"

	tags = {
	Name        = "Stack CSA"
	Environment = "Production"
	}

	versioning {
	enabled = true
	}

	lifecycle {
	# Any Terraform plan that includes a destroy of this resource will
	# result in an error message.
	prevent_destroy = true
	}

	server_side_encryption_configuration {
	rule {
	apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
	logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
}



  