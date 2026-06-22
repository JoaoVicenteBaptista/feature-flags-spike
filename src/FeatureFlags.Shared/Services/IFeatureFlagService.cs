using FeatureFlags.Shared.Models;

namespace FeatureFlags.Shared.Services;

public interface IFeatureFlagService
{
    Task<IReadOnlyList<FeatureFlagResponse>> GetAllAsync();
    Task<FeatureFlagResponse?> GetAsync(string name);
}
