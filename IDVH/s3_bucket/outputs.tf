output "name" {
  value = module.s3_bucket_raw.s3_bucket_id
}

output "arn" {
  value = module.s3_bucket_raw.s3_bucket_arn
}

output "bucket_domain_name" {
  value = module.s3_bucket_raw.s3_bucket_bucket_domain_name
}
