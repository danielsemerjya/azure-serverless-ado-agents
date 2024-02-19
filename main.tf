terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.92.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  subscription_id            = var.subscription_id
  skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project_name}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.project_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${var.project_name}"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "null_resource" "this" {
  triggers = { id = azurerm_container_app_environment.this.id }


  provisioner "local-exec" {
    command = "pwsh -File ${path.root}/create_container_app_job.ps1 -RESOURCE_GROUP ${azurerm_resource_group.this.name} -CONTAINER_ENVIRONMENT ${azurerm_container_app_environment.this.name} -AZP_TOKEN ${var.azp_token} -ORGANIZATION_URL ${var.organization_url} -AZP_POOL ${var.azp_pool}"
  }

  depends_on = [azurerm_container_app_environment.this]
}
