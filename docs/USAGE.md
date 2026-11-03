# Art Inspector guide

## Preview Scene and saved settings

Open **Settings → Preview Scene**. Checker floor and HDRI start **Off**.
Without HDRI, **Environment Color** defaults to normalized RGB **0.075, 0.075, 0.075**
(approximately #131313). Click the swatch or edit RGB values. The color is retained
while HDRI is on and reused when HDRI is turned off.

Face Orientation starts with **Show Faces: Both**: front faces are blue and back
faces red, including mirrored object transforms and reflected FBX conversions.

Use **Save Parameters** to keep Preview Scene or checker changes between runs.
Preview Scene Factory Reset restores and saves scene defaults; global Factory Reset
also restores checker defaults. Factory settings live in `Config/DefaultEditor.ini`;
saved overrides live in `Config/UserSettings.ini`.

## Updating a previous installation

Back up Config and edited materials. Extract the new release into a separate folder
and keep its new DefaultEditor.ini. If an older installation stored Custom.* settings
in DefaultEditor.ini, run the new executable before replacing the old factory file:

```bat
ArtInspector.exe --prepare-settings "path to the previous Config folder"
```

This creates or extends UserSettings.ini in the previous Config folder without
changing its factory file. Existing user overrides take precedence. Copy that
UserSettings.ini into the new installation's Config folder; copy custom materials separately.

## Z-Fighting Checker V1

Import FBX, select **Z-Fighting Checker** in either material picker and choose
**Run analysis**. Coincident is the default. Proximity uses a millimeter gap tolerance
(default 1 mm) and reports candidates for review. **Cancel** stops analysis;
conflict rows locate meshes. Parameters are session-only.

Red marks whole affected triangles; gray means checked. Blue is unverified, amber
uncertain and magenta invalid. Read status and scope before treating an empty list
as a completed result. All non-collision imported meshes, including hidden meshes,
are analyzed; preview helpers are excluded. Camera-dependent depth-buffer cases are outside V1.

Shading preference and ordinary material values are retained. Diagnostics use solid
colors; Collision remains independent. Scroll the Inspector at high DPI.
Keep `Resources/Diagnostics` beside the executable.

## Scope and package

The viewer imports **FBX** and uses diagnostic lighting. A complete metallic/roughness
PBR renderer, Bloom and a separate UV editor are not implemented. Collision display
is an inspection aid, not an Unreal/Chaos simulation. Minimum Windows support on a
clean machine has not been certified; Windows x64 and a Direct3D 11 / Shader Model 5.0 GPU are required.

Keep Config, Resources, licenses, docs and license documents beside ArtInspector.exe.
The repository contains the portable distribution. GitHub's automatic “Source code”
archives are repository snapshots; use the Windows ZIP from Releases to install.
OldVersions contains historical executables and is excluded from the current release ZIP.

[Checker materials](../Resources/Materials/README.md) ·
[Blender Bridge installation](../Blender/README.md) ·
[License](../LICENSE.md) ·
[Dependency audit](licensing/DEPENDENCY_LICENSE_AUDIT.md) ·
[Provenance](licensing/ARTINSPECTOR_PROVENANCE.md) ·
[Historical releases](licensing/LEGACY_RELEASES.md)
