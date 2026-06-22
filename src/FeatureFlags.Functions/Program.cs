using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.FeatureManagement;
using FeatureFlags.Shared.Services;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureAppConfiguration((context, builder) =>
    {
        var builtConfig = builder.Build();
        var connectionString = builtConfig.GetConnectionString("AppConfig");
        if (!string.IsNullOrEmpty(connectionString))
        {
            builder.AddAzureAppConfiguration(options =>
                options.Connect(connectionString).UseFeatureFlags());
        }
    })
    .ConfigureServices((context, services) =>
    {
        services.AddFeatureManagement();
        services.AddSingleton<IFeatureFlagService, FeatureFlagService>();
    })
    .Build();

host.Run();
