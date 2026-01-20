# ========================================
# outputs.tf - Oracle Autonomous Database on Azure Module
# ========================================

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

output "ocid" {
  description = "The Oracle Cloud ID (OCID) of the Autonomous Database"
  value       = azurerm_oracle_autonomous_database.this.ocid
}

output "connection_strings" {
  description = "Connection strings for different service levels (high, medium, low)"
  value       = azurerm_oracle_autonomous_database.this.connection_strings
  sensitive   = true
}

output "connection_urls" {
  description = "Connection URLs for various Oracle tools and services"
  value       = azurerm_oracle_autonomous_database.this.connection_urls
}

output "service_console_url" {
  description = "URL for the Oracle Autonomous Database service console"
  value       = azurerm_oracle_autonomous_database.this.service_console_url
}

output "actual_used_data_storage_size_in_tbs" {
  description = "Actual used data storage size in terabytes"
  value       = azurerm_oracle_autonomous_database.this.actual_used_data_storage_size_in_tbs
}

output "allocated_storage_size_in_tbs" {
  description = "Allocated storage size in terabytes"
  value       = azurerm_oracle_autonomous_database.this.allocated_storage_size_in_tbs
}

output "lifecycle_state" {
  description = "Current lifecycle state"
  value       = azurerm_oracle_autonomous_database.this.lifecycle_state
}

output "lifecycle_details" {
  description = "Additional lifecycle state details"
  value       = azurerm_oracle_autonomous_database.this.lifecycle_details
}

output "private_endpoint" {
  description = "Private endpoint for the database"
  value       = azurerm_oracle_autonomous_database.this.private_endpoint
}

output "private_endpoint_ip" {
  description = "Private endpoint IP address"
  value       = azurerm_oracle_autonomous_database.this.private_endpoint_ip
}

output "private_endpoint_label" {
  description = "Private endpoint label"
  value       = azurerm_oracle_autonomous_database.this.private_endpoint_label
}

output "time_created" {
  description = "Timestamp when the database was created"
  value       = azurerm_oracle_autonomous_database.this.time_created
}

output "time_maintenance_begin" {
  description = "Start time of the next maintenance window"
  value       = azurerm_oracle_autonomous_database.this.time_maintenance_begin
}

output "time_maintenance_end" {
  description = "End time of the next maintenance window"
  value       = azurerm_oracle_autonomous_database.this.time_maintenance_end
}

output "nsg_id" {
  description = "ID of the optional NSG created for allowed_ips (null if not created)"
  value       = length(azurerm_network_security_group.adb) > 0 ? azurerm_network_security_group.adb[0].id : null
}
