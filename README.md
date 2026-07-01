# GloUp User App (tressy)

Flutter client for the GloUp salon booking platform.

## API configuration

Production API is the default (`https://api.v1.gloup.in`). For local or staging backends, pass `API_BASE_URL` at run or build time — do not commit private IPs or dev URLs in source.

```bash
# Debug on a device/emulator (replace with your machine's LAN IP)
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5678
```

## Shorebird (code push)

**Important:** Play Store / production AABs must be built with `shorebird release`, not `flutter build appbundle` or Fastlane `gradle bundle`. Only Shorebird-built binaries can receive OTA patches. See [Shorebird troubleshooting](https://docs.shorebird.dev/code-push/troubleshooting/#patch-not-showing-up).

### New Play Store release (baseline)

```bash
shorebird release android -- --dart-define=API_BASE_URL=https://api.v1.gloup.in
```

Upload the AAB Shorebird prints:

`build/app/outputs/bundle/release/app-release.aab`

On Windows PowerShell, quote `--` before dart-defines:

```powershell
shorebird release android '--' --dart-define=API_BASE_URL=https://api.v1.gloup.in
```

Fastlane production lane (`android/fastlane/Fastfile`) runs the same Shorebird release, then uploads that AAB.

### OTA patch (Dart-only changes)

```bash
shorebird patch android -- --dart-define=API_BASE_URL=https://api.v1.gloup.in
```

Patches apply only to users on the **exact** release version (e.g. `2.5.1+58`). Kill and reopen the app after patching.

### Verify patches on a device

```bash
adb logcat | findstr shorebird
```

You should see `[shorebird]` logs and a `PatchCheckRequest` with your `release_version`. If there are no `[shorebird]` logs, the installed APK/AAB was not built with `shorebird release`.

### Current console state

- Release `2.5.1+58` exists on Shorebird with patches — **0 active users** usually means the Play Store binary was not the Shorebird release artifact.
- Fix: ship a new store release built via `shorebird release` (bump `version` in `pubspec.yaml` if Play already has that version code), then use `shorebird patch` for hotfixes.

## Getting Started

- [Flutter documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
