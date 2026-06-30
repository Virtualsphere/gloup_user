# GloUp User App (tressy)

Flutter client for the GloUp salon booking platform.

## API configuration

Production API is the default (`https://api.v1.gloup.in`). For local or staging backends, pass `API_BASE_URL` at run or build time — do not commit private IPs or dev URLs in source.

```bash
# Debug on a device/emulator (replace with your machine's LAN IP)
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5678

# Release / Shorebird (example)
flutter build apk --release --dart-define=API_BASE_URL=https://api.v1.gloup.in
shorebird release android -- --dart-define=API_BASE_URL=https://api.v1.gloup.in
```

## Getting Started

- [Flutter documentation](https://docs.flutter.dev/)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
