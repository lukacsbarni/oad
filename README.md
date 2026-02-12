# Oracle Autonomous Database on Azure - Terraform Module

This Terraform module provisions an Oracle Autonomous Database on Azure with automatic password generation and Azure Key Vault integration.

## Features

- ✅ **Automatic Password Generation** - Generates secure passwords meeting Oracle requirements
- ✅ **Azure Key Vault Integration** - Optionally stores admin password in Key Vault
- ✅ **Comprehensive Configuration** - Supports all ADB configuration options
- ✅ **Network Security** - Optional NSG creation with IP allowlisting
- ✅ **Long-term Backups** - Configurable backup schedules
- ✅ **Auto-scaling** - Support for compute and storage auto-scaling
- ✅ **Input Validation** - Extensive validation for all inputs

## Requirements

- Terraform >= 1.14.3
- Azure Provider >= 4.58.0
- Random Provider >= 3.6

## Usage

### Basic Example - Auto-generated Password

```hcl
module "oracle_adb" {
  source = "./path-to-module"

  name                = "myoracledb"
  resource_group_name = "my-rg"
  location            = "eastus"
  subnet_id           = azurerm_subnet.oracle.id
  virtual_network_id  = azurerm_virtual_network.main.id

  # Password will be auto-generated
  generate_admin_password = true

  # Database configuration
  compute_model            = "ECPU"
  compute_count            = 4
  data_storage_size_in_tbs = 2
  db_version               = "19c"
  db_workload              = "OLTP"

  # No long-term backup schedule specified - it's optional
  # Standard backups (7 days retention) are still active

  tags = {
    environment = "production"
    application = "my-app"
  }
}

# Access the generated password
output "db_password" {
  value     = module.oracle_adb.admin_password
  sensitive = true
}
```

### Example with Key Vault Secret Storage

```hcl
# Existing Key Vault
data "azurerm_key_vault" "main" {
  name                = "my-keyvault"
  resource_group_name = "my-rg"
}

module "oracle_adb" {
  source = "./path-to-module"

  name                = "myoracledb"
  resource_group_name = "my-rg"
  location            = "eastus"
  subnet_id           = azurerm_subnet.oracle.id
  virtual_network_id  = azurerm_virtual_network.main.id

  # Auto-generate password and store in Key Vault
  generate_admin_password = true
  create_key_vault_secret = true
  key_vault_id            = data.azurerm_key_vault.main.id
  key_vault_secret_name   = "oracle-admin-password"

  # Optional: Set expiration
  key_vault_secret_expiration_date = "2027-02-12T00:00:00Z"

  tags = {
    environment = "production"
  }
}

# Reference the Key Vault secret
output "kv_secret_id" {
  value = module.oracle_adb.key_vault_secret_id
}
```

### Example with Custom Password

```hcl
module "oracle_adb" {
  source = "./path-to-module"

  name                = "myoracledb"
  resource_group_name = "my-rg"
  location            = "eastus"
  subnet_id           = azurerm_subnet.oracle.id
  virtual_network_id  = azurerm_virtual_network.main.id

  # Provide your own password
  admin_password          = var.db_admin_password
  generate_admin_password = false

  # Store in Key Vault
  create_key_vault_secret = true
  key_vault_id            = data.azurerm_key_vault.main.id

  tags = {
    environment = "production"
  }
}
```

### Example with Network Security and IP Allowlist

```hcl
module "oracle_adb" {
  source = "./path-to-module"

  name                = "myoracledb"
  resource_group_name = "my-rg"
  location            = "eastus"
  subnet_id           = azurerm_subnet.oracle.id
  virtual_network_id  = azurerm_virtual_network.main.id

  # Security settings
  mtls_connection_required = true
  allowed_ips = [
    "10.0.1.0/24",
    "203.0.113.0/24"
  ]

  # Create NSG with rules for allowed IPs
  create_nsg_for_allowed_ips = true

  tags = {
    environment = "production"
  }
}
```

### Example with Auto-scaling and Long-term Backup

```hcl
module "oracle_adb" {
  source = "./path-to-module"

  name                = "myoracledb"
  resource_group_name = "my-rg"
  location            = "eastus"
  subnet_id           = azurerm_subnet.oracle.id
  virtual_network_id  = azurerm_virtual_network.main.id

  # Auto-scaling
  auto_scaling_enabled             = true
  auto_scaling_for_storage_enabled = true

  # Backup configuration
  backup_retention_period_in_days = 30

  # Long-term backup schedule (only one allowed)
  long_term_backup_schedule = {
    repeat_cadence           = "Weekly"
    time_of_backup           = "2026-03-01T02:00:00Z"
    retention_period_in_days = 180
    enabled                  = true
  }

  tags = {
    environment = "production"
  }
}
```

### Data Warehouse Workload Example

```hcl
module "oracle_dw" {
  source = "./path-to-module"

  name                = "myoracledw"
  resource_group_name = "my-rg"
  location            = "eastus"
  subnet_id           = azurerm_subnet.oracle.id
  virtual_network_id  = azurerm_virtual_network.main.id

  # Data Warehouse configuration
  db_workload              = "DW"
  compute_model            = "OCPU"
  compute_count            = 8
  data_storage_size_in_tbs = 5

  # DW typically benefits from auto-scaling
  auto_scaling_enabled             = true
  auto_scaling_for_storage_enabled = true

  license_model = "BringYourOwnLicense"

  tags = {
    environment = "production"
    workload    = "analytics"
  }
}
```

## Input Variables

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Database name (alphanumeric, max 30 chars) |
| `resource_group_name` | `string` | Azure resource group name |
| `location` | `string` | Azure region |
| `subnet_id` | `string` | Subnet ID (must be delegated to Oracle.Database/networkAttachments) |
| `virtual_network_id` | `string` | Virtual Network resource ID |

### Password Management

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `admin_password` | `string` | `null` | Admin password (12-30 chars with complexity) |
| `generate_admin_password` | `bool` | `true` | Generate random password if not provided |
| `generated_password_length` | `number` | `20` | Length of auto-generated password (12-30) |

### Key Vault Integration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_key_vault_secret` | `bool` | `false` | Store password in Key Vault |
| `key_vault_id` | `string` | `null` | Key Vault resource ID |
| `key_vault_secret_name` | `string` | `null` | Secret name (defaults to `{db_name}-admin-password`) |
| `key_vault_secret_content_type` | `string` | `"password"` | Secret content type |
| `key_vault_secret_expiration_date` | `string` | `null` | Expiration date (RFC3339 format) |
| `key_vault_secret_tags` | `map(string)` | `{}` | Additional tags for the secret |

### Database Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `display_name` | `string` | `null` | User-friendly display name |
| `compute_model` | `string` | `"ECPU"` | Compute model (ECPU or OCPU) |
| `compute_count` | `number` | `2` | Number of cores |
| `data_storage_size_in_tbs` | `number` | `1` | Storage size in TB |
| `db_version` | `string` | `"19c"` | Database version (19c, 21c, 23ai) |
| `db_workload` | `string` | `"OLTP"` | Workload type (OLTP, DW, AJD, APEX) |
| `license_model` | `string` | `"LicenseIncluded"` | License model |
| `auto_scaling_enabled` | `bool` | `false` | Enable compute auto-scaling |
| `auto_scaling_for_storage_enabled` | `bool` | `false` | Enable storage auto-scaling |

### Backup Configuration

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `backup_retention_period_in_days` | `number` | `7` | Backup retention (1-60 days) |
| `long_term_backup_schedule` | `object` | `null` | Long-term backup configuration (only one allowed) |

### Network Security

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `mtls_connection_required` | `bool` | `false` | Require mutual TLS |
| `allowed_ips` | `list(string)` | `[]` | Client IP allowlist (CIDR blocks) |
| `create_nsg_for_allowed_ips` | `bool` | `false` | Create NSG for IP allowlist |

### Other Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `character_set` | `string` | `"AL32UTF8"` | Database character set |
| `national_character_set` | `string` | `"AL16UTF16"` | National character set |
| `customer_contacts` | `list(string)` | `[]` | Email addresses for notifications (max 10) |
| `tags` | `map(string)` | `{}` | Resource tags |

## Outputs

### Database Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `id` | Azure resource ID | No |
| `name` | Database name | No |
| `resource_group_name` | Resource group name | No |
| `ocid` | Oracle Cloud Identifier | No |
| `lifecycle_state` | Current lifecycle state | No |
| `connection_strings` | Connection strings | Yes |
| `connection_urls` | Connection URLs | Yes |

### Password Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `admin_password` | Admin password | Yes |
| `password_generated` | Whether password was auto-generated | No |

### Key Vault Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `key_vault_secret_id` | Key Vault secret ID | No |
| `key_vault_secret_name` | Secret name | No |
| `key_vault_secret_version` | Secret version | No |
| `key_vault_secret_versionless_id` | Versionless ID (latest) | No |

### Network Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `nsg_id` | NSG resource ID (if created) | No |
| `subnet_id` | Subnet ID | No |

## Password Requirements

The admin password must meet the following requirements:

- **Length**: 12-30 characters
- **Uppercase**: At least 1 uppercase letter
- **Lowercase**: At least 1 lowercase letter
- **Number**: At least 1 digit
- **Special Character**: At least 1 special character

When auto-generating passwords, the module uses these characters for special characters: `!#$%&*()-_=+[]{}<>:?`

## Key Vault Prerequisites

To use Key Vault integration, ensure:

1. The Key Vault exists and is accessible
2. The Terraform service principal has permissions:
   - `Key Vault Secrets Officer` role, or
   - Access policy with `Set` and `Get` secret permissions
3. The Key Vault has appropriate firewall rules

## Network Prerequisites

The subnet must be delegated to `Oracle.Database/networkAttachments`:

```hcl
resource "azurerm_subnet" "oracle" {
  name                 = "oracle-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "oracle-delegation"

    service_delegation {
      name = "Oracle.Database/networkAttachments"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
```

## License Models

- **LicenseIncluded**: License is included in the service cost
- **BringYourOwnLicense (BYOL)**: Use existing Oracle licenses (typically 50% cost savings)

## Workload Types

- **OLTP**: Optimized for transaction processing
- **DW**: Optimized for data warehousing and analytics
- **AJD**: Autonomous JSON Database
- **APEX**: Oracle Application Express

## Long-term Backup Schedule

**Note: Only one long-term backup schedule is allowed.**

Example configuration:

```hcl
long_term_backup_schedule = {
  repeat_cadence           = "Weekly"     # Weekly, Monthly, Yearly, OneTime
  time_of_backup           = "2026-03-01T02:00:00Z"
  retention_period_in_days = 180          # 90-2558 days
  enabled                  = true
}
```

If you don't want long-term backups, simply **omit the variable** (the default is `null`):
```hcl
# No need to set anything - just don't include long_term_backup_schedule
# The variable defaults to null, which disables long-term backups
```

**Important Notes:**
- Only one schedule can be configured
- `repeat_cadence` is case-sensitive (use: Weekly, Monthly, Yearly, OneTime)
- `time_of_backup` must be in ISO8601 format
- Retention period: 90-2558 days
- **Optional**: If not specified, long-term backups are disabled

## Security Recommendations

1. **Enable mTLS**: Set `mtls_connection_required = true` for production
2. **Use Key Vault**: Store passwords in Key Vault rather than Terraform state
3. **Limit IPs**: Use `allowed_ips` to restrict database access
4. **Auto-scaling**: Enable for production workloads to handle load spikes
5. **Backups**: Configure both standard and long-term backups
6. **Tags**: Use consistent tagging for cost tracking and governance

## Cost Optimization

1. **BYOL**: Use `BringYourOwnLicense` if you have existing Oracle licenses
2. **Right-size**: Start with smaller `compute_count` and enable auto-scaling
3. **ECPU vs OCPU**: ECPU is more cost-effective for variable workloads
4. **Storage**: Don't over-provision; enable `auto_scaling_for_storage_enabled`

## Troubleshooting

### Password doesn't meet requirements
Ensure your password includes uppercase, lowercase, number, and special character.

### Key Vault access denied
Check that the service principal has appropriate permissions on the Key Vault.

### Subnet delegation error
Verify the subnet is delegated to `Oracle.Database/networkAttachments`.

### NSG association conflict
If the subnet already has an NSG, set `create_nsg_for_allowed_ips = false` and manage NSG separately.

## License

This module is licensed under the MIT License.

## Authors

Maintained by your team/organization.

## Support

For issues and questions:
- Check Azure documentation for Oracle Database@Azure
- Review Terraform azurerm provider documentation
- Open an issue in the repository
