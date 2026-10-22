// Native geometry diagnostic. Independent of material macros and scene lighting.
// Bits match diagnostics/z_fighting_types.h. Red marks entire affected triangles.
StructuredBuffer<uint> TriangleStatus : register(t2);
cbuffer DiagnosticConstants : register(b1) { uint TriangleCount; uint3 Reserved; };
// Preserve the complete VS output signature and register ordering.
struct PSInput {
    float4 Position : SV_POSITION;
    float3 WorldPosition : TEXCOORD3;
    float3 Normal : NORMAL;
    float2 UV : TEXCOORD0;
    float4 MaterialColor : COLOR0;
    float4 VertexColor : COLOR1;
    nointerpolation float UvPerMeter : TEXCOORD1;
    nointerpolation uint Flags : TEXCOORD2;
    nointerpolation uint TriangleIndex : TEXCOORD4;
    noperspective float3 WireBarycentric : TEXCOORD5;
};
struct PSOutput { float4 Color : SV_TARGET0; float TexelDensity : SV_TARGET1; };
PSOutput PSMain(PSInput input) {
    uint status=0;
    if((input.Flags & 0x30000u)==0 && input.TriangleIndex<TriangleCount)
        status=TriangleStatus[input.TriangleIndex];
    float3 color=float3(0.20,0.30,0.43); // unverified / pending / incomplete
    if((status & 14u)!=0) color=float3(0.95,0.035,0.025);
    else if((status & 16u)!=0) color=float3(0.72,0.15,0.60);
    else if((status & 32u)!=0) color=float3(0.94,0.62,0.12);
    else if((status & 1u)!=0) color=float3(0.36,0.38,0.41);
    PSOutput output;output.Color=float4(color,1);output.TexelDensity=-1;return output;
}
