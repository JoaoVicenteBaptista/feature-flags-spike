resource "azurerm_app_configuration" "main" {
  name                = "${var.prefix}appconfig"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "free"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_configuration_feature" "feature_a" {
  configuration_store_id = azurerm_app_configuration.main.id
  name                   = "FeatureA"
  enabled                = var.feature_a_appconfig_value
  label                  = "prd"
}

resource "azurerm_app_configuration_feature" "feature_b" {
  configuration_store_id = azurerm_app_configuration.main.id
  name                   = "FeatureB"
  enabled                = var.feature_b_appconfig_value
  label                  = "prd"
}
