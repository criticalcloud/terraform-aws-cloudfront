output "domain_name" {
  description = "CF Domain name"
  value       = aws_cloudfront_distribution.cloudfront.domain_name
}