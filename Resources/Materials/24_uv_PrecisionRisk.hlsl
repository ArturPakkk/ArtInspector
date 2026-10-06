//@unlit
//@name UV Precision
//@description Estimates FP16 UV rounding error in texels. Warning and danger levels use fixed gray colors; critical risk is highlighted.
//@order 2

//@param float UVP_TextureRes|Texture resolution|128|16384|2048
//@param float UVP_WarningPx|Warning error (px)|0.25|64|45
//@param float UVP_DangerPx|Danger error (px)|1|128|49
//@param float UVP_CriticalPx|Critical error (px)|4|512|50
//@param color UVP_SafeColor|Safe color|0.08|0.08|0.08
//@param color UVP_CriticalColor|Critical color|1.0|0.0|1.0

static const float UVP_FP16_MIN_NORMAL = 0.00006103515625;
static const float3 UVP_WarningColor = float3(0.35, 0.35, 0.35);
static const float3 UVP_DangerColor = float3(0.65, 0.65, 0.65);

float UVP_SafeFloat(float value, float minimum, float maximum, float fallback)
{
    return isfinite(value) ? clamp(value, minimum, maximum) : fallback;
}

float3 UVP_SafeColorValue(float3 value, float3 fallback)
{
    return all(isfinite(value)) ? saturate(value) : fallback;
}

// Estimate the maximum rounding error (half one FP16 ULP), rather than
// converting interpolated fragment UVs. FP16 has ten fraction bits.
float UVP_CalculateErrorTexels(float2 uv, float textureResolution)
{
    float2 absUV = abs(uv);
    float2 safeMagnitude = max(absUV, float2(UVP_FP16_MIN_NORMAL, UVP_FP16_MIN_NORMAL));
    float2 exponent = floor(log2(safeMagnitude));
    exponent = clamp(exponent, float2(-14.0, -14.0), float2(15.0, 15.0));
    float2 fp16Step = exp2(exponent - 10.0);
    float2 maxUVError = fp16Step * 0.5;
    float2 errorTexelsXY = maxUVError * textureResolution;
    return max(errorTexelsXY.x, errorTexelsXY.y);
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    float3 criticalColor = UVP_SafeColorValue(UVP_CriticalColor, float3(1.0, 0.0, 1.0));
    if (!all(isfinite(input.UV)))
        return criticalColor;

    float textureResolution = UVP_SafeFloat(UVP_TextureRes, 128.0, 16384.0, 2048.0);
    float warningPx = UVP_SafeFloat(UVP_WarningPx, 0.25, 64.0, 45.0);
    float dangerPx = UVP_SafeFloat(UVP_DangerPx, 1.0, 128.0, 49.0);
    float criticalPx = UVP_SafeFloat(UVP_CriticalPx, 4.0, 512.0, 50.0);
    dangerPx = max(dangerPx, warningPx);
    criticalPx = max(criticalPx, dangerPx);

    float3 safeColor = UVP_SafeColorValue(UVP_SafeColor, float3(0.08, 0.08, 0.08));
    float errorTexels = UVP_CalculateErrorTexels(input.UV, textureResolution);
    float warning = smoothstep(warningPx * 0.75, warningPx, errorTexels);
    float danger = smoothstep(dangerPx * 0.75, dangerPx, errorTexels);
    float critical = smoothstep(criticalPx * 0.75, criticalPx, errorTexels);

    float3 result = lerp(safeColor, UVP_WarningColor, warning);
    result = lerp(result, UVP_DangerColor, danger);
    return lerp(result, criticalColor, critical);
}
