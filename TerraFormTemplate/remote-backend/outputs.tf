output "remote_state_bucket_name"{
description = "Name of the S3 Bucket for the State"
value = aws_s3_bucket.tf_state_bucket.id
}

output "remote_state_lock_table"{
description = "Name of the DynamoDB table used for locking"
value = aws_dynamodb_table.tf_lock_table.name
}