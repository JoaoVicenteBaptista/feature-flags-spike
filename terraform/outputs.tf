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

output "feature_flags_command" {
  value = <<-EOT
    az rest --method put --headers "Content-Type=application/json" \
      --uri "https://management.azure.com/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}/providers/Microsoft.AppConfiguration/configurationStores/${azurerm_app_configuration.main.name}/keyValues/.appconfig.featureflag~2FFeatureA?api-version=2023-03-01" \
      --body '{"properties":{"value":"{\"id\":\"FeatureA\",\"enabled\":true,\"conditions\":{\"client_filters\":[]}}","contentType":"application/vnd.microsoft.appconfig.ff+json;charset=utf-8","tags":{}}}' -o none && \
    az rest --method put --headers "Content-Type=application/json" \
      --uri "https://management.azure.com/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}/providers/Microsoft.AppConfiguration/configurationStores/${azurerm_app_configuration.main.name}/keyValues/.appconfig.featureflag~2FFeatureB?api-version=2023-03-01" \
      --body '{"properties":{"value":"{\"id\":\"FeatureB\",\"enabled\":false,\"conditions\":{\"client_filters\":[]}}","contentType":"application/vnd.microsoft.appconfig.ff+json;charset=utf-8","tags":{}}}' -o none
  EOT
}
