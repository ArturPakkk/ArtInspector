//@name Default Materials
//@description Displays material colors imported from the FBX file.
//@order 0

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    return pow(saturate(input.MaterialColor.rgb), 1.0 / 2.2);
}
