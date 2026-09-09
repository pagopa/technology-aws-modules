output "arn" {
  value = module.nlb_raw.arn
}

output "dns_name" {
  value = module.nlb_raw.dns_name
}

output "security_group_id" {
  value = module.nlb_raw.security_group_id
}

output "target_groups" {
  value = module.nlb_raw.target_groups
}
