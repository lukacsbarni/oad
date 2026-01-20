# ========================================
# main.tf - Oracle Autonomous Database on Azure Module
# ========================================

resource "azurerm_oracle_autonomous_database" "this" {
  # Required
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  admin_password      = var.admin_password
  subnet_id           = var.subnet_id
  virtual_network_id  = var.virtual_network_id

  # Optional/Configurable (all supported arguments exposed)
  display_name                     = coalesce(var.display_name, var.name)
  compute_model                    = var.compute_model
  compute_count                    = var.compute_count
  data_storage_size_in_tbs         = var.data_storage_size_in_tbs
  db_version                       = var.db_version
  db_workload                      = var.db_workload
  license_model                    = var.license_model
  backup_retention_period_in_days  = var.backup_retention_period_in_days
  auto_scaling_enabled             = var.auto_scaling_enabled
  auto_scaling_for_storage_enabled = var.auto_scaling_for_storage_enabled
  mtls_connection_required         = var.mtls_connection_required
  allowed_ips                      = var.allowed_ips
  character_set                    = var.character_set
  national_character_set           = var.national_character_set
  customer_contacts                = var.customer_contacts
  tags                             = var.tags

  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }

  timeouts {
    create = "3h"
    update = "2h"
    delete = "1h"
  }
}

# Optional: NSG that matches allowed_ips (orgs may prefer subnet NSG enforcement too)
resource "azurerm_network_security_group" "adb" {
  count               = (var.create_nsg_for_allowed_ips && length(var.allowed_ips) > 0) ? 1 : 0
  name                = "${var.name}-adb-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.allowed_ips
    content {
      name                       = "allow-${replace(replace(security_rule.value, "/", "-"), ":", "-")}"
      priority                   = 100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1522"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "adb" {
  count = (var.create_nsg_for_allowed_ips && length(var.allowed_ips) > 0) ? 1 : 0

  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.adb[0].id
}
