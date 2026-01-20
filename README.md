# Oracle Autonomous Database on Azure – Terraform Module

A comprehensive Terraform module for provisioning **Oracle Autonomous Database@Azure** using the  
`azurerm_oracle_autonomous_database` resource and its supported arguments.

This module exposes all commonly used configuration options while keeping sane defaults and provider-correct attributes.

---

## Folder structure (module)

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

---

## Prerequisites

- Azure subscription with **Oracle Database@Azure** enabled
- Oracle Database@Azure onboarding completed
- Terraform **>= 1.0**
- Azure authentication via:
  - `az login`, or
  - Service Principal

---

## Usage

### Basic example

```hcl
module "autonomous_database" {
  source = "path/to/oracle-adb-azure-module"

  name                = "mydb01"
  resource_group_name = "rg-oracle-prod"
  location            = "eastus"

  admin_password = var.admin_password

  # Networking (REQUIRED)
  subnet_id          = azurerm_subnet.delegated.id
  virtual_network_id = azurerm_virtual_network.main.id

  # REQUIRED by the resource
  national_character_set = "AL16UTF16"

  tags = {
    Environment = "Production"
  }
}
```

---

## Important Notes

### Networking requirements

- The subnet **must be delegated** to:

```
Oracle.Database/networkAttachments
```


### Character sets

- `national_character_set` is **required**
  - Allowed values: `AL16UTF16`, `UTF8`
- `character_set` is optional (default: `AL32UTF8`)

---

### Network access control

- The module supports **database-level IP allow-listing** using:

```hcl
allowed_ips = [
  "203.0.113.0/24",
  "198.51.100.50/32"
]
```

- Optionally, the module can also create and attach a **Network Security Group (NSG)** on the delegated subnet to enforce the same rules at the network level.

---

## Examples

- `examples/basic`  
  Minimal configuration with required arguments only

- `examples/complete`  
  Full example including:
  - Virtual Network
  - Delegated Subnet
  - Auto-scaling
  - IP allow-listing
  - Optional NSG enforcement
  - Tags and maintenance contacts

---

## License

MIT
