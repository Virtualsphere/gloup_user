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

You should see `[shorebird]` logs and a `PatchCheckRequest` with `release_version: "2.5.2+59"`. **If there are no `[shorebird]` logs, the installed app was not built with `shorebird release`** — uploading to Play or registering on Shorebird does not fix a non-Shorebird binary.

### Play Store checklist (required)

Per [Shorebird Play Store guide](https://docs.shorebird.dev/code-push/guides/stores/play-store/):

1. Run `shorebird release android` **first**, then upload **only** `build/app/outputs/bundle/release/app-release.aab`.
2. Do **not** run `flutter build appbundle` and upload that AAB — it looks the same but cannot receive patches.
3. In Play Console, confirm the live release shows **version code 59** and **version name 2.5.2** — do not change these in the console after upload.
4. Open the app on a device **after** installing the Play update (release build, not debug). Active users appear only after a check-in on launch.
5. Do not run security/obfuscation tools **after** the Shorebird build ([security tooling docs](https://docs.shorebird.dev/code-push/guides/security-tools/)).

### Isolate Play vs Shorebird (definitive test)

Install the APK Shorebird stored for the release (not from Play):

```bash
shorebird releases get-apks --release-version=2.5.2+59
```

Install the generated APK, open the app, wait ~1 minute, refresh the Shorebird console. If active users appear here but not for the Play build, the Play Store AAB is not the Shorebird artifact.

### Current console state

- Release `2.5.2+59` is registered on Shorebird with patches — **0 active users** means no device running the Shorebird-built binary has checked in yet, almost always because Play has a plain `flutter build` AAB or the update is not installed/opened on the test device.

## Getting Started

- [Flutter documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
