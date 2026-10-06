//@name Face Orientation
//@description Inspects rasterized triangle winding independently of vertex normals. Front faces are blue, back faces red. Isolate either side and control back-face HDR emission separately from material lighting.
//@order 4
//@emissive
//@category Face visibility
//@param choice VisibleFaces|Show Faces|0|Both=0|Front=1|Back=2
//@category Face colors
//@param color FrontColor|Front face|0.04|0.25|0.95
//@param color BackColor|Back face|0.9|0.05|0.04
//@category Back-face emission
//@param float RedEmissive|Emission strength|0.0|20.0|8.0|0.1
//@presets Off=0|Low=2|High=8

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // SV_IsFrontFace reflects winding after projection; vertex normals must not
    // be used to classify faces. The host renders both sides (CULL_NONE).
    int faces = (int)round(VisibleFaces);
    clip((faces == 1 && !isFrontFace) || (faces == 2 && isFrontFace) ? -1.0 : 1.0);
    return saturate(isFrontFace ? FrontColor : BackColor);
}

float3 MaterialEmissive(PSInput input, bool isFrontFace)
{
    // Emission is separate from base color and reaches Bloom as linear HDR.
    float strength = isfinite(RedEmissive) ? clamp(RedEmissive, 0.0, 20.0) : 8.0;
    return isFrontFace ? float3(0.0, 0.0, 0.0) : SRGBToLinear(saturate(BackColor)) * strength;
}
