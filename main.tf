# ========================================
# main.tf - Oracle Autonomous Database on Azure Module
# ========================================

# ==================== PASSWORD GENERATION ====================
resource "random_password" "admin" {
  count = var.admin_password == null && var.generate_admin_password ? 1 : 0

  length  = var.generated_password_length
  special = true
  
  # Ensure password meets Oracle ADB requirements
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  
  # Avoid ambiguous characters
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  # Use provided password or generated password
  admin_password = var.admin_password != null ? var.admin_password : (
    var.generate_admin_password ? random_password.admin[0].result : null
  )

  # Key Vault secret name
  kv_secret_name = var.key_vault_secret_name != null ? var.key_vault_secret_name : "${var.name}-admin-password"
  
  # Merge tags for Key Vault secret
  kv_secret_tags = merge(
    var.tags,
    var.key_vault_secret_tags,
    {
      "managed-by"    = "terraform"
      "database-name" = var.name
    }
  )
}

# ==================== AUTONOMOUS DATABASE ====================
resource "azurerm_oracle_autonomous_database" "this" {
  # Required
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  admin_password      = local.admin_password
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

  dynamic "long_term_backup_schedule" {
    for_each = var.long_term_backup_schedule != null ? [var.long_term_backup_schedule] : []

    content {
      repeat_cadence           = long_term_backup_schedule.value.repeat_cadence
      time_of_backup           = long_term_backup_schedule.value.time_of_backup
      retention_period_in_days = long_term_backup_schedule.value.retention_period_in_days
      enabled                  = long_term_backup_schedule.value.enabled
    }
  }

  lifecycle {
    ignore_changes = [
      admin_password,
    ]
    
    precondition {
      condition     = local.admin_password != null
      error_message = "Admin password must be provided or generate_admin_password must be true."
    }
  }

  timeouts {
    create = "3h"
    update = "2h"
    delete = "1h"
  }
}

# ==================== KEY VAULT SECRET ====================
resource "azurerm_key_vault_secret" "admin_password" {
  count = var.create_key_vault_secret ? 1 : 0

  name         = local.kv_secret_name
  value        = local.admin_password
  key_vault_id = var.key_vault_id

  content_type    = var.key_vault_secret_content_type
  expiration_date = var.key_vault_secret_expiration_date
  tags            = local.kv_secret_tags

  lifecycle {
    precondition {
      condition     = var.key_vault_id != null
      error_message = "key_vault_id must be provided when create_key_vault_secret is true."
    }
    
    ignore_changes = [
      value, # Don't update the secret if password changes in state
    ]
  }

  depends_on = [
    azurerm_oracle_autonomous_database.this
  ]
}

# ==================== NETWORK SECURITY GROUP ====================
resource "azurerm_network_security_group" "adb" {
  count               = (var.create_nsg_for_allowed_ips && length(var.allowed_ips) > 0) ? 1 : 0
  name                = "${var.name}-adb-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Create individual security rules to avoid priority conflicts
resource "azurerm_network_security_rule" "allow_adb_inbound" {
  for_each = var.create_nsg_for_allowed_ips && length(var.allowed_ips) > 0 ? toset(var.allowed_ips) : []

  name                        = "allow-adb-${replace(replace(each.value, "/", "-"), ".", "-")}"
  priority                    = 100 + index(var.allowed_ips, each.value)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1522"
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.adb[0].name

  lifecycle {
    precondition {
      condition     = (100 + index(var.allowed_ips, each.value)) <= 4096
      error_message = "NSG rule priority would exceed maximum of 4096. Too many allowed_ips entries."
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "adb" {
  count = (var.create_nsg_for_allowed_ips && length(var.allowed_ips) > 0) ? 1 : 0

  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.adb[0].id
}
