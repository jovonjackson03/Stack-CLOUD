#create bucket
resource "aws_s3_bucket" "b" {
	bucket = "stackbucktf-jovon"
	acl = "public-read-write"
	tags = {
	Name = "Stack CSA"
	Environment = "Production"}
	force_destroy = true
	policy = file("static_web_policy.json")
	
#Enable versioning
	versioning {
	enabled = true
	}

#Enable Acceleration Status
	acceleration_status = "Enabled"

#Enable Object Lock
	object_lock_configuration {
    object_lock_enabled = "Enabled"
	}

#configure bucket encryption
	server_side_encryption_configuration {
	rule {
	apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
    }
    }
}

#enable server access logging
	logging {
		target_bucket = aws_s3_bucket.server_access_log_bucket.id
		target_prefix = "log/"
	}

#lifecycle
	lifecycle {
        prevent_destroy = false
    }

#lifecycle rule
	lifecycle_rule {
	prefix  = "config/"
    enabled = true

    noncurrent_version_transition {
    days          = 30
    storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
    days          = 60
    storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
    days = 90
    }
	}

#Redirect Bucket Requests to Static Website Hosting Bucket
	website {
		redirect_all_requests_to = "https://www.stackittraining.com/"
	}
}

#Static Website Bucket Host
resource "aws_s3_bucket" "web_bucket" {
	bucket = "s3-website-jovon"
	acl = "public-read-write"
	force_destroy = true
	policy = file("static_web_policy_test.json")

	website {
    index_document = "index.html"
    error_document = "error.html"
	}

#enable server access logging
	logging {
		target_bucket = aws_s3_bucket.server_access_log_bucket.id
		target_prefix = "log/"
	}

#lifecycle
	lifecycle {
        prevent_destroy = false
    }

}

#create a server access log bucket
resource "aws_s3_bucket" "server_access_log_bucket" {
	bucket = "mytfserveraccesslogbucketjovon"
	acl = "log-delivery-write"
	force_destroy = true

#lifecycle
	lifecycle {
        prevent_destroy = false
    }
}


#create object level log bucket
resource "aws_s3_bucket" "object_level_log_bucket" {
	bucket = "mytfobjectlevellogbucketjovon"
	acl = "log-delivery-write"
	policy = file("ct_log_policy.json")
	force_destroy = true

#lifecycle
	lifecycle {
        prevent_destroy = false
    }
}

#configure bucket encryption
resource "aws_kms_key" "mykey" {
	description = "This key is used to encrypt bucket objects"
	deletion_window_in_days = 20
}

#object level logging
resource "aws_cloudtrail" "object-level-logging-jovon" {
	name = "tf-trail-Stack-jovon"
    s3_bucket_name = aws_s3_bucket.object_level_log_bucket.id
    s3_key_prefix = "log/"
    include_global_service_events = false

	event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
    type   = "AWS::S3::Object"
    values = ["arn:aws:s3:::"]
    }
	}
    }

#Event Notification SNS (Simple Notification Service)
resource "aws_sns_topic" "user_updates" {
	name = "user-updates-topic"
	policy = file("sns_policy_doc.json")
	}

#Enable analytics configuration
resource "aws_s3_bucket_analytics_configuration" "test-entire-bucket" {
	bucket = aws_s3_bucket.b.bucket
	name   = "EntireBucket"

	storage_class_analysis {
    data_export {
    destination {
        s3_bucket_destination {
        bucket_arn = aws_s3_bucket.analytics.arn
        }
    }
    }
}
}

resource "aws_s3_bucket" "analytics" {
	bucket = "mytfobjectlevellogbucketjovon"
	acl = "public-read-write"
}

#Enable Inventory Configuration
resource "aws_s3_bucket" "inventory" {
	bucket = "inventory-bucket-jovon"
	acl = "private"
	force_destroy = true
}
resource "aws_s3_bucket_inventory" "inventory-test" {
	bucket = aws_s3_bucket.b.id
	name   = "EntireBucketDaily"
	included_object_versions = "All"

	schedule {
    frequency = "Daily"
	}

	destination {
    bucket {
    format     = "ORC"
    bucket_arn = aws_s3_bucket.inventory.arn
    }
}
}

#Enable Bucket Metrics
resource "aws_s3_bucket" "metrics" {
	bucket = "metrics-bucket-jovon"
	acl = "private"
	force_destroy = true
}

resource "aws_s3_bucket_metric" "metric-filtered-bucket" {
	bucket = aws_s3_bucket.b.bucket
	name   = "FilteredObjectsBucket"

	filter {
    prefix = "documents/"

    tags = {
    priority = "high"
    class    = "blue"
    }
}
}

#Block public access
resource "aws_s3_bucket_public_access_block" "blcok-public-access" {
	bucket = aws_s3_bucket.b.id
	block_public_acls   = false
	block_public_policy = false
}


#Enable Bucket Metrics
resource "aws_s3_bucket" "stackbuckstatejovon" {
	bucket = "stackbuckstatejovon"
	acl = "private"
	force_destroy = true
}

#Locking Remote State File
#terraform{
#    backend "s3"{
#    bucket= "stackbuckstatejovon"
#    key = "terraform.tfsate"
#    region="us-east-1"
#    dynamodb_table="statelock-tf"
#    }
#}
