//@unlit
//@name Texel Density v4
//@description Camera-independent UV0 texel-density diagnostic using mesh UvPerMeter. Fixed at 2048 texture resolution and 1024 px/m target density. Red is low, green is in range, amber is high. Magenta marks invalid or collapsed UVs.
//@order 10
//@param float Tolerance|Tolerance|0|0.5|0.1
//@param float CheckerScale|Overlay scale|2|128|32
//@param color LowColor|Low density|0.82|0.09|0.08
//@param color GoodColor|In range|0.05|0.65|0.34
//@param color HighColor|High density|1.0|0.48|0.04
//@param color InvalidUVColor|Invalid / collapsed UV|1.0|0.0|0.75

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Fixed project values — intentionally hidden from Material Parameters.
    const float TextureResolution = 2048.0;
    const float TargetDensity = 1024.0;

    // Import/runtime invalid state.
    if (input.Flags != 0)
    {
        return InvalidUVColor;
    }

    // v4:
    // Use the mesh-provided UV-per-meter value instead of
    // TexelDensityRatio(input), which is screen-space derivative based.
    // This keeps the density diagnostic independent of camera angle/distance.
    float uvPerMeter = max(input.UvPerMeter, 0.0);
    float density = TextureResolution * uvPerMeter;

    // Collapsed / zero-area / unavailable UV density.
    if (density <= 0.001)
    {
        return InvalidUVColor;
    }

    float low = TargetDensity * (1.0 - Tolerance);
    float high = TargetDensity * (1.0 + Tolerance);

    float3 diagnostic =
        density < low
        ? LowColor
        : (density > high ? HighColor : GoodColor);

    // The checker itself remains pixel-filtered on purpose.
    // Only its anti-aliasing may react to distance; diagnostic color does not.
    float checker = FilteredChecker(input.UV * CheckerScale);

    return diagnostic * lerp(0.76, 1.0, checker);
}
