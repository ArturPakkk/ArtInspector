//@unlit
//@name UV Checker
//@description Anti-aliased checkerboard for inspecting UV scale, stretching and seams.
//@order 20
//@param float CheckerScale|Checker scale|2|256|32
//@param float GridStrength|Grid strength|0|1|0.8
//@param color DarkTile|Dark tile|0.035|0.055|0.09
//@param color LightTile|Light tile|0.48|0.58|0.72
//@param color GridColor|Grid color|0.02|0.65|1.0

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    if (input.Flags != 0) return float3(0.9, 0.04, 0.08);
    float2 tileUv = input.UV * CheckerScale;
    float checker = FilteredChecker(tileUv);
    float2 cell = abs(frac(tileUv) - 0.5);
    float edge = max(cell.x, cell.y);
    float lineWidth = max(max(fwidth(tileUv.x), fwidth(tileUv.y)), 0.006);
    float grid = smoothstep(0.5 - lineWidth, 0.5, edge) * GridStrength * (1.0 - smoothstep(0.25, 1.0, lineWidth));
    return lerp(lerp(DarkTile, LightTile, checker), GridColor, grid);
}
