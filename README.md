# Oracle Autonomous Database on Azure – Terraform Module

Terraform module to provision **Oracle Autonomous Database@Azure** using the `azurerm_oracle_autonomous_database` resource.

## Features

- Creates an Oracle Autonomous Database instance on Azure
- Supports compute + storage sizing and autoscaling
- Configurable backups and maintenance notification contacts
- Optional IP allow-listing (database ACL) via `allowed_ips`
- Optional subnet-level enforcement by creating an NSG that mirrors `allowed_ips` (disabled by default)
- Comprehensive outputs (IDs, connection info, endpoints, lifecycle)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |

## Module structure

```text
oracle-adb-azure-module/
  providers.tf
  variables.tf
  main.tf
  outputs.tf
  README.md
  examples/
    basic/
      main.tf
    complete/
      main.tf
```

## Usage

### Basic example

```hcl
module "autonomous_database" {
  source = "path/to/oracle-adb-azure-module"

  name                = "mydb01"
  resource_group_name = "rg-oracle-prod"
  location            = "eastus"

  admin_password = var.admin_password

  subnet_id          = azurerm_subnet.delegated.id
  virtual_network_id = azurerm_virtual_network.main.id

  # Required
  national_character_set = "AL16UTF16"

  tags = {
    Environment = "Production"
  }
}
```

## Notes

- The subnet must be delegated to `Oracle.Database/networkAttachments`.
- If you enable `create_nsg_for_allowed_ips`, the module creates an NSG and associates it with the provided subnet.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Autonomous Database (alphanumeric only, max 30 characters) | `string` | n/a | yes |
| resource_group_name | Name of the Azure resource group | `string` | n/a | yes |
| location | Azure region (e.g., eastus, westeurope) | `string` | n/a | yes |
| admin_password | Admin password (12-30 chars, must include uppercase, lowercase, number, and special char) | `string` | n/a | yes |
| subnet_id | Azure subnet ID (must be delegated to Oracle.Database/networkAttachments) | `string` | n/a | yes |
| virtual_network_id | Azure Virtual Network resource ID | `string` | n/a | yes |
| display_name | User-friendly display name for the Autonomous Database | `string` | `null` | no |
| compute_model | Compute model: ECPU or OCPU | `string` | `"ECPU"` | no |
| compute_count | Number of ECPU/OCPU cores | `number` | `2` | no |
| data_storage_size_in_tbs | Storage size in terabytes | `number` | `1` | no |
| db_version | Oracle Database version (e.g., 19c, 21c, 23ai) | `string` | `"19c"` | no |
| db_workload | Workload type: OLTP, DW, AJD, APEX | `string` | `"OLTP"` | no |
| license_model | License model: LicenseIncluded or BringYourOwnLicense | `string` | `"LicenseIncluded"` | no |
| auto_scaling_enabled | Enable auto scaling for compute resources | `bool` | `false` | no |
| auto_scaling_for_storage_enabled | Enable auto scaling for storage | `bool` | `false` | no |
| backup_retention_period_in_days | Backup retention period in days (1-60) | `number` | `7` | no |
| character_set | Database character set | `string` | `"AL32UTF8"` | no |
| national_character_set | National character set (e.g., AL16UTF16 or UTF8) | `string` | `"AL16UTF16"` | no *(resource-required)* |
| mtls_connection_required | Require mutual TLS (mTLS) authentication for connections | `bool` | `false` | no |
| allowed_ips | Client IP access control list (ACL) for the database (CIDR blocks) | `list(string)` | `[]` | no |
| create_nsg_for_allowed_ips | If true and allowed_ips is non-empty, create an NSG and associate it to the subnet to allow inbound TCP/1522 | `bool` | `false` | no |
| customer_contacts | List of customer email addresses for maintenance notifications (max 10) | `list(string)` | `[]` | no |
| tags | Tags to apply to the resource | `map(string)` | `{}` | no |

> Note: Some fields may be required by the AzureRM resource even if a default is set in this module. In particular, `national_character_set` is required by the service; a default is provided for convenience.

## Outputs

| Name | Description |
|------|-------------|
| id | The Azure resource ID of the Autonomous Database |
| name | The name of the Autonomous Database |
| display_name | The display name of the Autonomous Database |
| ocid | The Oracle Cloud ID (OCID) of the Autonomous Database |
| connection_strings | Connection strings for different service levels (high, medium, low) *(sensitive)* |
| connection_urls | Connection URLs for various Oracle tools and services |
| service_console_url | URL for the Oracle Autonomous Database service console |
| actual_used_data_storage_size_in_tbs | Actual used data storage size in terabytes |
| allocated_storage_size_in_tbs | Allocated storage size in terabytes |
| lifecycle_state | Current lifecycle state |
| lifecycle_details | Additional lifecycle state details |
| private_endpoint | Private endpoint for the database |
| private_endpoint_ip | Private endpoint IP address |
| private_endpoint_label | Private endpoint label |
| time_created | Timestamp when the database was created |
| time_maintenance_begin | Start time of the next maintenance window |
| time_maintenance_end | End time of the next maintenance window |
| nsg_id | ID of the optional NSG created for allowed_ips (null if not created) |

## Examples

- `examples/basic` – minimal configuration
- `examples/complete` – full example

## License

MIT
