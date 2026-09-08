//@unlit
//@name Texel Density v3
//@description Measures UV0 pixel density in world-space meters. Fixed at 2048 texture resolution and 1024 px/m target density. Red is low, green is in range, amber is high. Magenta marks invalid or collapsed UVs.
//@order 10
//@param float Tolerance|Tolerance|0|0.5|0.1
//@param float CheckerScale|Overlay scale|2|128|32
//@param color LowColor|Low density|0.82|0.09|0.08
//@param color GoodColor|In range|0.05|0.65|0.34
//@param color HighColor|High density|1.0|0.48|0.04
//@param color InvalidUVColor|Invalid / collapsed UV|1.0|0.0|0.75

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Fixed project values — intentionally not exposed in the material UI.
    const float TextureResolution = 2048.0;
    const float TargetDensity = 1024.0;

    // Same invalid/runtime flag handling as Texel Density v2.
    if (input.Flags != 0)
    {
        return InvalidUVColor;
    }

    float uvPerMeter = max(TexelDensityRatio(input), 0.0);
    float density = TextureResolution * uvPerMeter;

    // Collapsed / zero-area UVs are invalid instead of merely "low density".
    if (density <= 0.001)
    {
        return InvalidUVColor;
    }

    // Original Texel Density v1 diagnostic logic.
    float low = TargetDensity * (1.0 - Tolerance);
    float high = TargetDensity * (1.0 + Tolerance);

    float3 diagnostic =
        density < low
        ? LowColor
        : (density > high ? HighColor : GoodColor);

    float checker = FilteredChecker(input.UV * CheckerScale);

    return diagnostic * lerp(0.76, 1.0, checker);
}
