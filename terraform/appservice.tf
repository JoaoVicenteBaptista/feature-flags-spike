resource "azurerm_linux_web_app" "main" {
  name                = "${var.prefix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "FeatureManagement__FeatureA"  = tostring(var.feature_a_env_value)
    "FeatureManagement__FeatureB"  = tostring(var.feature_b_env_value)
    "ConnectionStrings__AppConfig" = azurerm_app_configuration.main.primary_read_key[0].connection_string
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "webapp_appconfig" {
  scope                = azurerm_app_configuration.main.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_linux_web_app.main.identity[0].principal_id
}
