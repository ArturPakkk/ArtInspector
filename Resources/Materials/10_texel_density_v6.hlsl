//@unlit
//@name Texel Density v6
//@description Camera-independent texel-density diagnostic with UV stretch highlighting. Fixed at 2048 texture resolution and 1024 px/m target density. Yellow highlights anisotropic UV distortion where checker squares become rectangles.
//@order 10
//@param float Tolerance|Tolerance|0|0.5|0.1
//@param float UVStretchHighlight|UV Stretch Highlight|0|1|1
//@param float CheckerScale|Overlay scale|2|128|32
//@param color LowColor|Low density|0.82|0.09|0.08
//@param color GoodColor|In range|0.05|0.65|0.34
//@param color HighColor|High density|1.0|0.48|0.04
//@param color InvalidUVColor|Invalid / collapsed UV|1.0|0.0|0.75

float ComputeUVStretchRatio(PSInput input)
{
    // IMPORTANT:
    // Use WORLD position derivatives, not screen/SV position derivatives.
    // Screen projection then cancels when reconstructing the local UV->world Jacobian.
    float3 dpdx = ddx(input.WorldPosition);
    float3 dpdy = ddy(input.WorldPosition);

    float2 duvdx = ddx(input.UV);
    float2 duvdy = ddy(input.UV);

    float det =
        duvdx.x * duvdy.y -
        duvdx.y * duvdy.x;

    // Degenerate / numerically unusable UV derivative matrix.
    if (abs(det) < 1e-10)
    {
        return 1.0;
    }

    float invDet = 1.0 / det;

    // World-space vectors corresponding to one UV unit along U and V.
    float3 dPdu =
        (dpdx * duvdy.y - dpdy * duvdx.y) * invDet;

    float3 dPdv =
        (-dpdx * duvdy.x + dpdy * duvdx.x) * invDet;

    // Metric tensor:
    //
    // [ dot(dPdu,dPdu)  dot(dPdu,dPdv) ]
    // [ dot(dPdu,dPdv)  dot(dPdv,dPdv) ]
    //
    // Eigenvalues are squared principal world-space stretches of the UV mapping.
    float a = dot(dPdu, dPdu);
    float b = dot(dPdu, dPdv);
    float c = dot(dPdv, dPdv);

    float trace = a + c;

    float discriminant = sqrt(max(
        (a - c) * (a - c) +
        4.0 * b * b,
        0.0
    ));

    float lambdaMax = max(
        0.5 * (trace + discriminant),
        1e-12
    );

    float lambdaMin = max(
        0.5 * (trace - discriminant),
        1e-12
    );

    // 1.0 = isotropic mapping (checker remains square).
    // >1.0 = UV is stretched more in one principal direction.
    return sqrt(lambdaMax / lambdaMin);
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Fixed project values — intentionally not exposed in the UI.
    const float TextureResolution = 2048.0;
    const float TargetDensity = 1024.0;

    // UV stretch thresholds.
    const float StretchStart = 1.10;
    const float StretchFull  = 1.50;

    const float3 StretchColor = float3(1.0, 0.92, 0.05);

    if (input.Flags != 0)
    {
        return InvalidUVColor;
    }

    // Stable texel-density source.
    float uvPerMeter = max(input.UvPerMeter, 0.0);
    float density = TextureResolution * uvPerMeter;

    if (density <= 0.001)
    {
        return InvalidUVColor;
    }

    float low = TargetDensity * (1.0 - Tolerance);
    float high = TargetDensity * (1.0 + Tolerance);

    float3 diagnostic =
        density < low
        ? LowColor
        : (density > high ? HighColor : GoodColor);

    // Camera-independent UV anisotropy test.
    float stretchRatio = ComputeUVStretchRatio(input);

    float stretchSeverity = smoothstep(
        StretchStart,
        StretchFull,
        stretchRatio
    );

    float stretchAmount =
        saturate(UVStretchHighlight) *
        stretchSeverity;

    diagnostic = lerp(
        diagnostic,
        StretchColor,
        stretchAmount
    );

    // Checker remains filtered in screen space only for anti-aliasing.
    float checker = FilteredChecker(
        input.UV * CheckerScale
    );

    return diagnostic * lerp(
        0.76,
        1.0,
        checker
    );
}
