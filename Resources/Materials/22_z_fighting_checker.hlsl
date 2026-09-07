//@unlit
//@name Z-Fighting Checker
//@description Makes overlapping and nearly coplanar triangles obvious. Each triangle receives a stable contrasting pattern, so depth conflicts flicker between clearly different colors while the camera moves.
//@order 22
//@param float PatternScale|Screen pattern scale|2|64|12
//@param float PatternStrength|Pattern strength|0|1|0.35
//@param float DepthBands|Depth precision bands|16|4096|768
//@param color ColorA|Diagnostic color A|1.0|0.04|0.42
//@param color ColorB|Diagnostic color B|0.0|0.78|1.0

float TriangleHash(uint triangleIndex)
{
    return frac(sin((float)(triangleIndex + 1u) * 12.9898) * 43758.5453);
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    if (input.Flags != 0) return float3(1.0, 0.55, 0.0);

    // Coplanar triangles normally look identical with an ordinary material.
    // Giving every triangle a stable identity makes a changing depth winner
    // immediately visible as cyan/magenta flicker while orbiting the camera.
    const float triangleClass = step(0.5, TriangleHash(input.TriangleIndex));
    const float3 diagnosticColor = lerp(ColorA, ColorB, triangleClass);

    // A screen-space micro pattern makes small conflict areas readable, while
    // depth bands expose surfaces approaching limited depth-buffer precision.
    const float2 screenCell = floor(input.Position.xy / max(PatternScale, 1.0));
    const float screenPattern = fmod(screenCell.x + screenCell.y, 2.0);
    const float depthPattern = step(0.5, frac(input.Position.z * DepthBands));
    const float brightness = lerp(1.0 - PatternStrength, 1.0,
        lerp(screenPattern, depthPattern, 0.35));

    return diagnosticColor * brightness;
}
