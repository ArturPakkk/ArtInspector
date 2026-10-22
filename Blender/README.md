# Art Inspector — Blender Bridge 1.2.0

## Установка

1. Распакуйте Art Inspector 0.1.5 целиком и запустите `ArtInspector.exe`.
2. В Blender 4.5+ (Windows x64): **Edit → Preferences → Get Extensions → меню → Install from Disk**.
3. Выберите лежащий рядом `ArtInspector_Blender_Bridge.zip` и включите расширение **Art Inspector — Blender Bridge**.
4. В настройках расширения укажите **Art Inspector Executable** — `ArtInspector.exe` из этой поставки. Явный путь особенно удобен для переносимой папки; сохранённый путь предыдущей установки автоматически не меняется.
5. В Object Mode выделите Mesh-объекты и нажмите **N → Art Inspector → Export**.

**New window every time** создаёт новое окно при каждом экспорте (по умолчанию).
**Update matching window** обновляет окно того же `.blend` независимо от текущего набора Mesh, сохраняя камеру и настройки инспектора. Если окна ещё нет, оно создаётся.
При Export окно Art Inspector поднимается на передний план. Сначала отображается этап экспорта из Blender, затем загрузки модели. Для этого используйте обновлённый Art Inspector 0.1.5 из этой поставки.
Camera/Light/Empty пропускаются. Для Geometry Nodes с instances сначала используйте Realize Instances. Если Auto-Save Preferences отключён, нажмите Save Preferences.

## Installation

Extract the complete Art Inspector folder. In Blender 4.5+ on Windows x64, use **Edit → Preferences → Get Extensions → menu → Install from Disk**, choose `ArtInspector_Blender_Bridge.zip` and enable **Art Inspector — Blender Bridge**.
Set **Art Inspector Executable** to this release's `ArtInspector.exe`. Select Mesh objects in Object Mode and use **N → Art Inspector → Export**.
**New window every time** opens an independent viewer. **Update matching window** replaces the content of the viewer associated with the current `.blend`, preserving view and checker settings.

The extension code is GPL-3.0-or-later; its license is inside the extension ZIP. It has separate licensing from the native application.
Bridge 1.2.0 opens or activates the viewer at the start of Export and shows export/import stages in the updated Art Inspector 0.1.5.
