#S3 bucket for Angular static files
resource "aws_s3_bucket" "angular_bucket"{
    bucket = var.angular_s3_bucket_name
    force_destroy = true

    tags = {
        Name = "Angular Bookstore Static Site"
        Environment = "Production"
    }
}


#S3 bucket object ownership
resource "aws_s3_bucket_ownership_controls" "object_ownership"{
    bucket = aws_s3_bucket.angular_bucket.id
    rule{
        object_ownership = "BucketOwnerEnforced"

    }
    
}

#Block Public access at bucket level
resource "aws_s3_bucket_public_access_block" "block_public_access"{
    bucket = aws_s3_bucket.angular_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}



#Origin Access Control (OAC) 
resource "aws_cloudfront_origin_access_control" "oac"{
name = "${var.angular_s3_bucket_name}--oac"
description = "OAC for cloudfont to access S3 bucket"
signing_behavior = "always"
signing_protocol = "sigv4"
origin_access_control_origin_type = "s3"

}

#Cloudfront Distribution for Angular app
resource "aws_cloudfront_distribution" "angular_cdn"{
    enabled = true
    default_root_object = "index.html"

    origin{
        domain_name = aws_s3_bucket.angular_bucket.bucket_regional_domain_name
        origin_id = "s3-angular-origin"

        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    }
    
    viewer_certificate{
        cloudfront_default_certificate = true
        minimum_protocol_version = "TLSv1"

    }
    default_cache_behavior{
        allowed_methods = ["GET","HEAD","OPTIONS"]
        cached_methods = ["GET","HEAD"]
        target_origin_id = "s3-angular-origin"

        viewer_protocol_policy = "redirect-to-https"

        #Caching TTL settings, adjust as needed
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400

        compress = true

        forwarded_values{
            query_string = false
            cookies{
                forward = "none"
            }
        }
    }
    price_class = "PriceClass_100" #Use cheaptest edge locations

    restrictions{
        geo_restriction{
            restriction_type = "none"
        }
    }

    tags = {
        Environment = "Production"
        Project = "BookstoreWebApp"

    }
}


#OAC policy for S3 bucket
resource "aws_s3_bucket_policy" "angular_bucket_policy"{
bucket = aws_s3_bucket.angular_bucket.id
policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Sid = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
            Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.angular_bucket.arn}/*"
        Condition ={
            "ArnLike" = {
                "AWS:SourceArn" = aws_cloudfront_distribution.angular_cdn.arn
            }
        }
    }]
})

}