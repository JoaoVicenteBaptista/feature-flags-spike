resource "azurerm_app_configuration" "main" {
  name                = "${var.prefix}appconfig${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "free"

  identity {
    type = "SystemAssigned"
  }
}
