# Historical releases and licensing supplements

Audit date: 2026-09-22. Original commits and tags are preserved.
The formal LICENSE.md was added at ae9573b, after the v0.1.0 and 0.1.2 releases.
Updated terms have an explicit 2026-09-22 effective date and preserve prior
applicable grants; no claim is made that the file existed in earlier snapshots.

## Published legacy release state

| Legacy release | Tag commit | Original asset | Original licensing bundle | Published licensing supplement |
| --- | --- | --- | --- | --- |
| v0.1.0 | f74f515d19cc4dfd07e2e97241e7be837f220d21 | ArtInspector-0.1.0-win64.rar | Absent | ArtInspector-v0.1.0-win64-licensing-20260922.rar |
| 0.1.2 | 1688ce0dcabc563208faec3e676ff4aeb7e8cd3d | ArtInspector_v0.1.2.rar | Absent | ArtInspector-v0.1.2-win64-licensing-20260922.rar |

Both legacy GitHub Release descriptions now include the prepared licensing notice,
and both supplementary licensing archives are published alongside the preserved
original RAR assets. The historical tags and original archives were not replaced.

The extra Checker tag remains at
75e31e2434e351c965fd87ab4ff1bf42b96554a4; there is no GitHub Release object
for it.

ArtInspector 0.1.3 was published as a separate release, not a legacy licensing repack.
Its tag points to public distribution commit
188da32b4053c5a58693bba3e7fecd006b0c1020.

## Original uploaded executable hashes

| RAR | Executable | SHA-256 |
| --- | --- | --- |
| v0.1.0 | TexelDensityInspector.exe | f68bd6fc8e8cbb69343440042889756064f9532913edb0ead4e5fde89cdcec9e |
| 0.1.2 | ArtInspector/ArtInspector.exe | 3151308befcc68bdc623b22f2458ed4ca719a911a4641c8d94e43ff3a5c04e32 |

Original RAR hashes match GitHub's asset digests:

- v0.1.0: b837bb77eedbb46866f1e4603a8ee4f33afa334f3553e498a39aaf01b30b931a
- 0.1.2: db83a9d0b2e0bc27b1056c1d3f02fdde1452195c1a33c9ac9c4b0b40a681dc03

Published supplementary RAR hashes:

- v0.1.0 licensing supplement:
  2610de45bcdab8af9b31e3cf55eb649b8827e01b85eaf01024739a988868e8e9
- 0.1.2 licensing supplement:
  28ec15e25283d295ee9d38bd4a59bea335836ca65f0bed786e4b7a03b9114575

## Important v0.1.0 mismatch

The auto-generated Git-tag ZIP/tar.gz contains Artnspector.exe with SHA-256
97510d9cbfa168996814195766ce24dc01dac6132020b45863a7c7931b2909c4 and ten HLSL
files. The manually uploaded RAR contains TexelDensityInspector.exe and five
HLSL files. They are distinct builds. Their resources must remain paired with
their own executable. The 0.1.2 tag EXE does match the original 0.1.2 RAR EXE.

Both automatic Source code ZIP and tar.gz were downloaded during the audit; their
file lists agreed for each legacy tag and neither contained the later licensing
bundle. These are snapshots of a distribution repo, not the application's full
C++ source. Their historical tags were intentionally left unchanged.

## Published supplement policy

The published licensing-20260922 RAR assets were created from the original
RAR payloads. Every original file was preserved byte-for-byte, including the
executable name, resources, configuration and historical material README.

The supplements add LICENSE.md, THIRD_PARTY_NOTICES.md, licenses/, public audit
notes and REPACK_NOTICE.md. They do not rebuild old EXEs or silently replace
original assets.

Verification after re-extraction reported zero modified, removed or renamed
original files in both supplements. The supplementary archives retain unresolved
historical dependency-version and asset-provenance caveats; adding documentation
does not certify legal clearance.

For v0.1.0, the original executable filename remains TexelDensityInspector.exe.
The newer 0.1.2 materials were not used to fill the older RAR's resource set.
