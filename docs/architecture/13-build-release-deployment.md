# 13. Build, Release, and Deployment

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

## CI

`.github/workflows/ci.yml` runs on pushes and pull requests to `main` and `develop`. It installs Flutter stable and executes `dart format --output=none --set-exit-if-changed .`, `flutter analyze --no-fatal-infos`, and `flutter test`. After quality checks it builds a debug Android APK artifact and an iOS release build without codesigning. This verifies compilation, not store signing or release delivery.

## Version and environment

`pubspec.yaml` declares `2.8.14+73` for Android and contains a commented iOS example `2.9.11+72`. Confirm current store version and build number before release; Android `versionCode` must increase. Override API URL with `--dart-define=API_BASE_URL=...`; default is production. Record UAT and production build commands in the release ticket/runbook, not in committed secrets.

## Signing and platform builds

Android signing reads `android/key.properties` when present, or environment variables `KEY_ALIAS`, `KEY_PASSWORD`, `KEYSTORE_PATH`, and `STORE_PASSWORD`. Release config falls back to the debug keystore when release credentials are absent; that fallback is unsuitable for store publication and must be caught by release checks. Android enables minification and resource shrinking. iOS requires normal Xcode signing, provisioning, and configured capabilities; CI currently uses `--no-codesign`.

## Shorebird and dependencies

`shorebird.yaml` contains the app ID and automatic updates are enabled by default unless overridden. Use Shorebird releases for a new native binary and patches for Dart-only changes; plugin/native changes require a store binary. Repository scripts include multi-platform patch automation; review its arguments and signing/environment inputs before use.

`pubspec.yaml` overrides `google_maps_flutter_android` to `^2.19.12` and pins `package_info_plus` to `10.1.0`; comments describe Android map lifecycle and release-build compatibility reasons. Revalidate these constraints before changing pins.

## Store checklist

Confirm version/build numbers and API environment; validate signing identity and provider configuration; smoke test OTP, discovery, booking, payment success/failure, cancellation, and notification taps on physical devices; verify crash/logging behavior; produce signed artifacts; publish staged rollout; document Shorebird release/patch relation to the store build. Store credentials and release approvals are managed outside this repository.
