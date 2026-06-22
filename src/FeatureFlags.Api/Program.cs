using Microsoft.FeatureManagement;
using FeatureFlags.Shared.Services;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("AppConfig");
if (!string.IsNullOrEmpty(connectionString))
{
    builder.Configuration.AddAzureAppConfiguration(options =>
        options.Connect(connectionString).UseFeatureFlags());
}

builder.Services.AddFeatureManagement();

builder.Services.AddSingleton<IFeatureFlagService, FeatureFlagService>();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.MapControllers();

app.Run();
