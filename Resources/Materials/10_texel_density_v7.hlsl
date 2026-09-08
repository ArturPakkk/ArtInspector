//@unlit
//@name Texel Density v7
//@description Camera-independent texel-density diagnostic with UV stretch detection. Fixed at 2048 texture resolution and 1024 px/m target density. Yellow marks anisotropic UV stretch. Magenta always marks invalid or collapsed UVs.
//@order 10
//@param float Tolerance|Tolerance|0|0.5|0.1
//@param float UVStretchHighlight|UV Stretch Highlight|0|1|1
//@param float StretchSensitivity|Stretch Sensitivity|0|1|0.5
//@param float CheckerScale|Overlay scale|2|128|32
//@param color LowColor|Low density|0.82|0.09|0.08
//@param color GoodColor|In range|0.05|0.65|0.34
//@param color HighColor|High density|1.0|0.48|0.04
//@param color InvalidUVColor|Invalid / collapsed UV|1.0|0.0|0.75

struct UVAnalysis
{
    float IsInvalid;
    float StretchRatio;
};

UVAnalysis AnalyzeUV(PSInput input)
{
    UVAnalysis result;
    result.IsInvalid = 0.0;
    result.StretchRatio = 1.0;

    float3 dpdx = ddx(input.WorldPosition);
    float3 dpdy = ddy(input.WorldPosition);

    float2 duvdx = ddx(input.UV);
    float2 duvdy = ddy(input.UV);

    // Screen-space projected areas.
    float worldProjectedArea = length(cross(dpdx, dpdy));

    float uvDet =
        duvdx.x * duvdy.y -
        duvdx.y * duvdy.x;

    float uvProjectedArea = abs(uvDet);

    // Detect missing / point-collapsed / line-collapsed UVs.
    //
    // Important:
    // We compare UV projected area against WORLD projected area.
    // The camera projection factor exists in both and therefore mostly cancels.
    // This is much more stable than checking abs(uvDet) alone.
    if (worldProjectedArea > 1e-12)
    {
        float uvAreaPerWorldArea =
            uvProjectedArea / worldProjectedArea;

        if (uvAreaPerWorldArea <= 1e-10)
        {
            result.IsInvalid = 1.0;
            return result;
        }
    }
    else
    {
        // At an extreme grazing angle the projected world area itself can
        // become numerically unusable. Do not invent an invalid UV from camera
        // orientation; fall back to mesh-provided density information.
        if (input.UvPerMeter <= 0.000001)
        {
            result.IsInvalid = 1.0;
        }

        return result;
    }

    // We already know the UV mapping has usable area.
    float invDet = 1.0 / uvDet;

    // Reconstruct the world-space vectors corresponding to one UV unit.
    float3 dPdu =
        (dpdx * duvdy.y - dpdy * duvdx.y) * invDet;

    float3 dPdv =
        (-dpdx * duvdy.x + dpdy * duvdx.x) * invDet;

    // Metric tensor G = J^T J.
    float a = dot(dPdu, dPdu);
    float b = dot(dPdu, dPdv);
    float c = dot(dPdv, dPdv);

    float trace = a + c;

    float discriminant = sqrt(max(
        (a - c) * (a - c) +
        4.0 * b * b,
        0.0
    ));

    float lambdaMax = max(
        0.5 * (trace + discriminant),
        1e-12
    );

    float lambdaMin = max(
        0.5 * (trace - discriminant),
        1e-12
    );

    result.StretchRatio = sqrt(lambdaMax / lambdaMin);

    return result;
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Fixed project values — intentionally hidden from UI.
    const float TextureResolution = 2048.0;
    const float TargetDensity = 1024.0;

    const float3 StretchColor = float3(1.0, 0.92, 0.05);

    // Runtime/import invalid state always has highest priority.
    if (input.Flags != 0)
    {
        return InvalidUVColor;
    }

    UVAnalysis uv = AnalyzeUV(input);

    // Missing / collapsed UV always stays magenta.
    // It is completely independent from UVStretchHighlight.
    if (uv.IsInvalid > 0.5)
    {
        return InvalidUVColor;
    }

    float uvPerMeter = max(input.UvPerMeter, 0.0);
    float density = TextureResolution * uvPerMeter;

    if (density <= 0.001)
    {
        return InvalidUVColor;
    }

    // ------------------------------------------------------------
    // TEXEL DENSITY
    // ------------------------------------------------------------

    float low =
        TargetDensity * (1.0 - Tolerance);

    float high =
        TargetDensity * (1.0 + Tolerance);

    float3 diagnostic =
        density < low
        ? LowColor
        : (density > high ? HighColor : GoodColor);

    // ------------------------------------------------------------
    // UV STRETCH
    // ------------------------------------------------------------
    //
    // Sensitivity 0.0:
    //   only obvious distortion is highlighted.
    //
    // Sensitivity 0.5:
    //   roughly matches the behavior of v6.
    //
    // Sensitivity 1.0:
    //   catches small deviations from square proportions.
    //

    float sensitivity =
        saturate(StretchSensitivity);

    float stretchStart = lerp(
        1.30,   // lenient
        1.03,   // strict
        sensitivity
    );

    float stretchFull = lerp(
        2.00,   // lenient
        1.20,   // strict
        sensitivity
    );

    float stretchSeverity = smoothstep(
        stretchStart,
        stretchFull,
        uv.StretchRatio
    );

    float stretchAmount =
        saturate(UVStretchHighlight) *
        stretchSeverity;

    diagnostic = lerp(
        diagnostic,
        StretchColor,
        stretchAmount
    );

    // ------------------------------------------------------------
    // CHECKER
    // ------------------------------------------------------------

    float checker =
        FilteredChecker(input.UV * CheckerScale);

    return diagnostic * lerp(
        0.76,
        1.0,
        checker
    );
}
