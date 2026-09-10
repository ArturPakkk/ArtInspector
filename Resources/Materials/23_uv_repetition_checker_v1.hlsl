//@unlit
//@name UV Repetition Checker v1
//@description Visual macro-pattern test, NOT an automatic UV-overlap detector. Mode 0 reveals reuse of raw UV coordinates; Mode 1 previews a repeating UV pattern; Mode 2 is a continuous 3D world-space reference. Repeated distinctive patch shapes reveal repeated mapping, not a red/green verdict.
//@order 23
//@param float CoordinateMode|Mode (0 UV / 1 Repeat / 2 World)|0|2|0
//@param float UVPatternScale|UV pattern scale|2|32|4
//@param float RepeatTiling|Repeat tiling|0.05|16|1
//@param float WorldPatchSize|World patch size (world units)|0.1|10000|10
//@param float PatternSeed|Pattern seed|0|255|7
//@param float PatternContrast|Pattern contrast|0.5|3|2
//@param color DarkColor|Dark patches|0.08|0.08|0.08
//@param color LightColor|Light patches|0.85|0.85|0.85

// Existing host interface only:
//   float3 MaterialMain(PSInput input, bool isFrontFace)
//   input.UV : float2; input.WorldPosition : float3, Euclidean world position.
// The host generates parameter symbols from the metadata above.
// No textures, samplers, additional vertex fields, buffers or C++ changes.
//
// IMPORTANT INTERPRETATION:
// - This is a VISUAL repetition preview. It cannot count other triangles using
//   the same UVs, calculate overlap coverage, or certify that UVs are unique.
// - Raw UV mode does NOT wrap the input to 0..1. The local fractional part in
//   value noise is interpolation inside a cell; the cell ID is retained.
// - Repeat mode is intentionally periodic, with period 1/RepeatTiling in each
//   input-UV direction. It models WRAP, not MIRROR, UDIM or a texture atlas.
// - World mode ignores UV and evaluates a true 3D field. It is not a flat XY
//   projection and needs no assumption about the application's up axis.
// - A single seed is shared by ALL geometry. Do not add per-triangle/object
//   randomization here: that would hide the UV reuse this test should reveal.
// - Only the UV channel supplied as input.UV is inspected. Original material
//   UV transforms, texture contents, secondary UV channels and layering are
//   not available to this shader and are not inferred.
// - Finite but absent/default/constant UVs produce a uniform patch. This file
//   does not infer the semantics of input.Flags or diagnose UV validity.
// - Derivatives only fade undersampled pattern detail. This is a conservative
//   heuristic, not exact anisotropic texture filtering. It does not classify
//   UVs from camera angle. Tiny distant patches can fade to the midpoint.
// - World coordinates must be consistent across draws. Moving an object in
//   world space changes its world-mode pattern. Moving the camera does not
//   move the underlying field; pixel filtering can change visible detail.
//
// Magenta means unusable/nonfinite/out-of-range coordinates for THIS preview,
// not proof of overlapping or missing UVs. Shader arithmetic uses float32;
// precision already lost in input coordinates cannot be recovered here.

static const float UR1_MAX_BASE_COORD = 65536.0;
static const float3 UR1_UNUSABLE_COLOR = float3(1.0, 0.0, 0.75);

float UR1_Parameter(float value, float minimum, float maximum, float fallback)
{
    return isfinite(value) ? clamp(value, minimum, maximum) : fallback;
}

float3 UR1_Color(float3 value, float3 fallback)
{
    return all(isfinite(value)) ? saturate(value) : fallback;
}

float UR1_MaxAbs2(float2 p)
{
    float2 a = abs(p);
    return max(a.x, a.y);
}

float UR1_MaxAbs3(float3 p)
{
    float3 a = abs(p);
    return max(a.x, max(a.y, a.z));
}

// Integer avalanche: no sine-based hash or time-dependent random values.
uint UR1_Mix(uint value)
{
    value ^= value >> 16u;
    value *= 0x7feb352du;
    value ^= value >> 15u;
    value *= 0x846ca68bu;
    value ^= value >> 16u;
    return value;
}

float UR1_Hash2(int2 cell, uint seed)
{
    uint h = UR1_Mix(asuint(cell.x) ^ 0x9e3779b9u);
    h = UR1_Mix(h ^ asuint(cell.y) ^ UR1_Mix(seed + 0x85ebca6bu));
    return float(h >> 8u) * (1.0 / 16777216.0);
}

float UR1_Hash3(int3 cell, uint seed)
{
    uint h = UR1_Mix(asuint(cell.x) ^ 0x9e3779b9u);
    h = UR1_Mix(h ^ asuint(cell.y) ^ 0xc2b2ae35u);
    h = UR1_Mix(h ^ asuint(cell.z) ^ UR1_Mix(seed + 0x85ebca6bu));
    return float(h >> 8u) * (1.0 / 16777216.0);
}

int2 UR1_WrapCell(int2 cell, int period)
{
    // period is positive here. Correct negative-coordinate remainder too.
    int2 wrapped = cell % period;
    wrapped.x += wrapped.x < 0 ? period : 0;
    wrapped.y += wrapped.y < 0 ? period : 0;
    return wrapped;
}

float UR1_Corner2(int2 cell, uint seed, int period)
{
    if (period > 0)
    {
        cell = UR1_WrapCell(cell, period);
    }
    return UR1_Hash2(cell, seed);
}

float UR1_Noise2(float2 p, uint seed, int period)
{
    int2 cell = int2(floor(p));
    float2 f = frac(p);
    // Quintic interpolation: smooth transitions at noise-cell boundaries.
    float2 t = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    float a = UR1_Corner2(cell,                seed, period);
    float b = UR1_Corner2(cell + int2(1, 0), seed, period);
    float c = UR1_Corner2(cell + int2(0, 1), seed, period);
    float d = UR1_Corner2(cell + int2(1, 1), seed, period);
    return lerp(lerp(a, b, t.x), lerp(c, d, t.x), t.y);
}

float UR1_Noise3(float3 p, uint seed)
{
    int3 cell = int3(floor(p));
    float3 f = frac(p);
    float3 t = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    float x00 = lerp(UR1_Hash3(cell,                   seed),
                     UR1_Hash3(cell + int3(1, 0, 0), seed), t.x);
    float x10 = lerp(UR1_Hash3(cell + int3(0, 1, 0), seed),
                     UR1_Hash3(cell + int3(1, 1, 0), seed), t.x);
    float x01 = lerp(UR1_Hash3(cell + int3(0, 0, 1), seed),
                     UR1_Hash3(cell + int3(1, 0, 1), seed), t.x);
    float x11 = lerp(UR1_Hash3(cell + int3(0, 1, 1), seed),
                     UR1_Hash3(cell + int3(1, 1, 1), seed), t.x);
    return lerp(lerp(x00, x10, t.y), lerp(x01, x11, t.y), t.z);
}

float UR1_DetailWeight(float footprint)
{
    // Smoothly suppress noise whose cells become subpixel. This intentionally
    // fades to 0.5, not to a diagnosis that the UVs are correct or incorrect.
    return 1.0 - smoothstep(0.35, 0.90, footprint);
}

float UR1_Pattern2(float2 p, float2 dx, float2 dy, uint seed, int period)
{
    float footprint = min(max(UR1_MaxAbs2(dx), UR1_MaxAbs2(dy)), 8.0) * 1.41421356;
    float value = 0.5;
    float frequency = 1.0;
    float amplitude = 1.0 / 1.875; // Normalize 1 + 1/2 + 1/4 + 1/8.
    int octavePeriod = period;

    [unroll]
    for (int octave = 0; octave < 4; ++octave)
    {
        float weight = UR1_DetailWeight(footprint * frequency);
        if (weight > 0.0)
        {
            uint octaveSeed = seed + uint(octave) * 0x9e3779b9u;
            float n = UR1_Noise2(p * frequency, octaveSeed, octavePeriod);
            value += (n - 0.5) * amplitude * weight;
        }
        frequency *= 2.0;
        amplitude *= 0.5;
        octavePeriod *= 2; // Zero stays zero in the non-wrapped mode.
    }
    return saturate(value);
}

float UR1_Pattern3(float3 p, float3 dx, float3 dy, uint seed)
{
    float footprint = min(max(UR1_MaxAbs3(dx), UR1_MaxAbs3(dy)), 8.0) * 1.73205081;
    float value = 0.5;
    float frequency = 1.0;
    float amplitude = 1.0 / 1.875;

    [unroll]
    for (int octave = 0; octave < 4; ++octave)
    {
        float weight = UR1_DetailWeight(footprint * frequency);
        if (weight > 0.0)
        {
            uint octaveSeed = seed + uint(octave) * 0x9e3779b9u;
            float n = UR1_Noise3(p * frequency, octaveSeed);
            value += (n - 0.5) * amplitude * weight;
        }
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return saturate(value);
}

float3 MaterialMain(PSInput input, bool isFrontFace)
{
    // All derivatives precede branches and early returns. No derivatives of
    // frac/floor/wrapped coordinates are taken.
    float2 uvDx = ddx(input.UV);
    float2 uvDy = ddy(input.UV);
    float3 worldDx = ddx(input.WorldPosition);
    float3 worldDy = ddy(input.WorldPosition);

    int mode = int(floor(UR1_Parameter(CoordinateMode, 0.0, 2.0, 0.0) + 0.5));
    uint seed = uint(floor(UR1_Parameter(PatternSeed, 0.0, 255.0, 7.0) + 0.5));
    float contrast = UR1_Parameter(PatternContrast, 0.5, 3.0, 2.0);
    float3 dark = UR1_Color(DarkColor, float3(0.08, 0.08, 0.08));
    float3 light = UR1_Color(LightColor, float3(0.85, 0.85, 0.85));
    float pattern = 0.5;

    if (mode == 2)
    {
        // A 3D continuous field crosses roof strips without reading their UV.
        // Units are exactly the units of input.WorldPosition, not assumed m/cm.
        float size = UR1_Parameter(WorldPatchSize, 0.1, 10000.0, 10.0);
        float3 p = input.WorldPosition / size;
        float3 dx = worldDx / size;
        float3 dy = worldDy / size;
        if (!all(isfinite(p)) || !all(isfinite(dx)) || !all(isfinite(dy)) ||
            UR1_MaxAbs3(p) > UR1_MAX_BASE_COORD)
        {
            return UR1_UNUSABLE_COLOR;
        }
        pattern = UR1_Pattern3(p, dx, dy, seed);
    }
    else
    {
        float scale = UR1_Parameter(UVPatternScale, 2.0, 32.0, 4.0);
        float tiling = 1.0;
        int period = 0;
        if (mode == 1)
        {
            // An integer number of lattice cells gives a seamless repeat tile.
            // UI scale is rounded ONLY in this mode; tiling is not rounded.
            period = int(floor(scale + 0.5));
            scale = float(period);
            tiling = UR1_Parameter(RepeatTiling, 0.05, 16.0, 1.0);
        }
        float factor = scale * tiling;
        float2 p = input.UV * factor;
        float2 dx = uvDx * factor;
        float2 dy = uvDy * factor;
        if (!all(isfinite(p)) || !all(isfinite(dx)) || !all(isfinite(dy)) ||
            UR1_MaxAbs2(p) > UR1_MAX_BASE_COORD)
        {
            return UR1_UNUSABLE_COLOR;
        }
        pattern = UR1_Pattern2(p, dx, dy, seed, period);
    }

    float brightness = saturate((pattern - 0.5) * contrast + 0.5);
    return lerp(dark, light, brightness);
}
