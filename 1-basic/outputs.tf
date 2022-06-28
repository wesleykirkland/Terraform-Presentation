output "cidrprefix" {
  description = "CIDR Prefix"
  value       = local.cidrprefix
}

output "public" {
  value = local.public_subnet_cidrs
}

output "private" {
  value = local.private_subnet_cidrs
}

output "database" {
  value = local.database_subnet_cidrs
}