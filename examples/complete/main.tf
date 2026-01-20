terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-oracle-adb-complete"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-oracle-adb"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "delegated" {
  name                 = "subnet-oracle-delegated"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "oracle-delegation"

    service_delegation {
      name = "Oracle.Database/networkAttachments"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

module "autonomous_database" {
  source = "../../"

  name                = "proddb01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  admin_password      = "MySecureP@ssw0rd123!" # Use Key Vault in production
  subnet_id           = azurerm_subnet.delegated.id
  virtual_network_id  = azurerm_virtual_network.example.id

  display_name                     = "Production OLTP Database"
  compute_model                    = "ECPU"
  compute_count                    = 8
  data_storage_size_in_tbs         = 4
  db_version                       = "19c"
  db_workload                      = "OLTP"
  license_model                    = "BringYourOwnLicense"
  backup_retention_period_in_days  = 30
  auto_scaling_enabled             = true
  auto_scaling_for_storage_enabled = true

  character_set          = "AL32UTF8"
  national_character_set = "AL16UTF16"

  mtls_connection_required = true
  allowed_ips = [
    "203.0.113.0/24",
    "198.51.100.50/32",
  ]

  # Optional subnet NSG enforcement (off by default)
  create_nsg_for_allowed_ips = true

  customer_contacts = [
    "dba-team@company.com",
    "ops-team@company.com",
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

output "database_id" {
  value = module.autonomous_database.id
}
