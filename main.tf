## BUCKET S3
resource "aws_s3_bucket" "cloudfront_bucket" {
  bucket = "${var.name}-${var.environment}"

  tags = {
    Name = "${var.name}-${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "cloudfront_bucket_policy" {
  bucket = aws_s3_bucket.cloudfront_bucket.id

  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.cloudfront_bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.cloudfront.arn}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.cloudfront_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# TO DELETE
resource "aws_cloudfront_origin_access_identity" "cloudfront_id" {
  comment = "${var.name}-${var.environment}.s3.amazonaws.com"
}

## CLOUDFRONT ORIGIN
resource "aws_cloudfront_origin_access_control" "cloudfront_origin" {
  name                              = "${var.name}-${var.environment}"
  description                       = "S3 Origin Access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

## CLOUDFRONT
resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name              = aws_s3_bucket.cloudfront_bucket.bucket_regional_domain_name
    origin_id                = "${var.name}-${var.environment}"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_origin.id
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "${var.name}-${var.environment}"
  default_root_object = "index.html"

  aliases = var.url

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.name}-${var.environment}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.geo_restriction
    }
  }

  tags = {
    Name        = var.name
    Environment = var.environment
  }

  viewer_certificate {
    acm_certificate_arn = var.cert_arn
    ssl_support_method  = "sni-only"
  }
}
