//@name Shading Checker v2
//@description Procedural studio matcap with robust normal handling, filtered highlights and optional reflection lines. Flat/smooth comparison is preserved. Invalid source normals use InvalidNormalColor; unavailable geometry/camera analysis is neutral gray.
//@order 25
//@unlit
//@param float FlatShading|Flat shading|0|1|0
//@param float ReflectionMapping|Reflection mapping|0|1|1
//@param float Contrast|Matcap contrast|0.25|3|1.25
//@param float RimStrength|Rim strength|0|2|0.55
//@param float HighlightStrength|Studio highlight|0|2|0.55
//@param float MatcapRotation|Studio rotation (degrees)|0|360|0
//@param float ReflectionLines|Reflection lines|0|1|0
//@param float LineDensity|Line density|2|32|12
//@param color ColorMultiplier|Color multiplier|0.92|0.96|1.0
//@param color InvalidNormalColor|Invalid normal|1.0|0.0|0.75

// Based on the supplied 25_shading_checker.hlsl, not on the texel-density shader.
// Unchanged host interface:
//   MaterialMain(PSInput input, bool isFrontFace) -> float3
//   input.Normal, input.WorldPosition
//   CameraPosition, CameraRight, CameraUp, CameraForward (existing .xyz fields)
// The host declares parameter variables from the //@param metadata.
//
// Assumptions inherited from v1:
// - Normal and WorldPosition use the same Euclidean world space.
// - CameraPosition is the eye of a perspective camera. Orthographic rendering
//   needs a host-provided projection flag; this shader does not invent one.
// - Camera basis signs/orientation are preserved, including either handedness.
// No UV, textures, normal map, tangent data or new vertex attributes are needed.
// No input.Flags test: the meaning of those flags is not defined by this file.
//
// This is a visual shading diagnostic, NOT an automatic verdict that a hard
// edge, a weighted normal, or an inverted normal is an error. Reflections are
// intentionally view dependent. Derivatives cannot recover precision already
// lost in the host's world-position/normal interpolation.

static const float SC2_MIN_NORMAL = 1.17549435e-38;
static const float SC2_REL_ROUNDOFF = 3.814697265625e-6;
static const float SC2_PI = 3.14159265358979323846;
static const float3 SC2_UNCERTAIN_COLOR = float3(0.35, 0.35, 0.35);

struct SC2Direction
{
    float3 Unit;
    float Valid;
};

struct SC2Frame
{
    float3 Right;
    float3 Up;
    float3 Forward;
    float Valid;
};

struct SC2Projection
{
    float2 P;
    float DirectionalWeight;
};

float SC2_MaxAbs3(float3 value)
{
    float3 magnitude = abs(value);
    return max(magnitude.x, max(magnitude.y, magnitude.z));
}

float SC2_Parameter(float value, float minimum, float maximum, float fallback)
{
    return isfinite(value) ? clamp(value, minimum, maximum) : fallback;
}

float3 SC2_Color(float3 value, float3 fallback)
{
    return all(isfinite(value)) ? saturate(value) : fallback;
}

SC2Direction SC2_Unit3(float3 value)
{
    SC2Direction result;
    // Finite internal substitute so subsequent derivative operations can run.
    // Valid stays zero; the substitute is NOT treated as a measured normal.
    result.Unit = float3(0.0, 0.0, 1.0);
    result.Valid = 0.0;

    if (!all(isfinite(value)))
    {
        return result;
    }

    float scale = SC2_MaxAbs3(value);
    if (scale < SC2_MIN_NORMAL)
    {
        return result;
    }

    // Normalize after rescaling to avoid both dot(v,v) overflow and underflow.
    precise float3 scaled = value / scale;
    precise float lengthSquared = dot(scaled, scaled);
    result.Unit = scaled * rsqrt(lengthSquared);
    result.Valid = 1.0;
    return result;
}

SC2Direction SC2_FlatNormal(float3 positionDx, float3 positionDy)
{
    SC2Direction x = SC2_Unit3(positionDx);
    SC2Direction y = SC2_Unit3(positionDy);

    // Unlike a UV stretch ratio, a normal only needs the cross-product
    // DIRECTION. Independent positive rescaling of these derivatives is safe.
    precise float3 positive = y.Unit.yzx * x.Unit.zxy;
    precise float3 negative = y.Unit.zxy * x.Unit.yzx;
    precise float3 normalCross = positive - negative;
    precise float crossLength = length(normalCross);
    precise float cancellationBound = SC2_REL_ROUNDOFF *
        length(abs(positive) + abs(negative));

    SC2Direction result = SC2_Unit3(normalCross);
    if (x.Valid < 0.5 || y.Valid < 0.5 || crossLength <= cancellationBound)
    {
        result.Valid = 0.0;
    }
    return result;
}

SC2Frame SC2_CameraFrame(float3 rightInput, float3 upInput, float3 forwardInput)
{
    SC2Direction r = SC2_Unit3(rightInput);
    SC2Direction uInput = SC2_Unit3(upInput);
    SC2Direction fInput = SC2_Unit3(forwardInput);
    precise float3 upResidual = uInput.Unit - r.Unit * dot(r.Unit, uInput.Unit);
    SC2Direction u = SC2_Unit3(upResidual);
    SC2Direction f = SC2_Unit3(cross(r.Unit, u.Unit));
    float alignment = dot(f.Unit, fInput.Unit);

    SC2Frame result;
    result.Right = r.Unit;
    result.Up = u.Unit;
    // Do not assume a right- or left-handed host camera convention.
    result.Forward = alignment < 0.0 ? -f.Unit : f.Unit;
    result.Valid = 1.0;
    if (r.Valid < 0.5 || uInput.Valid < 0.5 || fInput.Valid < 0.5 ||
        u.Valid < 0.5 || f.Valid < 0.5 ||
        SC2_MaxAbs3(upResidual) <= SC2_REL_ROUNDOFF || abs(alignment) < 0.5)
    {
        result.Valid = 0.0;
    }
    return result;
}

SC2Projection SC2_Project(float3 viewReflection, float mapping)
{
    // Same sphere-map convention as v1, in p = 2*uv-1 coordinates.
    // For a UNIT reflection vector the equivalent radial expression avoids
    // subtractive loss in 1+z close to the south pole:
    //   radius = sqrt((1-z)/2), azimuth = normalize(reflection.xy).
    // In the north hemisphere use xy / sqrt(2*(1+z)) instead: 1-z would lose
    // precision there. No small denominator is used in either hemisphere.
    float2 planar = viewReflection.xy * float2(1.0, -1.0);
    float2 spherical = float2(0.0, 0.0);
    float directionalWeight = 1.0;

    if (viewReflection.z >= 0.0)
    {
        spherical = planar / sqrt(2.0 * (1.0 + viewReflection.z));
    }
    else
    {
        SC2Direction azimuth = SC2_Unit3(float3(planar, 0.0));
        float2 direction = azimuth.Valid > 0.5 ? azimuth.Unit.xy : float2(1.0, 0.0);
        float radius = sqrt(saturate(0.5 * (1.0 - viewReflection.z)));
        spherical = direction * radius;

        // Sphere mapping has no unique azimuth at the exact south pole.
        // Fade directional details there, retaining the radial body/rim.
        // This is deliberate visualization regularization, not recovered data.
        if (mapping > 0.0)
        {
            float poleWidth = max(0.015 * mapping, 1.0e-6);
            directionalWeight = smoothstep(0.0, poleWidth, length(planar));
        }
    }

    SC2Projection result;
    result.P = lerp(planar, spherical, mapping);
    result.DirectionalWeight = directionalWeight;
    return result;
}

// Antiderivative of the original symmetric compact cubic sweep profile:
// 1 - smoothstep(0, halfWidth, abs(x)). Its full integral equals halfWidth.
float SC2_SweepIntegral(float x, float halfWidth)
{
    float t = saturate(abs(x) / halfWidth);
    float t2 = t * t;
    float integral = halfWidth * (t - t2 * t + 0.5 * t2 * t2);
    return x < 0.0 ? -integral : integral;
}

float SC2_FilteredSweep(float coordinate, float footprint)
{
    const float halfWidth = 0.015;
    float width = max(footprint, 0.0);
    if (width < 1.0e-4)
    {
        return 1.0 - smoothstep(0.0, halfWidth, abs(coordinate));
    }

    // A 1D box approximation to the projected pixel footprint. Subpixel lines
    // lose intensity rather than being widened to an opaque screen-sized line.
    float hi = SC2_SweepIntegral(coordinate + 0.5 * width, halfWidth);
    float lo = SC2_SweepIntegral(coordinate - 0.5 * width, halfWidth);
    return saturate((hi - lo) / width);
}

// Gaussian approximation to pixel filtering of exp(-9*dot(p-center,p-center)).
// z stores the off-diagonal of the inverse filter matrix, w the amplitude.
float4 SC2_GaussianFilter(float2 pDx, float2 pDy)
{
    const float coefficient = 1.5; // 2 * exponent(9) * pixel variance(1/12)
    float a = 1.0 + coefficient * (pDx.x * pDx.x + pDy.x * pDy.x);
    float b = coefficient * (pDx.x * pDx.y + pDy.x * pDy.y);
    float c = 1.0 + coefficient * (pDx.y * pDx.y + pDy.y * pDy.y);
    float area = pDx.x * pDy.y - pDx.y * pDy.x;
    // Positive expansion of a*c-b*b avoids cancellation.
    float determinant = 1.0 + coefficient * (dot(pDx, pDx) + dot(pDy, pDy)) +
        coefficient * coefficient * area * area;
    return float4(c / determinant, a / determinant, -b / determinant,
        rsqrt(determinant));
}

float SC2_FilteredHighlight(float2 offset, float4 kernel)
{
    float quadratic = kernel.x * offset.x * offset.x +
        2.0 * kernel.z * offset.x * offset.y + kernel.y * offset.y * offset.y;
    return kernel.w * exp(-9.0 * max(quadratic, 0.0));
}

float SC2_Sinc(float cycles)
{
    float phase = SC2_PI * cycles;
    if (abs(phase) < 0.001)
    {
        return 1.0 - phase * phase * (1.0 / 6.0);
    }
    return sin(phase) / phase;
}

float SC2_FilteredLines(float coordinate, float derivativeX, float derivativeY)
{
    // Exact box filtering of a locally linear sinusoid across both pixel axes.
    float attenuation = SC2_Sinc(derivativeX) * SC2_Sinc(derivativeY);
    // Additional minification fade suppresses residual undersampling above
    // roughly half a cycle per pixel. Far-away lines tend to neutral gray.
    float footprint = max(abs(derivativeX), abs(derivativeY));
    attenuation *= 1.0 - smoothstep(0.35, 1.0, footprint);
    float bands = 0.5 + 0.5 * cos(2.0 * SC2_PI * coordinate) * attenuation;
    return lerp(0.12, 0.88, saturate(bands));
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // No material-level early returns until ALL derivative operations finish.
    precise float3 positionDx = ddx(input.WorldPosition);
    precise float3 positionDy = ddy(input.WorldPosition);

    float flatAmount = SC2_Parameter(FlatShading, 0.0, 1.0, 0.0);
    float mapping = SC2_Parameter(ReflectionMapping, 0.0, 1.0, 1.0);
    float contrast = SC2_Parameter(Contrast, 0.25, 3.0, 1.25);
    float rimStrength = SC2_Parameter(RimStrength, 0.0, 2.0, 0.55);
    float highlightStrength = SC2_Parameter(HighlightStrength, 0.0, 2.0, 0.55);
    float rotation = SC2_Parameter(MatcapRotation, 0.0, 360.0, 0.0);
    float lineAmount = SC2_Parameter(ReflectionLines, 0.0, 1.0, 0.0);
    float lineDensity = SC2_Parameter(LineDensity, 2.0, 32.0, 12.0);
    float3 tint = SC2_Color(ColorMultiplier, float3(0.92, 0.96, 1.0));
    float3 invalidNormalColor = SC2_Color(InvalidNormalColor, float3(1.0, 0.0, 0.75));

    SC2Direction vertexNormal = SC2_Unit3(isFrontFace ? input.Normal : -input.Normal);
    SC2Direction flatNormal = SC2_FlatNormal(positionDx, positionDy);
    // Preserve the original hemisphere alignment and smooth/flat blend.
    if (dot(flatNormal.Unit, vertexNormal.Unit) < 0.0)
    {
        flatNormal.Unit = -flatNormal.Unit;
    }
    float3 safeFlat = flatNormal.Valid > 0.5 ? flatNormal.Unit : vertexNormal.Unit;
    SC2Direction normal = SC2_Unit3(lerp(vertexNormal.Unit, safeFlat, flatAmount));

    SC2Frame frame = SC2_CameraFrame(CameraRight.xyz, CameraUp.xyz, CameraForward.xyz);
    precise float3 eyeVector = CameraPosition.xyz - input.WorldPosition;
    SC2Direction toCamera = SC2_Unit3(eyeVector);
    SC2Direction reflection = SC2_Unit3(reflect(-toCamera.Unit, normal.Unit));
    SC2Direction viewReflection = SC2_Unit3(float3(
        dot(reflection.Unit, frame.Right), dot(reflection.Unit, frame.Up),
        dot(reflection.Unit, frame.Forward)));
    SC2Projection projection = SC2_Project(viewReflection.Unit, mapping);

    float sine;
    float cosine;
    sincos(rotation * (SC2_PI / 180.0), sine, cosine);
    float2 p = float2(cosine * projection.P.x - sine * projection.P.y,
                     sine * projection.P.x + cosine * projection.P.y);
    precise float2 pDx = ddx(p);
    precise float2 pDy = ddy(p);
    // All helper paths reconverge before these derivative instructions.
    // Shading uses derivative-free filtering from this point onward.

    // Invalid SOURCE normal remains visible even with Flat shading = 1.
    if (vertexNormal.Valid < 0.5)
    {
        return invalidNormalColor;
    }
    if (!all(isfinite(input.WorldPosition)) || !all(isfinite(CameraPosition.xyz)) ||
        frame.Valid < 0.5 || toCamera.Valid < 0.5 || normal.Valid < 0.5 ||
        reflection.Valid < 0.5 || viewReflection.Valid < 0.5 ||
        !all(isfinite(p)) || !all(isfinite(pDx)) || !all(isfinite(pDy)))
    {
        return SC2_UNCERTAIN_COLOR;
    }
    if (flatAmount > 0.0 && flatNormal.Valid < 0.5)
    {
        // Never silently claim that a fallback vertex normal is a flat normal.
        return SC2_UNCERTAIN_COLOR;
    }

    float radius = saturate(length(p));
    float body = 0.16 + pow(saturate(1.0 - radius), 0.7) * 0.54;
    float4 highlightFilter = SC2_GaussianFilter(pDx, pDy);
    float key = SC2_FilteredHighlight(p - float2(-0.34, -0.30), highlightFilter) *
        highlightStrength;
    float fill = SC2_FilteredHighlight(p - float2(0.48, 0.24), highlightFilter) * 0.25;
    float radiusSquared = radius * radius;
    float rim = radiusSquared * radiusSquared * rimStrength;
    float sweepCoordinate = p.y + p.x * 0.32 - 0.08;
    float sweepFootprint = abs(pDx.y + pDx.x * 0.32) + abs(pDy.y + pDy.x * 0.32);
    float sweep = SC2_FilteredSweep(sweepCoordinate, sweepFootprint) * 0.18;
    float studioValue = body + rim + projection.DirectionalWeight * (key + fill + sweep);
    float matcapValue = saturate((studioValue - 0.5) * contrast + 0.5);

    float cyclesPerUnit = 0.5 * lineDensity; // Density = cycles across the matcap diameter.
    float lineValue = SC2_FilteredLines(p.x * cyclesPerUnit,
        pDx.x * cyclesPerUnit, pDy.x * cyclesPerUnit);
    float value = lerp(matcapValue, lineValue, lineAmount * projection.DirectionalWeight);
    if (!isfinite(value))
    {
        return SC2_UNCERTAIN_COLOR;
    }
    return saturate(value) * tint;
}
