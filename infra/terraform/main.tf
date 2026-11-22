provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "agents-dev-rg"
  location = var.location
}

resource "azurerm_container_app_environment" "env" {
  name                = "agents-dev-env"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_container_app" "api" {
  name                         = "agent-api"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  template {
    min_replicas = 1

    container {
      name   = "api"
      image  = var.image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  dapr {
    app_id   = "agent-api"
    app_port = 80
  }
}

resource "azurerm_container_app" "worker" {
  name                         = "agent-worker"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  revision_mode                = "Single"

  template {
    min_replicas = 1

    container {
      name   = "worker"
      image  = var.image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  dapr {
    app_id   = "agent-worker"
    app_port = 80
  }
}