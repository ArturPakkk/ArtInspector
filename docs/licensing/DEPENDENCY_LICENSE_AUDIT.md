# ArtInspector distribution dependency audit

2026-09-22. Scope: public main at ae9573b603adb6ba81f7ddac3c46d848c2a32806,
its OldVersions binaries, manually uploaded v0.1.0 / 0.1.2 RARs, and the associated
current optimized native build. No private source files are included in this repo.

## Evidence and requirements

License paths below are relative to ../../licenses/. The actual text files were
compared against vendored licenses or official upstream font/SDK texts. The main
ArtInspector terms never replace these component terms.

| Component / version | Holder | Source and use | Ships? | License and action | Status |
| --- | --- | --- | --- | --- | --- |
| Dear ImGui 1.92.9 + Win32/DX11 backends | Omar Cornut 2014–2026 | ocornut/imgui; compiled UI, identified in all inspected binaries | Embedded | MIT; native/Dear-ImGui-MIT.txt | CONFIRMED |
| ufbx 0.23.0 in current source; historic exact version unverified | Samuli Raivio 2020 | ufbx/ufbx; model importer; diagnostic strings in all inspected binaries | Embedded | MIT alternative; native/ufbx-LICENSE.txt | Current text confirmed; legacy version MANUAL REVIEW REQUIRED |
| ImGui-modified stb_truetype 1.26 | Sean Barrett 2017 | nothings/stb via ImGui; font rasterization | Embedded | MIT alternative; native/imstb_truetype-LICENSE.txt | Current confirmed; historic linkage inferred from same ImGui version |
| ImGui-modified stb_rect_pack 1.01 | Sean Barrett 2017 | nothings/stb via ImGui; atlas packing | Embedded | MIT alternative; native/imstb_rectpack-LICENSE.txt | Same limitation |
| ImGui-modified stb_textedit 1.14 | Sean Barrett 2017 | nothings/stb via ImGui; text editing | Embedded | MIT alternative; native/imstb_textedit-LICENSE.txt | Same limitation |
| stb_decompress, unversioned embedded code | Sean Barrett | ImGui source labels public domain | Embedded | Source attribution retained; no extra notice obligation identified | Current confirmed |
| DirectXMath / DirectXCollision, current SDK macro 317 | Microsoft Corporation | SDK inline math; official microsoft/DirectXMath MIT text | Embedded in current EXE | native/DirectXMath-MIT.txt | Current confirmed; historic SDK exact version MANUAL REVIEW REQUIRED |
| ProggyClean | Tristan Grimmer 2004,2005 | Embedded ImGui font / bluescan/proggyfonts | Embedded, all inspected EXEs | MIT; fonts/ProggyClean-MIT.txt | CONFIRMED identification/text |
| ProggyForever minimal | Disco Hello 2026; Tristan Grimmer 2019,2023 | Embedded ImGui font / ocornut/proggyforever | Embedded, all inspected EXEs | MIT; fonts/ProggyForever-MIT.txt | CONFIRMED identification/text |
| HDRI_01 / HDRI_02 | Poly Haven contributors, individual names unknown | Environment resources; identified hashes | Files in all packages | CC0; assets/PolyHaven.txt and CC0-1.0.txt | CONFIRMED |
| Microsoft CRT / C++ runtime | Microsoft | Current MSVC static linkage; original toolchain records unavailable | Embedded | Applicable Visual Studio redistribution agreement | MANUAL REVIEW REQUIRED |
| Windows DLLs and installed Segoe UI/Consolas | Microsoft/respective rights holders | OS services/fonts, not bundled copies | No files copied | Installed OS/font terms, do not repackage arbitrarily | CONFIRMED layout |
| Shader/UI icon/logo assets | Ultimate origin unknown | Shaders as files; UI artwork in EXE | Yes | See provenance document; no invented license | MANUAL REVIEW REQUIRED |

For each MIT row, retain the named copyright and the full permission/warranty
text. Required LICENSE copy: yes. Separate NOTICE requirement: none found in
those actual texts. Source disclosure: no. Modification disclosure: no under
the selected MIT terms; upstream modification annotations remain intact.
CC0 imposes no mandatory attribution/source/NOTICE requirement identified here;
the asset records are supplied voluntarily. Unknown assets have UNKNOWN
obligations, not zero obligations. Unknown binary build records cannot be
certified solely by copying a plausible license bundle.

## Per-artifact limits

Both original RAR executables and both OldVersions EXEs identify Dear ImGui 1.92.9,
ProggyClean and ProggyForever, and contain ufbx strings. The earliest available
associated source snapshot already uses ufbx 0.23.0 but postdates v0.1.0; do not
misrepresent it as a complete source-to-binary attestation for that release.
The original v0.1.0 RAR ships five HLSL files, its tag snapshot ships ten, and
0.1.2 ships eleven. Their original binaries/resources must not be interchanged.
Current eleven-material notices must be qualified when supplied with v0.1.0.
OldVersions EXEs lack their own complete resource sets; do not advertise them
as complete packages or infer version numbers solely from filenames.

All inspected EXEs import d3d11.dll, D3DCOMPILER_47.dll, COMDLG32.dll, SHELL32.dll,
ole32.dll, dwmapi.dll, USER32.dll, KERNEL32.dll, IMM32.dll and GDI32.dll. No private
DLL or dynamic VCRUNTIME/MSVCP dependency appeared. This is not exhaustive static
binary provenance or a vulnerability assessment.

React, Electron, Diligent, npm, Rust crates and Python are not current runtime
build inputs. Naming native widgets Spectrum does not establish distribution
of a React Spectrum package or settle the ownership of embedded coordinates.

## Notice matrix

| Component | Repository texts | Current package | Legacy repack candidate | Result |
| --- | --- | --- | --- | --- |
| ImGui, ufbx, stb trio | native/ full texts | Included | Included with historical version caveat | PASS text coverage; legacy build record review remains |
| DirectXMath | native/DirectXMath-MIT.txt | Included | Included conservatively; exact SDK unverified | MANUAL REVIEW REQUIRED for historic attestation |
| Proggy fonts | fonts/ full texts | Included | Included | PASS |
| HDRI | assets/ source record and CC0 | Included | Included, original hashes verified | PASS |
| ArtInspector | Root LICENSE.md | Included | Included with effective-date/previous-rights clauses | PASS presence; custom legal review remains |
| Unresolved artwork/shaders/runtime entitlement | Explicit review notes | Included | Included | MANUAL REVIEW REQUIRED |

License-copy checks do not authorize publication while unresolved rights remain.


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
