# Feature Flags POC

A spike evaluating the .NET Feature Flag Management framework with Azure App Configuration. Two compute hosts — an Azure Functions API and an ASP.NET Web API — both expose endpoints that read feature flags from environment variables and Azure App Configuration, demonstrating a strangler migration pattern.

## Architecture

```
Azure App Configuration (primary)
        │
        ▼
  IFeatureManager  ──DI──►  FeatureFlagService
        │
        ▼ (fallback)
  Environment Variables
```

Both hosts register `Microsoft.FeatureManagement` with Azure App Configuration as the primary feature definition provider. If App Config is available, flags resolve from there; otherwise they fall back to environment variables. The response includes which source was used.

## Prerequisites

- [.NET SDK 8.0+](https://dotnet.microsoft.com/download)
- [Terraform CLI 1.5+](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (for deployment)

## Quick Start

```bash
git clone <repo-url> && cd feature-flags-spike
dotnet build
dotnet run --project src/FeatureFlags.Api
```

Open `http://localhost:<port>/swagger` in your browser, or use curl:

```bash
curl http://localhost:<port>/api/features
curl http://localhost:<port>/api/features/FeatureA
```

By default (no App Config connection), flags use environment variables as defined in `appsettings.Development.json` / `local.settings.json`:

| Flag     | Enabled | Source              |
|----------|---------|---------------------|
| FeatureA | true    | EnvironmentVariable |
| FeatureB | false   | EnvironmentVariable |

## API

Both the Azure Functions and the App Service expose the same endpoints:

### `GET /api/features`

Returns all feature flags.

**Response:**
```json
[
  { "name": "FeatureA", "enabled": true,  "source": "EnvironmentVariable" },
  { "name": "FeatureB", "enabled": false, "source": "EnvironmentVariable" }
]
```

### `GET /api/features/{name}`

Returns a single feature flag, or 404 if not found.

**Response (200):**
```json
{ "name": "FeatureA", "enabled": true, "source": "EnvironmentVariable" }
```

**Response (404):** empty body

## Feature Flag Resolution

Each flag is resolved through a priority chain:

1. **Azure App Configuration** — checks `.appconfig.featureflag/<name>`
2. **Environment variables** — checks `FeatureManagement__<name>` or `FeatureManagement:<name>` in configuration

The `source` field in the response indicates which provider resolved the flag.

### Strangler Migration Pattern

This setup demonstrates how to migrate feature flags from environment variables to Azure App Configuration without downtime:

1. **Start:** All flags defined in env vars (current state in this repo).
2. **Connect App Config:** Deploy with an App Config connection string. The service detects it and marks all flags as `AppConfiguration` source.
3. **Per-flag migration:** Enable a flag in App Config (e.g., `feature_a_appconfig_value = true` via Terraform). The app picks it up without a redeploy.
4. **Cleanup:** Once all flags are in App Config, remove the env vars from the compute hosts.

## Deployment

### 1. Login to Azure

```bash
az login
```

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan   # review what will be created
terraform apply  # creates RG, storage, service plan, functions, app service, app config
```

This provisions:
- Resource group, Linux B1 service plan, storage account
- Azure Functions (.NET 8, isolated worker) with `FeatureManagement__FeatureA/B` env vars
- App Service (.NET 8) with the same env vars
- Azure App Configuration store with Managed Identity

### 3. Create Feature Flags in App Configuration

Terraform's `azurerm_app_configuration_feature` is notoriously slow (10+ min per flag). Use `az` CLI instead:

```bash
# Get the App Config store name from Terraform output
APP_CONFIG=$(terraform -chdir=terraform output -raw app_configuration_name)

# Create FeatureA (disabled) and FeatureB (disabled)
az appconfig feature set --name "$APP_CONFIG" --feature FeatureA --label prd
az appconfig feature set --name "$APP_CONFIG" --feature FeatureB
```

To enable a flag later (simulating migration):
```bash
az appconfig feature enable --name "$APP_CONFIG" --feature FeatureA
```

### 4. Publish Applications

```bash
dotnet publish src/FeatureFlags.Functions -c Release -o publish/functions
cd publish/functions && zip -r ../functions.zip . && cd ../..

dotnet publish src/FeatureFlags.Api -c Release -o publish/api
cd publish/api && zip -r ../api.zip . && cd ../..

az functionapp deployment source config-zip \
  --resource-group ffpoc-rg \
  --name ffpoc-func \
  --src publish/functions.zip

az webapp deployment source config-zip \
  --resource-group ffpoc-rg \
  --name ffpoc-api \
  --src publish/api.zip
```

### 5. Verify

```bash
curl https://ffpoc-func.azurewebsites.net/api/features
curl https://ffpoc-api.azurewebsites.net/api/features
```

Both should return `"source": "AppConfiguration"` since the App Config connection string is now wired.

## Project Structure

```
src/
├── FeatureFlags.Shared/         # Models + IFeatureFlagService
│   ├── Models/
│   │   └── FeatureFlagResponse.cs
│   └── Services/
│       ├── IFeatureFlagService.cs
│       └── FeatureFlagService.cs
├── FeatureFlags.Functions/      # Azure Functions (Isolated Worker)
│   ├── Program.cs
│   ├── FeaturesHttpTrigger.cs
│   └── local.settings.json
└── FeatureFlags.Api/            # ASP.NET Web API
    ├── Program.cs
    └── Controllers/
        └── FeaturesController.cs
terraform/
├── main.tf                      # Provider, resource group, service plan
├── variables.tf                 # Input variables
├── appconfig.tf                 # App Configuration store + feature flags
├── functions.tf                 # Storage account + Function App
├── appservice.tf                # Web App + role assignment
└── outputs.tf                   # Output URLs
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Runtime | .NET 8 |
| Feature Flags | Microsoft.FeatureManagement 4.5.0 |
| App Config | Microsoft.Extensions.Configuration.AzureAppConfiguration 8.5.0 |
| Functions | Isolated Worker, v4 programming model |
| API | ASP.NET Core, Swagger |
| Auth | Anonymous (POC only) |
| Infrastructure | Terraform, AzureRM provider ~> 3.100 |
