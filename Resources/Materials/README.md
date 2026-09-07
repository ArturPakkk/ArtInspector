# Viewport materials

The runtime material library lives in `Resources/Materials`. The portable build mirrors this directory next to the executable, so adding an `.hlsl` or `.glsl` file there is enough for it to appear in the application.

Every `.hlsl` or `.glsl` file in this directory is discovered automatically (every 0.8 seconds), on startup, or when **Reload** / F5 is pressed. Existing parameter values survive reloads by matching name and type. A failed compile keeps the last working shader visible.

The file must implement:

```hlsl
float3 MaterialMain(PSInput input, bool isFrontFace)
```

Metadata is read from comments:

```hlsl
//@name My Checker
//@description A short description shown in the UI.
//@order 50
//@unlit
//@param float Scale|Checker scale|1|256|32
//@param color Tint|Tint color|0.1|0.6|1.0
```

Parameters become HLSL symbols (`Scale`, `Tint`) and automatically appear in the Material Parameters panel. Up to 16 parameters are supported. `.glsl` files use the same `MaterialMain` contract and may use `vec2/3/4`, `mix`, `fract`, `dFdx` and `dFdy`; this compact GLSL subset is translated for the DirectX 11 runtime.

Available input fields: `WorldPosition`, `Normal`, `UV`, `MaterialColor`, `VertexColor`, `UvPerMeter`, and `Flags`. The helper `TexelDensityRatio(input)` returns screen-space UV units per world-space meter.

`FilteredChecker(float2 uv)` returns a pixel-filtered checker in [0,1], including negative UVs and minification. Use it instead of floor/fmod to avoid shimmering. Optional `//@unlit` selects diagnostic shading by default; the user may still switch to Lit. Unlit colors are display colors and bypass exposure/tone mapping. Lit material colors are interpreted as linear reflectance.
