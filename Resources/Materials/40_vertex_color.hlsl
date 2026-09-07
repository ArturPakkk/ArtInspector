//@unlit
//@name Vertex Color
//@description Displays the vertex color data stored in the FBX mesh.
//@order 40
//@param float Intensity|Intensity|0|4|1

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    return pow(saturate(input.VertexColor.rgb), 1.0 / 2.2) * Intensity;
}
