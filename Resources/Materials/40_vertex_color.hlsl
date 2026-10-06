//@name Vertex Color
//@description Inspects linear mesh vertex colors. R/G/B are grayscale; RGB shows all channels. Missing vertex colors use the importer's white default.
//@order 5
//@category Channels
//@param choice Channel|Channel|3|R=0|G=1|B=2|RGB=3
//@category Display
//@param float Intensity|Intensity|0|4|1|0.01

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Importers supply linear vertex color; the material ABI expects display RGB.
    // The Unlit path applies the inverse transfer, avoiding a double gamma.
    float3 linearColor = float3(isfinite(input.VertexColor.r) ? saturate(input.VertexColor.r) : 0,
                                isfinite(input.VertexColor.g) ? saturate(input.VertexColor.g) : 0,
                                isfinite(input.VertexColor.b) ? saturate(input.VertexColor.b) : 0);
    int channel = (int)round(Channel);
    float3 color = channel == 0 ? linearColor.rrr : channel == 1 ? linearColor.ggg
                               : channel == 2 ? linearColor.bbb : linearColor;
    float intensity = isfinite(Intensity) ? clamp(Intensity, 0.0, 4.0) : 1.0;
    return pow(color, 1.0 / 2.2) * intensity;
}
