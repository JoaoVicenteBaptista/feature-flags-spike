using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using FeatureFlags.Shared.Services;

namespace FeatureFlags.Functions;

public sealed class FeaturesHttpTrigger
{
    private readonly IFeatureFlagService _featureFlagService;

    public FeaturesHttpTrigger(IFeatureFlagService featureFlagService)
    {
        _featureFlagService = featureFlagService;
    }

    [Function("GetAllFeatures")]
    public async Task<IActionResult> GetAllFeatures(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "api/features")]
        HttpRequest req)
    {
        var features = await _featureFlagService.GetAllAsync();
        return new OkObjectResult(features);
    }

    [Function("GetFeature")]
    public async Task<IActionResult> GetFeature(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "api/features/{name}")]
        HttpRequest req,
        string name)
    {
        var feature = await _featureFlagService.GetAsync(name);
        if (feature is null)
            return new NotFoundResult();
        return new OkObjectResult(feature);
    }
}
