//@name Shading Checker
//@description Image-based matcap checker reconstructed from the reference: reflection mapping plus a vertex/flat-normal comparison.
//@order 25
//@unlit
//@param float FlatShading|Flat shading|0|1|0
//@param float ReflectionMapping|Reflection mapping|0|1|1
//@param float Contrast|Matcap contrast|0.25|3|1.25
//@param float RimStrength|Rim strength|0|2|0.55
//@param float HighlightStrength|Studio highlight|0|2|0.55
//@param color ColorMultiplier|Color multiplier|0.92|0.96|1.0

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    float3 vertexNormal = normalize(isFrontFace ? input.Normal : -input.Normal);

    // Faceted hard normal, matching the DDX/DDY branch in the reference graph.
    float3 flatNormal = normalize(cross(ddy(input.WorldPosition), ddx(input.WorldPosition)));
    if (dot(flatNormal, vertexNormal) < 0.0) flatNormal = -flatNormal;
    float3 normal = normalize(lerp(vertexNormal, flatNormal, saturate(FlatShading)));

    float3 toCamera = normalize(CameraPosition.xyz - input.WorldPosition);
    float3 reflected = normalize(reflect(-toCamera, normal));
    float3 viewReflection = float3(dot(reflected, CameraRight.xyz),
        dot(reflected, CameraUp.xyz), dot(reflected, CameraForward.xyz));

    // Sphere/reflection mapping from the upper branch in the reference graph.
    float denominator = max(sqrt(max(viewReflection.z + 1.0, 0.0001)) * 2.828427, 0.0001);
    float2 reflectionUv = viewReflection.xy / denominator + 0.5;
    reflectionUv.y = 1.0 - reflectionUv.y;
    float2 planarUv = viewReflection.xy * float2(0.5, -0.5) + 0.5;
    float2 uv = lerp(planarUv, reflectionUv, saturate(ReflectionMapping));

    // Procedural neutral matcap image. Continuous highlights reveal waviness,
    // incorrect weighted normals and smoothing seams.
    float2 p = uv * 2.0 - 1.0;
    float radius = saturate(length(p));
    float body = 0.16 + pow(saturate(1.0 - radius), 0.7) * 0.54;
    float key = exp(-dot(p - float2(-0.34, -0.30), p - float2(-0.34, -0.30)) * 9.0) * HighlightStrength;
    float fill = exp(-dot(p - float2(0.48, 0.24), p - float2(0.48, 0.24)) * 9.0) * 0.25;
    float rim = pow(radius, 4.0) * RimStrength;
    float sweep = smoothstep(0.015, 0.0, abs(p.y + p.x * 0.32 - 0.08)) * 0.18;
    float value = saturate((body + key + fill + rim + sweep - 0.5) * Contrast + 0.5);
    return value * ColorMultiplier;
}
