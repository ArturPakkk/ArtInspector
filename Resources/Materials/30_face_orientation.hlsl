//@unlit
//@name Face Orientation
//@description Highlights triangle winding: front faces use adjustable red emissive and back faces are blue.
//@order 30
//@param color FrontColor|Front face|0.9|0.05|0.04
//@param float FrontEmissive|Red emissive|0.0|4.0|1.0
//@param color BackColor|Back face|0.04|0.25|0.95

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Face Orientation is unlit, so this is a true self-lit diagnostic value:
    // zero disables the red output, one preserves the selected FrontColor and
    // values above one increase HDR intensity when the viewport is switched to Lit.
    return isFrontFace ? FrontColor * FrontEmissive : BackColor;
}
