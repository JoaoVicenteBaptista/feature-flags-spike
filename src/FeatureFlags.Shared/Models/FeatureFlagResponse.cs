namespace FeatureFlags.Shared.Models;

public sealed record FeatureFlagResponse(string Name, bool Enabled, string Source);
