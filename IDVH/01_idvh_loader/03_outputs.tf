output "idvh_resource_type" {
  value = var.idvh_resource_type
}

output "idvh_resource_tier" {
  value = var.idvh_resource_tier
}

output "idvh_resource_configuration" {
  value = local.tiers_configurations[var.idvh_resource_tier]
}

output "idvh_tiers_configurations" {
  value = local.tiers_configurations
}
