data "azurerm_oracle_autonomous_database" "this" {
  name                = azurerm_oracle_autonomous_database.this.name
  resource_group_name = azurerm_oracle_autonomous_database.this.resource_group_name

  depends_on = [azurerm_oracle_autonomous_database.this]
}

output "id" {
  description = "The Azure resource ID of the Autonomous Database"
  value       = azurerm_oracle_autonomous_database.this.id
}

output "name" {
  description = "The name of the Autonomous Database"
  value       = azurerm_oracle_autonomous_database.this.name
}

output "display_name" {
  description = "The display name of the Autonomous Database"
  value       = azurerm_oracle_autonomous_database.this.display_name
}

output "lifecycle_state" {
  description = "Current lifecycle state (from data source)"
  value       = data.azurerm_oracle_autonomous_database.this.lifecycle_state
}

output "private_endpoint_ip" {
  description = "Private endpoint IP address (from data source)"
  value       = data.azurerm_oracle_autonomous_database.this.private_endpoint_ip
}

output "private_endpoint_label" {
  description = "Private endpoint label (from data source)"
  value       = data.azurerm_oracle_autonomous_database.this.private_endpoint_label
}

output "time_created" {
  description = "Timestamp when the database was created (from data source)"
  value       = data.azurerm_oracle_autonomous_database.this.time_created
}

output "nsg_id" {
  description = "ID of the optional NSG created for allowed_ips (null if not created)"
  value       = length(azurerm_network_security_group.adb) > 0 ? azurerm_network_security_group.adb[0].id : null
}
