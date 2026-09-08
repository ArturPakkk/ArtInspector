//@unlit
//@name Texel Density v5
//@description Texel-density diagnostic with optional UV stretch highlighting. Fixed at 2048 texture resolution and 1024 px/m target density. Yellow highlights anisotropic UV distortion where checker squares become rectangles.
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
    // Screen derivatives of world-space position and UV.
    // We use both together to reconstruct the local world/UV Jacobian.
    // Projection/camera scale cancels out in the reconstruction.
    float3 dpdx = ddx(input.Position);
    float3 dpdy = ddy(input.Position);

    float2 duvdx = ddx(input.UV);
    float2 duvdy = ddy(input.UV);

    float det =
        duvdx.x * duvdy.y -
        duvdx.y * duvdy.x;

    // Degenerate derivative matrix.
    if (abs(det) < 1e-8)
    {
        return 1.0;
    }

    float invDet = 1.0 / det;

    // World-space change for one UV unit along U and V.
    float3 dPdu =
        (dpdx * duvdy.y - dpdy * duvdx.y) * invDet;

    float3 dPdv =
        (-dpdx * duvdy.x + dpdy * duvdx.x) * invDet;

    // Metric tensor G = J^T * J.
    // Its eigenvalues are the squared principal stretch values.
    float a = dot(dPdu, dPdu);
    float b = dot(dPdu, dPdv);
    float c = dot(dPdv, dPdv);

    float trace = a + c;
    float discriminant = sqrt(max(
        (a - c) * (a - c) + 4.0 * b * b,
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

    return sqrt(lambdaMax / lambdaMin);
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // Fixed project values.
    const float TextureResolution = 2048.0;
    const float TargetDensity = 1024.0;

    // UV stretch warning thresholds.
    // 1.0 = perfect isotropic mapping.
    const float StretchStart = 1.10;
    const float StretchFull  = 1.50;

    // Fixed warning color to keep the material UI clean.
    const float3 StretchColor = float3(1.0, 0.92, 0.05);

    if (input.Flags != 0)
    {
        return InvalidUVColor;
    }

    // Stable texel-density value from the mesh/runtime input.
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

    // Detect anisotropic UV distortion:
    // 1.0  -> square checker remains square
    // >1.0 -> one UV direction is stretched relative to the other
    float stretchRatio = ComputeUVStretchRatio(input);

    float stretchSeverity = smoothstep(
        StretchStart,
        StretchFull,
        stretchRatio
    );

    float stretchAmount =
        saturate(UVStretchHighlight) *
        stretchSeverity;

    // Blend toward yellow only where UV proportions are distorted.
    diagnostic = lerp(
        diagnostic,
        StretchColor,
        stretchAmount
    );

    float checker = FilteredChecker(
        input.UV * CheckerScale
    );

    return diagnostic * lerp(
        0.76,
        1.0,
        checker
    );
}
