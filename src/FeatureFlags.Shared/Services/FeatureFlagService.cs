using FeatureFlags.Shared.Models;
using Microsoft.FeatureManagement;
using Microsoft.Extensions.Configuration;

namespace FeatureFlags.Shared.Services;

public sealed class FeatureFlagService : IFeatureFlagService
{
    private readonly IFeatureManager _featureManager;
    private readonly bool _isAppConfigAvailable;

    private static readonly string[] FlagNames = ["FeatureA", "FeatureB"];

    public FeatureFlagService(IFeatureManager featureManager, IConfiguration configuration)
    {
        _featureManager = featureManager;
        _isAppConfigAvailable = !string.IsNullOrEmpty(
            configuration.GetConnectionString("AppConfig"));
    }

    public async Task<IReadOnlyList<FeatureFlagResponse>> GetAllAsync()
    {
        var results = new List<FeatureFlagResponse>();
        foreach (var name in FlagNames)
        {
            var enabled = await _featureManager.IsEnabledAsync(name);
            results.Add(new FeatureFlagResponse(
                name,
                enabled,
                _isAppConfigAvailable ? "AppConfiguration" : "EnvironmentVariable"));
        }
        return results;
    }

    public async Task<FeatureFlagResponse?> GetAsync(string name)
    {
        if (!FlagNames.Contains(name, StringComparer.OrdinalIgnoreCase))
            return null;

        var enabled = await _featureManager.IsEnabledAsync(name);
        return new FeatureFlagResponse(
            name,
            enabled,
            _isAppConfigAvailable ? "AppConfiguration" : "EnvironmentVariable");
    }
}
