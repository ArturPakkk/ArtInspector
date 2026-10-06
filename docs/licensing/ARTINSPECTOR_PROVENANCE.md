# ArtInspector provenance status

Audit date: 2026-09-22. This document records evidence, not an assertion that all
unattributed work belongs to ArtInspector. No private prompts or conversations
are published as provenance evidence.

Ultimate origin/authorship of UI icons and the logo has not been conclusively established. No third-party license is assigned without file-level evidence. MANUAL REVIEW REQUIRED.

| Component | Origin | Author | License | Evidence | Confidence |
| --- | --- | --- | --- | --- | --- |
| Resources/Materials/00_default_materials.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 75e31e2 2026-09-07 Init | PARTIALLY CONFIRMED lineage |
| Resources/Materials/10_Texel_Density - Default.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 1688ce0 2026-09-14 Update legacy ArtInspector UI, materials and viewport controls; 75e31e2 2026-09-07 Init | PARTIALLY CONFIRMED lineage |
| Resources/Materials/10_Texel_Density_Pro.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 1688ce0 2026-09-14 Update legacy ArtInspector UI, materials and viewport controls; efc1608 2026-09-10 Update; 0b97cfa 2026-09-08 Update | PARTIALLY CONFIRMED lineage |
| Resources/Materials/20_uv_checker.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 75e31e2 2026-09-07 Init | PARTIALLY CONFIRMED lineage |
| Resources/Materials/22_z_fighting_checker.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 75e31e2 2026-09-07 Init | PARTIALLY CONFIRMED lineage |
| Resources/Materials/23_uv_repetition_checker_v1.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | ba9ae79 2026-09-10 Update | PARTIALLY CONFIRMED lineage |
| Resources/Materials/25_shading_checker.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 1688ce0 2026-09-14 Update legacy ArtInspector UI, materials and viewport controls; 75e31e2 2026-09-07 Init | PARTIALLY CONFIRMED lineage |
| Resources/Materials/26_solid_wireframe_v1.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 1688ce0 2026-09-14 Update legacy ArtInspector UI, materials and viewport controls | PARTIALLY CONFIRMED lineage |
| Resources/Materials/30_face_orientation.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 1688ce0 2026-09-14 Update legacy ArtInspector UI, materials and viewport controls; 75e31e2 2026-09-07 Init | PARTIALLY CONFIRMED lineage |
| Resources/Materials/40_vertex_color.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 1688ce0 2026-09-14 Update legacy ArtInspector UI, materials and viewport controls; 75e31e2 2026-09-07 Init | PARTIALLY CONFIRMED lineage |
| Resources/Materials/UV Island checker.hlsl | UNKNOWN ultimate origin; project revision history located | Not independently established | MANUAL REVIEW REQUIRED | 1688ce0 2026-09-14 Update legacy ArtInspector UI, materials and viewport controls; efc1608 2026-09-10 Update; 0b97cfa 2026-09-08 Update | PARTIALLY CONFIRMED lineage |
| Legacy RAR v0.1.0: 00_default_materials, 10_texel_density, 10_texel_density_v2, 30_face_orientation, 40_vertex_color | UNKNOWN ultimate origin | Not independently established | MANUAL REVIEW REQUIRED | Original uploaded RAR preserved; names occur in early material history, but later revisions differ | PARTIALLY CONFIRMED lineage |
| UI icons and tokens | Native procedural drawing; comments refer to earlier HTML paths | Unknown ultimate source | MANUAL REVIEW REQUIRED | Current associated native implementation; ultimate source not established | PARTIALLY CONFIRMED implementation, not origin |
| ArtInspector logo | A-shaped local SVG matches native BrandMark geometry | Not independently established | MANUAL REVIEW REQUIRED | SVG uses M4 19 11 4h2l7 15 and two crossbars, matching procedural logo | PARTIALLY CONFIRMED lineage |
| HDRI_01.hdr, HDRI_02.hdr | Poly Haven | Individual contributors not identified | CC0-1.0 | Prior owner confirmation, identical SHA-256 across current and both RARs; official policy | CONFIRMED |
| ProggyClean | Embedded ImGui font | Tristan Grimmer, 2004/2005 | MIT | Vendored font comment and upstream license; font name in all inspected EXEs | CONFIRMED |
| ProggyForever minimal | Embedded ImGui font | Disco Hello 2026; Tristan Grimmer 2019/2023 | MIT | Vendored font comment and upstream license; font name in all inspected EXEs | CONFIRMED |
| System Segoe UI / Consolas | Installed Windows fonts | Respective Microsoft font rights holders | Installed system terms | Font-loading code; no TTF/OTF distributed | CONFIRMED use, not redistribution permission |

Current shader files match the public main snapshot and the associated current
legacy source byte-for-byte. Internal history traces material integration; it
does not prove that the original algorithms or code were independently authored.
Solid Wireframe also has an earlier implementation guide describing its native
barycentric integration. Neither that guide nor the commit author establishes
an upstream copyright license by itself. No supplied external attribution was
found in the checked material comments.

No packaged Adobe/React/Unreal icon library was found in the build. This does
not rule out copied coordinates. Searches in available local SVG/HTML material
found the matching project logo, but no definitive original third-party source.
The exact historical HTML reference has not been recovered.

No third-party license or original ArtInspector authorship is assigned to unknown icons or the logo without file-level evidence.

Resolution: record the exact upstream repository, package, file/version and applicable LICENSE,
NOTICE and modification requirements, or commission/implement a clearly recorded
replacement in a separate authorized task. No rendering, checker or icon changes
were made merely to close this audit.


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
