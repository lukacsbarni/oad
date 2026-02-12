output "id" {
  value       = azurerm_oracle_autonomous_database.this.id
  description = "Azure resource ID"
}

output "name" {
  value       = azurerm_oracle_autonomous_database.this.name
  description = "Autonomous DB name"
}

output "resource_group_name" {
  value       = azurerm_oracle_autonomous_database.this.resource_group_name
  description = "Resource group name"
}
