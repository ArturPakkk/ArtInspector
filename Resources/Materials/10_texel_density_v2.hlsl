//@unlit
//@name Texel Density v2
//@description Continuous UV0 texel-density diagnostic with selectable checker or line-grid overlay. Green is within tolerance; color intensity increases with the severity of under/over density. Magenta marks invalid or collapsed UVs.
//@order 10
//@param float TextureResolution|Texture resolution|128|16384|2048
//@param float TargetDensity|Target density (px/m)|32|16384|1024
//@param float Tolerance|Tolerance|0|0.5|0.1
//@param float FullWarningAt|Full warning at (x target)|1.1|4|2
//@param float Pattern|Pattern (0 Checker / 1 Lines)|0|1|0
//@param float CheckerScale|Overlay scale|2|128|32
//@param float CheckerStrength|Overlay strength|0|0.6|0.6
//@param color LowColor|Low density|0.82|0.09|0.08
//@param color GoodColor|In range|0.05|0.65|0.34
//@param color HighColor|High density|1.0|0.48|0.04
//@param color InvalidUVColor|Invalid / collapsed UV|1.0|0.0|0.75

float GridLines(float2 uv)
{
    float2 cell = abs(frac(uv) - 0.5);
    float edge = max(cell.x, cell.y);

    // Anti-aliased cell borders. Fade the grid when it becomes too dense
    // on screen so it does not turn into noisy moire patterns.
    float lineWidth = max(max(fwidth(uv.x), fwidth(uv.y)), 0.006);
    float grid = smoothstep(0.5 - lineWidth, 0.5, edge);
    grid *= 1.0 - smoothstep(0.25, 1.0, lineWidth);

    return saturate(grid);
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Import/runtime flags are treated separately from an ordinary density error.
    if (input.Flags != 0)
    {
        return InvalidUVColor;
    }

    float uvPerMeter = max(TexelDensityRatio(input), 0.0);
    float density = TextureResolution * uvPerMeter;

    // A zero-area/collapsed UV island should not look like merely "very low" density.
    if (density <= 0.001)
    {
        return InvalidUVColor;
    }

    float target = max(TargetDensity, 0.001);
    float densityRatio = max(density / target, 0.000001);

    // Log2 makes the diagnostic symmetric:
    // 0.5x target and 2.0x target are equally severe in opposite directions.
    float signedStops = log2(densityRatio);
    float absStops = abs(signedStops);

    float lowToleranceRatio = max(1.0 - Tolerance, 0.000001);
    float highToleranceRatio = max(1.0 + Tolerance, 1.000001);

    float lowToleranceStops = -log2(lowToleranceRatio);
    float highToleranceStops = log2(highToleranceRatio);
    float toleranceStops = signedStops < 0.0 ? lowToleranceStops : highToleranceStops;

    float fullWarningMultiplier = max(FullWarningAt, 1.0001);
    float fullWarningStops = max(log2(fullWarningMultiplier), toleranceStops + 0.0001);

    // 0 = inside tolerance, 1 = full warning color.
    float severity = saturate(
        (absStops - toleranceStops) /
        (fullWarningStops - toleranceStops)
    );

    // Smooth the transition so small measurement noise around the tolerance
    // boundary does not create a visually harsh color step.
    severity = severity * severity * (3.0 - 2.0 * severity);

    float3 warningColor = signedStops < 0.0 ? LowColor : HighColor;
    float3 diagnostic = lerp(GoodColor, warningColor, severity);

    float2 overlayUv = input.UV * CheckerScale;

    // Pattern 0: filled checker tiles.
    float checker = FilteredChecker(overlayUv);
    float checkerBrightness = lerp(1.0 - CheckerStrength, 1.0, checker);

    // Pattern 1: only anti-aliased UV cell borders.
    float lines = GridLines(overlayUv);
    float linesBrightness = lerp(1.0, 1.0 - CheckerStrength, lines);

    // Hard switch around the middle of the 0..1 parameter range.
    float useLines = step(0.5, Pattern);
    float overlayBrightness = lerp(checkerBrightness, linesBrightness, useLines);

    return diagnostic * overlayBrightness;
}
