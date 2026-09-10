//@unlit
//@name Texel Density v9
//@description Mesh texel density with scale-normalized UV stretch analysis. Fixed 2048 texture resolution and 1024 px/m target. Invalid UV uses InvalidUVColor; inconclusive derivative analysis is neutral gray. Checker Strength controls checker contrast.
//@order 10
//@param float Tolerance|Tolerance|0|0.5|0.1
//@param float UVStretchHighlight|UV Stretch Highlight|0|1|1
//@param float StretchSensitivity|Stretch Sensitivity|0|1|0.5
//@param float CheckerScale|Overlay scale|2|128|32
//@param float CheckerStrength|Checker Strength|0|1|0.24
//@param color LowColor|Low density|0.82|0.09|0.08
//@param color GoodColor|In range|0.05|0.65|0.34
//@param color HighColor|High density|1.0|0.48|0.04
//@param color StretchColor|UV Stretch|1.0|0.92|0.05
//@param color InvalidUVColor|Invalid / collapsed UV|1.0|0.0|0.75

// Host contract is unchanged from the supplied v8:
// PSInput.WorldPosition, .UV, .UvPerMeter, .Flags; FilteredChecker(float2).
// The host supplies parameter variables from the //@param declarations.
// WorldPosition must be a Euclidean position, NOT SV_Position. UV and
// WorldPosition must describe the same surface with compatible interpolation.
// UvPerMeter remains the host-provided density source; it is not recomputed.
//
// v9 only changes this material. It does not require new vertex attributes.
// Derivative analysis is stateless: it cannot recover precision already lost
// by the host's interpolation, nor prove that an absent UV channel was replaced
// with synthetic UVs. Gray means inconclusive, NOT "valid" or "collapsed".

static const uint TD9_UNCERTAIN = 0u;
static const uint TD9_VALID = 1u;
static const uint TD9_INVALID = 2u;

// Storage limit, not a UV-area threshold. Avoid reciprocal overflow / denormals.
static const float TD9_MIN_NORMAL = 1.17549435e-38;
// Dimensionless conditioning threshold for the normalized position derivatives.
static const float TD9_MIN_WORLD_QUALITY = 1.0e-5;
// 32 * float32 machine epsilon: a conservative cancellation guard.
static const float TD9_REL_ROUNDOFF = 3.814697265625e-6;
// A display diagnostic does not need unbounded ratios. This is far above every
// warning threshold; larger trustworthy ratios retain a full stretch warning.
static const float TD9_MAX_STRETCH = 1000000.0;

struct TD9UVAnalysis
{
    uint State;
    // Only meaningful when State == TD9_VALID; zero is an unavailable sentinel.
    float StretchRatio;
};

float TD9_MaxAbs2(float2 value)
{
    float2 magnitude = abs(value);
    return max(magnitude.x, magnitude.y);
}

float TD9_MaxAbs3(float3 value)
{
    float3 magnitude = abs(value);
    return max(magnitude.x, max(magnitude.y, magnitude.z));
}

float TD9_SafeParameter(float value, float minimum, float maximum, float fallback)
{
    return isfinite(value) ? clamp(value, minimum, maximum) : fallback;
}

float3 TD9_SafeColor(float3 value, float3 fallback)
{
    // These diagnostic colors are normalized RGB, not HDR lighting values.
    return all(isfinite(value)) ? saturate(value) : fallback;
}

// No derivative operations inside this function. All four inputs are collected
// unconditionally by MaterialMain before any per-pixel early return.
TD9UVAnalysis TD9_AnalyzeUV(
    float3 positionDx, float3 positionDy,
    float2 uvDx, float2 uvDy)
{
    TD9UVAnalysis result;
    result.State = TD9_UNCERTAIN;
    result.StretchRatio = 0.0;

    // Bad intermediate data is not evidence of a collapsed source UV island.
    if (!all(isfinite(positionDx)) || !all(isfinite(positionDy)) ||
        !all(isfinite(uvDx)) || !all(isfinite(uvDy)))
    {
        return result;
    }

    float positionScale = max(TD9_MaxAbs3(positionDx), TD9_MaxAbs3(positionDy));
    if (positionScale < TD9_MIN_NORMAL)
    {
        return result;
    }

    // ONE shared scale for the position pair. Independent normalization of the
    // X and Y derivatives would change the mapping being measured.
    precise float3 px = positionDx / positionScale;
    precise float3 py = positionDy / positionScale;
    precise float3 worldCross = cross(px, py);
    precise float worldArea = length(worldCross);
    precise float worldEnergy = dot(px, px) + dot(py, py);

    if (!isfinite(worldArea) || !isfinite(worldEnergy) ||
        worldArea <= TD9_MIN_WORLD_QUALITY * worldEnergy)
    {
        return result;
    }

    float uvScale = max(TD9_MaxAbs2(uvDx), TD9_MaxAbs2(uvDy));
    if (uvScale == 0.0)
    {
        // The observed UV is constant while the observed geometry has area.
        result.State = TD9_INVALID;
        return result;
    }
    if (uvScale < TD9_MIN_NORMAL)
    {
        return result;
    }

    // ONE shared scale for the UV pair. Uniformly tiny nonzero UVs remain
    // analyzable: there is no absolute UV-area cutoff in this material.
    precise float2 ux = uvDx / uvScale;
    precise float2 uy = uvDy / uvScale;
    precise float determinantPositive = ux.x * uy.y;
    precise float determinantNegative = ux.y * uy.x;
    precise float uvDet = determinantPositive - determinantNegative;
    float absUvDet = abs(uvDet);

    if (!isfinite(uvDet))
    {
        return result;
    }
    if (absUvDet == 0.0)
    {
        // Zero area in the observed UV derivatives: point or line collapse.
        // Like any derivative-only test, this cannot distinguish an actual
        // collapse from UV precision already lost before this function ran.
        result.State = TD9_INVALID;
        return result;
    }

    // A small determinant caused by subtraction of nearly equal products is
    // inconclusive. A small but well-resolved product is NOT automatically bad.
    float determinantError = TD9_REL_ROUNDOFF *
        (abs(determinantPositive) + abs(determinantNegative));
    if (absUvDet <= determinantError || absUvDet < TD9_MIN_NORMAL)
    {
        return result;
    }

    // Numerators of dP/du and dP/dv. Their shared 1/uvDet is not needed when
    // taking the ratio of principal stretches, so do not divide by uvDet.
    precise float3 axisU = px * uy.y - py * ux.y;
    precise float3 axisV = py * ux.x - px * uy.x;
    float axisScale = max(TD9_MaxAbs3(axisU), TD9_MaxAbs3(axisV));
    if (!isfinite(axisScale) || axisScale < TD9_MIN_NORMAL)
    {
        return result;
    }

    // Again, ONE common factor. Separately normalizing U and V would erase
    // the very scale imbalance that the stretch diagnostic must detect.
    precise float3 aU = axisU / axisScale;
    precise float3 aV = axisV / axisScale;
    precise float metricUU = dot(aU, aU);
    precise float metricUV = dot(aU, aV);
    precise float metricVV = dot(aV, aV);
    precise float metricDifference = metricUU - metricVV;
    precise float discriminantSquared = metricDifference * metricDifference +
        4.0 * metricUV * metricUV;
    precise float lambdaMax = 0.5 *
        (metricUU + metricVV + sqrt(max(discriminantSquared, 0.0)));

    // Stretch = lambdaMax / length(cross(aU, aV)).
    // Evaluate the cross-product area using the equivalent identity
    // cross(axisU, axisV) = uvDet * cross(px, py).
    // This avoids another subtraction of near-equal products when the U/V
    // axes are almost parallel. Division order avoids squaring a tiny scale.
    precise float principalArea =
        (absUvDet / axisScale) * (worldArea / axisScale);

    if (!isfinite(lambdaMax) || lambdaMax <= 0.0 ||
        !isfinite(principalArea) || principalArea < 0.0)
    {
        return result;
    }

    // No trace - discriminant, no tiny lambdaMin clamp, no unbounded division.
    // A zero principalArea here can only be a numeric underflow after a
    // nonzero, checked uvDet: retain a saturated stretch warning, not "good".
    precise float stretch = TD9_MAX_STRETCH;
    if (principalArea > lambdaMax / TD9_MAX_STRETCH)
    {
        stretch = lambdaMax / principalArea;
    }
    if (!isfinite(stretch))
    {
        return result;
    }

    result.State = TD9_VALID;
    result.StretchRatio = clamp(stretch, 1.0, TD9_MAX_STRETCH);
    return result;
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    const float TextureResolution = 2048.0;
    const float TargetDensity = 1024.0;
    const float3 UncertainColor = float3(0.35, 0.35, 0.35);

    // Gather derivatives before ANY material-level per-pixel early exit.
    precise float3 positionDx = ddx(input.WorldPosition);
    precise float3 positionDy = ddy(input.WorldPosition);
    precise float2 uvDx = ddx(input.UV);
    precise float2 uvDy = ddy(input.UV);

    float checkerScale = TD9_SafeParameter(CheckerScale, 2.0, 128.0, 32.0);
    float checkerStrength = TD9_SafeParameter(CheckerStrength, 0.0, 1.0, 0.24);

    // Keep the host's existing checker implementation. Call it unconditionally
    // here because it may use derivatives internally. Sanitize only its input;
    // the UV analysis above still sees the original, unsanitized derivatives.
    precise float2 checkerCoords = input.UV * checkerScale;
    checkerCoords = all(isfinite(checkerCoords)) ? checkerCoords : float2(0.0, 0.0);
    float checkerRaw = FilteredChecker(checkerCoords);
    float checker = isfinite(checkerRaw) ? saturate(checkerRaw) : 0.5;
    float checkerBrightness = lerp(1.0 - checkerStrength, 1.0, checker);

    float3 invalidColor = TD9_SafeColor(InvalidUVColor, float3(1.0, 0.0, 0.75));

    // Preserve v8's opaque nonzero-Flags convention; do not reinterpret bits.
    // Non-finite UV coordinates or invalid mesh density also have priority.
    if (input.Flags != 0 || !all(isfinite(input.UV)) ||
        !isfinite(input.UvPerMeter) || input.UvPerMeter <= 0.0)
    {
        return invalidColor;
    }
    if (!all(isfinite(input.WorldPosition)))
    {
        return UncertainColor * checkerBrightness;
    }

    TD9UVAnalysis uv = TD9_AnalyzeUV(positionDx, positionDy, uvDx, uvDy);
    if (uv.State == TD9_INVALID)
    {
        // Solid invalid color: independent of stretch and checker strengths.
        return invalidColor;
    }
    if (uv.State != TD9_VALID)
    {
        // Never disguise an unavailable stretch result as StretchRatio = 1.
        // Neutral gray deliberately replaces the diagnostic, even when
        // UVStretchHighlight is zero. It is not an extra UV error category.
        return UncertainColor * checkerBrightness;
    }

    float tolerance = TD9_SafeParameter(Tolerance, 0.0, 0.5, 0.1);
    float sensitivity = TD9_SafeParameter(StretchSensitivity, 0.0, 1.0, 0.5);
    float highlight = TD9_SafeParameter(UVStretchHighlight, 0.0, 1.0, 1.0);

    float3 lowColor = TD9_SafeColor(LowColor, float3(0.82, 0.09, 0.08));
    float3 goodColor = TD9_SafeColor(GoodColor, float3(0.05, 0.65, 0.34));
    float3 highColor = TD9_SafeColor(HighColor, float3(1.0, 0.48, 0.04));
    float3 stretchColor = TD9_SafeColor(StretchColor, float3(1.0, 0.92, 0.05));

    // Equivalent to comparing 2048 * UvPerMeter with 1024 * (1 +/- Tolerance),
    // without risking overflow in 2048 * an exceptionally large finite input.
    // Tiny POSITIVE mesh density is LOW, not automatically INVALID.
    float targetUvPerMeter = TargetDensity / TextureResolution;
    float low = targetUvPerMeter * (1.0 - tolerance);
    float high = targetUvPerMeter * (1.0 + tolerance);
    float3 diagnostic = input.UvPerMeter < low ? lowColor :
        (input.UvPerMeter > high ? highColor : goodColor);

    // Exact v8 sensitivity curve: do not silently change the user's settings.
    // 0.0 -> 1.30 / 2.00; 0.5 -> 1.165 / 1.60; 1.0 -> 1.03 / 1.20.
    float stretchStart = lerp(1.30, 1.03, sensitivity);
    float stretchFull = lerp(2.00, 1.20, sensitivity);
    float stretchSeverity = smoothstep(stretchStart, stretchFull, uv.StretchRatio);
    diagnostic = lerp(diagnostic, stretchColor, highlight * stretchSeverity);

    // Default CheckerStrength = 0.24 exactly preserves v8's 0.76..1.00 range.
    // Strength 0 removes only the checker, not invalid/uncertain diagnostics.
    return diagnostic * checkerBrightness;
}
