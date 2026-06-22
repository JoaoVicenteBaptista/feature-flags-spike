resource "azurerm_app_configuration" "main" {
  name                = "${var.prefix}appconfig${random_string.suffix.result}"
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
  enabled                = false
}

resource "azurerm_app_configuration_feature" "feature_b" {
  configuration_store_id = azurerm_app_configuration.main.id
  name                   = "FeatureB"
  enabled                = false
}
