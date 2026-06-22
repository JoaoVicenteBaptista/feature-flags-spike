using Microsoft.AspNetCore.Mvc;
using FeatureFlags.Shared.Services;

namespace FeatureFlags.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class FeaturesController : ControllerBase
{
    private readonly IFeatureFlagService _featureFlagService;

    public FeaturesController(IFeatureFlagService featureFlagService)
    {
        _featureFlagService = featureFlagService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var features = await _featureFlagService.GetAllAsync();
        return Ok(features);
    }

    [HttpGet("{name}")]
    public async Task<IActionResult> Get(string name)
    {
        var feature = await _featureFlagService.GetAsync(name);
        if (feature is null)
            return NotFound();
        return Ok(feature);
    }
}
