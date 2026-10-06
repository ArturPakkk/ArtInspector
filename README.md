# Art Inspector 0.1.4

A standalone Windows tool for 3D asset inspection and artist self-checks before
assets move further through production. Author: [ArturPakkk](https://github.com/ArturPakkk).

## Current public version

The current public release is **0.1.4**. Download the Windows ZIP from
[Releases](https://github.com/ArturPakkk/ArtInspector/releases).
This repository contains the portable distribution, resources and licensing
information, rather than the complete C++ development project. GitHub's automatic
“Source code” ZIP/tar.gz archives are snapshots of this distribution repository;
historical files under OldVersions are retained in those repository snapshots.

## Features

- FBX import, a Direct3D 11 viewport and Outliner selection/visibility.
- Seven editable HLSL materials for UV0, texel density, shading, face orientation,
  vertex color and UV repetition, including **UV Precision**.
- Collision-mesh display, Lit/Unlit and Wireframe modes.
- HDRI and directional lighting, with a custom **Environment Color** when HDRI is off.
- Editable checker parameters, saved settings and factory reset controls.

The viewport uses matte diagnostic lighting; a complete metallic/roughness PBR
renderer, Bloom and a separate UV editor are not implemented. Collision display
is an inspection aid, not an Unreal/Chaos simulation. Application model import
supports FBX; other importer capabilities do not imply additional app formats.

## Installation

1. Open [Releases](https://github.com/ArturPakkk/ArtInspector/releases).
2. Download the latest Windows ZIP. For 0.1.4, use `ArtInspector-v0.1.4-win64.zip`.
3. Extract the whole **ArtInspector** folder.
4. Run **ArtInspector.exe**. Keep Config, Resources, LICENSE.md,
   THIRD_PARTY_NOTICES.md, licenses and docs beside the executable.

Windows x64 with a Direct3D 11 / Shader Model 5.0 GPU is required. No separate
shader SDK is needed. Clean-machine minimum Windows support has not been certified.
Do not copy Windows system DLLs or fonts into the application folder yourself.

## Preview Scene and saved settings

Open **Settings → Preview Scene**. The floor starts **Off** and can be enabled with
Checker floor. Turn HDRI off to use **Environment Color**, initially neutral gray
**#606060** (RGB 96 / 96 / 96). Click the swatch for the picker or edit RGB values.
The chosen color is retained while HDRI is on and reused when HDRI is turned off.
Face Orientation starts with **Show Faces: Both**.

Use **Save Parameters** to retain Preview Scene or checker changes between runs.
Preview Scene Factory Reset restores and saves scene defaults; the global Factory
Reset also restores checker defaults. Factory settings live in
`Config/DefaultEditor.ini`; saved overrides live in `Config/UserSettings.ini`.

## Updating a previous installation

Back up Config and any edited materials. Extract this release into a new folder
and keep its new DefaultEditor.ini. If an earlier installation saved Custom.*
settings in DefaultEditor.ini, use the new executable before replacing that file:

```bat
ArtInspector.exe --prepare-settings "path to the previous Config folder"
```

This creates or extends UserSettings.ini in the previous Config folder without
changing its factory file. Newer user overrides take precedence. Copy that
UserSettings.ini into the new installation's Config folder, and copy custom
materials separately. The original window-layout identity is retained for compatibility.

## Distribution files

| Path | Purpose |
|---|---|
| ArtInspector.exe | Windows executable for 0.1.4 |
| Config/DefaultEditor.ini | Clean factory settings |
| Resources/Materials/ | Seven editable HLSL materials and their guide |
| Resources/HDRI/ | Two bundled environment maps |
| release-manifest.json | Product and package version metadata |
| licenses/ | Third-party notices and complete license texts |
| docs/licensing/ | Dependency, provenance and legacy release records |

In this repository, OldVersions contains intentionally preserved historical
executables. It is not part of the current Windows release ZIP. Prefer the complete
release ZIP for installation. See the [material guide](Resources/Materials/README.md).

## Licensing

The proprietary contribution is governed by [LICENSE.md](LICENSE.md), effective
September 22, 2026. Personal and commercial use is allowed under those terms;
general redistribution, sale, rebranding and sublicensing rights are not granted.
Public visibility does not make the application unrestricted open-source software.
Other existing grants remain unaffected. [Third-party notices](licenses/THIRD_PARTY_NOTICES.md)
and component licenses apply independently to their code/fonts/assets.

Some logo/icon/shader provenance and historical build-origin questions still
require manual review. See the [dependency audit](docs/licensing/DEPENDENCY_LICENSE_AUDIT.md)
and [provenance status](docs/licensing/ARTINSPECTOR_PROVENANCE.md).
No new rights clearance is asserted for this release.

## Historical releases

The repository was previously named **ArtInspector_v_0.1.2**; its current address is
[ArturPakkk/ArtInspector](https://github.com/ArturPakkk/ArtInspector).
Earlier tags and release assets remain preserved. Older RAR downloads belong to
those historical releases; the current 0.1.4 download is the Windows ZIP.
The v0.1.0 RAR launches TexelDensityInspector.exe, while its tag snapshot contains
Artnspector.exe; these are distinct historical builds. The original v0.1.0 and
0.1.2 assets also have separately published licensing supplements.
[Legacy details and hashes](docs/licensing/LEGACY_RELEASES.md).
The software is provided as-is to the extent permitted by applicable law.
