resource "azurerm_storage_account" "functions" {
  name                     = "${var.prefix}stor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_function_app" "main" {
  name                       = "${var.prefix}-func"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

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

resource "azurerm_role_assignment" "functions_appconfig" {
  scope                = azurerm_app_configuration.main.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}
