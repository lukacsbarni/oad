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
  name     = "rg-oracle-adb-basic"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-oracle-adb-basic"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "delegated" {
  name                 = "subnet-oracle-delegated"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.1.0/24"]

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

  name                = "devdb01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  admin_password      = "MySecureP@ssw0rd123!"
  subnet_id           = azurerm_subnet.delegated.id
  virtual_network_id  = azurerm_virtual_network.example.id

  # Required by resource
  national_character_set = "AL16UTF16"

  tags = {
    Environment = "Development"
  }
}

output "database_id" {
  value = module.autonomous_database.id
}
