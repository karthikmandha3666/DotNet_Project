terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # SOLUTION: Store the state file remotely so CI/CD doesn't lose it!
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"            # Must be manually created once
    storage_account_name = "webprojecttfstatestore" # Must be manually created once
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate" # The name of the state file in storage
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Example App Service Plan & Web App
resource "azurerm_service_plan" "app_plan" {
  name                = "app-plan-webproject"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = "app-webproject-backend"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.app_plan.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      dotnet_version = "9.0"
    }
  }
}
