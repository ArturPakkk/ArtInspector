# Art Inspector Checker Materials

This folder contains the seven shipped HLSL materials. Select a material in the
application and adjust its generated controls. F5 reloads materials; file changes
are also detected automatically. Refresh clears the scene and resets checker
parameters. Selecting a material preserves the current Lit/Unlit state.

## Shipped materials

The list follows the menu order. Numbering below is consecutive; original shader
filenames and their host order metadata are retained.

| Position | Material | File |
|---|---|---|
| 1 | Default Materials | `00_default_materials.hlsl` |
| 2 | Texel_Density_Pro | `10_Texel_Density_Pro.hlsl` |
| 3 | UV Precision | `24_uv_PrecisionRisk.hlsl` |
| 4 | UV Repetition Checker_v1 | `23_uv_repetition_checker_v1.hlsl` |
| 5 | Face Orientation | `30_face_orientation.hlsl` |
| 6 | Vertex Color | `40_vertex_color.hlsl` |
| 7 | Shading Checker | `25_shading_checker.hlsl` |

Face Orientation defaults to **Show Faces: Both**. Front and Back remain available.
Lit, Unlit and Wireframe are viewport shading modes; this package does not ship a
separate Solid Wireframe material.

## Creating a material for your own use

Implement the host entry point:

```hlsl
//@name My Checker
//@description Custom diagnostic material.
//@order 50
//@param float Scale|Checker scale|1|256|32
//@param color Tint|Tint color|0.1|0.6|1.0
float3 MaterialMain(PSInput input, bool isFrontFace)
{
    float checker = fmod(floor(input.UV.x * Scale) + floor(input.UV.y * Scale), 2.0);
    return lerp(Tint * 0.15, Tint, checker);
}
```

The current legacy host supports up to 64 parameter slots and choice parameters.
The compact GLSL-like input accepts vec2/3/4, mix, fract, dFdx and dFdy and translates
them to HLSL; it is not a general OpenGL/GLSL renderer. HLSL is used for the shipped
materials. Input fields include WorldPosition, Normal, UV, MaterialColor,
VertexColor, UvPerMeter, Flags and the host-provided WireBarycentric.
FilteredChecker(float2 uv) supplies a filtered checker helper.

The host provides barycentric wireframe coordinates. Emissive is supported;
Bloom is not. Shader reload keeps compatible parameter values; use reset controls
to restore defaults. A shader requiring new host fields cannot simply be installed
into an older executable.

These instructions describe the current shipped set, not the earlier v0.1.0 RAR.
Preserve modified shaders before updating. See [license terms](../../LICENSE.md),
[third-party notices](../../licenses/THIRD_PARTY_NOTICES.md) and
[provenance review](../../docs/licensing/ARTINSPECTOR_PROVENANCE.md).

## UV Precision

`24_uv_PrecisionRisk.hlsl` estimates the maximum FP16 UV rounding error (half one
ULP) in texels; it does not measure actual per-vertex conversion error. Its display
name is **UV Precision**, and its host order metadata is 2. The file is shipped
unchanged from the verified 0.1.4 portable package.

| Parameter | Range | Default |
|---|---|---|
| Texture resolution | 128–16384 | 2048 |
| Warning error (px) | 0.25–64 | 45 |
| Danger error (px) | 1–128 | 49 |
| Critical error (px) | 4–512 | 50 |
| Safe color | RGB 0–1 | (0.08, 0.08, 0.08) |
| Critical color | RGB 0–1 | (1, 0, 1) |

Warning and danger colors are fixed gray (0.35 and 0.65). There is no numeric
overlay, glyph atlas or texture dependency. The existing metadata parser supplies
these six controls. The new material's presence does not establish its ultimate
original authorship or licensing.

### Historical integration record

The source project's 2026-10-05 record describes a copy from an Art Inspector 2
working material supplied for integration. This is a record of technical lineage,
not independent original artwork/code license clearance. MANUAL REVIEW REQUIRED
remains in the licensing/provenance documents; no new license is assigned here.
