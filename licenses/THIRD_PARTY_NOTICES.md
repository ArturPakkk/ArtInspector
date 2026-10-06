# Third-party notices — ArtInspector

Third-party rights are independent of the ArtInspector proprietary license.
The texts below accompany this executable distribution.

| Component / use | Copyright / license | Accompanying text |
| --- | --- | --- |
| Dear ImGui 1.92.9, docking build, Win32/DX11 backends; compiled UI | 2014–2026 Omar Cornut; MIT | native/Dear-ImGui-MIT.txt |
| ufbx 0.23.0; compiled model importer | 2020 Samuli Raivio; MIT alternative | native/ufbx-LICENSE.txt |
| ImGui-modified stb_truetype 1.26, stb_rect_pack 1.01, stb_textedit 1.14; font rasterization/atlas/text editing | 2017 Sean Barrett; MIT alternative | native/imstb_truetype-LICENSE.txt, native/imstb_rectpack-LICENSE.txt, native/imstb_textedit-LICENSE.txt |
| DirectXMath / DirectXCollision; SDK inline geometry | Microsoft Corporation; MIT | native/DirectXMath-MIT.txt |
| ProggyClean; font embedded in ImGui | 2004, 2005 Tristan Grimmer; MIT | fonts/ProggyClean-MIT.txt |
| ProggyForever minimal; font embedded in ImGui | 2026 Disco Hello; 2019,2023 Tristan Grimmer; MIT | fonts/ProggyForever-MIT.txt |
| HDRI_01.hdr, HDRI_02.hdr; environment maps | Poly Haven asset contributors; CC0 1.0 | assets/PolyHaven.txt, assets/CC0-1.0.txt |

ImGui also embeds public-domain stb_decompress code in imgui_draw.cpp.
The modified stb source headers retain their upstream modification annotations.
MIT components require preservation of copyright and permission notices;
no source-disclosure or separate NOTICE obligation was found in these texts.
CC0 attribution is voluntary; the source/provenance record is retained here.

## Upstream sources

- https://github.com/ocornut/imgui (license copied from this project's vendored version)
- https://github.com/ufbx/ufbx (license copied from this project's vendored version)
- https://github.com/nothings/stb (licenses extracted from vendored imstb headers)
- https://github.com/microsoft/DirectXMath/blob/main/LICENSE
- https://github.com/bluescan/proggyfonts/blob/master/LICENSE
- https://github.com/ocornut/proggyforever/blob/master/LICENSE.txt
- https://polyhaven.com/license

Official external texts retrieved 2026-09-22. Local imgui_draw.cpp identifies
both embedded fonts and their copyright holders. ProggyForever is a minimal
variant embedded by ImGui, not a new ArtInspector font.

## Windows components

Direct3D 11, DXGI, D3DCompiler, WIC, Win32 and system fonts are supplied by
Windows, not copied into this package. Segoe UI, Segoe UI Bold and Consolas are
loaded from the installed Windows Fonts directory. Do not copy those font files
into releases. MSVC runtime code is statically linked by the current build;
its redistribution is governed by the applicable Visual Studio terms.

## Provenance requiring review

The procedural UI icon coordinates/tokens, application logo and bundled checker
shaders lack a complete author/source provenance record. They are not assigned
an invented third-party license here. LICENSE REQUIRES MANUAL REVIEW before
public redistribution. Source/Icons describes possible Unreal candidate assets,
but those candidate SVG files are not present or packaged; this does not prove
that all procedural shapes were independently authored.

## Evidence limits and historical builds

This inventory is verified against the associated current native build inputs;
those private development inputs are not published by this distribution repository.
Both original release RAR executables identify ImGui 1.92.9 and both Proggy font
names. They contain ufbx diagnostic strings, but an exact ufbx/SDK/toolchain version
cannot be certified for every historical EXE without its original build record.
The oldest available associated source snapshot declares ufbx 0.23.0; that is
corroborating evidence, not proof of an earlier executable's exact version.
See [the per-artifact audit](../docs/licensing/DEPENDENCY_LICENSE_AUDIT.md).

Ultimate origin/authorship of UI icons and the logo has not been conclusively established. MANUAL REVIEW REQUIRED. No third-party license is assigned without file-level evidence. If an upstream source is identified, record the exact repository, package, file/version, license, NOTICE requirements and modification requirements.


## Art Inspector 0.1.4 package inventory — 2026-10-06

The earlier audit above is a historical snapshot. This package supplies seven
HLSL material files:

- `00_default_materials.hlsl`
- `10_Texel_Density_Pro.hlsl`
- `23_uv_repetition_checker_v1.hlsl`
- `24_uv_PrecisionRisk.hlsl`
- `25_shading_checker.hlsl`
- `30_face_orientation.hlsl`
- `40_vertex_color.hlsl`

Both original HDRI maps, the original vendor license texts, fonts notices and
main license remain bundled. New release changes do not establish the ultimate
origin of these resources. In particular, UV Precision is an additional file
relative to the older provenance table; its ultimate authorship/license remains
unconfirmed here. The owner deferred provenance review on 2026-10-06. No unknown
resource is newly declared MIT, proprietary or cleared for public redistribution.
