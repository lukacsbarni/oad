# Oracle Autonomous Database on Azure - Terraform Module

This module provisions an **Oracle Autonomous Database@Azure** using `azurerm_oracle_autonomous_database`.

## Important (fix for your error)

The resource expects **`virtual_network_id`** (not `vnet_id`). This is shown in Oracle's Terraform example docs.  
It also uses **`national_character_set`** and supports **`allowed_ips`**.

References:
- Oracle doc example showing `virtual_network_id` + `national_character_set`. 
- AzureRM provider changelog entry adding `allowed_ips` support.
