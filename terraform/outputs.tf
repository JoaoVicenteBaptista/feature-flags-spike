output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "function_app_name" {
  value = azurerm_linux_function_app.main.name
}

output "function_app_url" {
  value = "https://${azurerm_linux_function_app.main.default_hostname}/api/features"
}

output "web_app_name" {
  value = azurerm_linux_web_app.main.name
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}/api/features"
}

output "app_configuration_name" {
  value = azurerm_app_configuration.main.name
}

output "create_feature_flags_command" {
  sensitive = true
  value = join(" && ", [
    "az appconfig feature set --name ${azurerm_app_configuration.main.name} --feature FeatureA --label prd -o none",
    "az appconfig feature set --name ${azurerm_app_configuration.main.name} --feature FeatureB -o none",
  ])
}
