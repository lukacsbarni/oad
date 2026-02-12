# ========================================
# variables.tf - Oracle Autonomous Database on Azure Module
# ========================================

# ==================== REQUIRED VARIABLES ====================
variable "name" {
  description = "Name of the Autonomous Database (alphanumeric only, max 30 characters)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{1,30}$", var.name))
    error_message = "Name must be alphanumeric and max 30 characters."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region (e.g., eastus, westeurope)"
  type        = string
}

variable "admin_password" {
  description = "Admin password (12-30 chars, must include uppercase, lowercase, number, and special char)"
  type        = string
  sensitive   = true

  validation {
    condition = (
      length(var.admin_password) >= 12 &&
      length(var.admin_password) <= 30 &&
      can(regex("[a-z]", var.admin_password)) &&
      can(regex("[A-Z]", var.admin_password)) &&
      can(regex("[0-9]", var.admin_password)) &&
      can(regex("[^A-Za-z0-9]", var.admin_password))
    )

    error_message = "admin_password must be 12-30 chars and include uppercase, lowercase, number, and special character."
  }
}


variable "subnet_id" {
  description = "Azure subnet ID (must be delegated to Oracle.Database/networkAttachments)"
  type        = string
}

variable "virtual_network_id" {
  description = "Azure Virtual Network resource ID"
  type        = string
}

# ==================== BASIC CONFIGURATION ====================
variable "display_name" {
  description = "User-friendly display name for the Autonomous Database"
  type        = string
  default     = null
}

variable "compute_model" {
  description = "Compute model: ECPU or OCPU"
  type        = string
  default     = "ECPU"
  validation {
    condition     = contains(["ECPU", "OCPU"], var.compute_model)
    error_message = "compute_model must be ECPU or OCPU."
  }
}

variable "compute_count" {
  description = "Number of ECPU/OCPU cores"
  type        = number
  default     = 2
}

variable "data_storage_size_in_tbs" {
  description = "Storage size in terabytes"
  type        = number
  default     = 1
}

variable "db_version" {
  description = "Oracle Database version (e.g., 19c, 21c, 23ai)"
  type        = string
  default     = "19c"
}

variable "db_workload" {
  description = "Workload type: OLTP, DW, AJD, APEX"
  type        = string
  default     = "OLTP"
  validation {
    condition     = contains(["OLTP", "DW", "AJD", "APEX"], var.db_workload)
    error_message = "db_workload must be OLTP, DW, AJD, or APEX."
  }
}

variable "license_model" {
  description = "License model: LicenseIncluded or BringYourOwnLicense"
  type        = string
  default     = "LicenseIncluded"
  validation {
    condition     = contains(["LicenseIncluded", "BringYourOwnLicense"], var.license_model)
    error_message = "license_model must be LicenseIncluded or BringYourOwnLicense."
  }
}

# ==================== AUTO SCALING ====================
variable "auto_scaling_enabled" {
  description = "Enable auto scaling for compute resources"
  type        = bool
  default     = false
}

variable "auto_scaling_for_storage_enabled" {
  description = "Enable auto scaling for storage"
  type        = bool
  default     = false
}

# ==================== BACKUP CONFIGURATION ====================
variable "backup_retention_period_in_days" {
  description = "Backup retention period in days (1-60)"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period_in_days >= 1 && var.backup_retention_period_in_days <= 60
    error_message = "backup_retention_period_in_days must be between 1 and 60."
  }
}

# ==================== CHARACTER SETS ====================
variable "character_set" {
  description = "Database character set"
  type        = string
  default     = "AL32UTF8"
}

variable "national_character_set" {
  description = "National character set (e.g., AL16UTF16 or UTF8)"
  type        = string
  default     = "AL16UTF16"
}

# ==================== NETWORK SECURITY ====================
variable "mtls_connection_required" {
  description = "Require mutual TLS (mTLS) authentication for connections"
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "Client IP access control list (ACL) for the database (CIDR blocks)."
  type        = list(string)
  default     = []
}

# Optional: also create an NSG on the delegated subnet allowing TCP/1522 from allowed_ips
variable "create_nsg_for_allowed_ips" {
  description = "If true and allowed_ips is non-empty, create an NSG and associate it to the subnet to allow inbound TCP/1522."
  type        = bool
  default     = false
}

# ==================== MAINTENANCE & CONTACTS ====================
variable "customer_contacts" {
  description = "List of customer email addresses for maintenance notifications (max 10)"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.customer_contacts) <= 10
    error_message = "Maximum 10 customer contacts allowed."
  }
}

# ==================== TAGS ====================
variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
