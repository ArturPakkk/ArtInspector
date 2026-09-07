//@unlit
//@name Texel Density
//@description Measures UV0 pixel density in world-space meters. Red is low, green is in range, amber is high.
//@order 10
//@param float TextureResolution|Texture resolution|128|16384|2048
//@param float TargetDensity|Target density (px/m)|32|16384|1024
//@param float Tolerance|Tolerance|0|0.5|0.1
//@param float CheckerScale|Overlay scale|2|128|32
//@param color LowColor|Low density|0.82|0.09|0.08
//@param color GoodColor|In range|0.05|0.65|0.34
//@param color HighColor|High density|1.0|0.48|0.04

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    if (input.Flags != 0) return LowColor;
    float density = TextureResolution * TexelDensityRatio(input);
    float low = TargetDensity * (1.0 - Tolerance);
    float high = TargetDensity * (1.0 + Tolerance);
    float3 diagnostic = density < low ? LowColor : (density > high ? HighColor : GoodColor);
    float checker = FilteredChecker(input.UV * CheckerScale);
    return diagnostic * lerp(0.76, 1.0, checker);
}
