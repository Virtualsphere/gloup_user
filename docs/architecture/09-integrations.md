# 09. Integrations

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

| Integration | Package / implementation | Purpose and configuration notes |
|---|---|---|
| GloUp API | Dio | Backend contract; base URL via `API_BASE_URL`, production default in `ApiRoutes` |
| Image storage | Google Cloud Storage URLs | Salon, banner, profile, and category media; URL resolution helpers |
| Firebase | `firebase_core`, `firebase_messaging` | App initialization, FCM registration, foreground/background message handling; options in `firebase_options.dart` |
| Local notifications | `flutter_local_notifications` | Android foreground and data-only display, tap payloads; channel `gloup_default_channel` |
| Razorpay | `razorpay_flutter` | Checkout after API order creation; key constant in `ApiRoutes`; keep key configuration reviewed by release/security owners |
| Maps and place | `google_maps_flutter`, `google_places_flutter`, `geolocator`, `geocoding` | Maps, place lookup, coordinates, address; platform API key setup and restrictions are native configuration concerns |
| Google sign-in | `google_sign_in` | Federated authentication; client IDs and platform setup must match Firebase/provider consoles |
| Apple sign-in | `sign_in_with_apple` | iOS federated authentication; Apple entitlement/capability required |
| Facebook App Events | `facebook_app_events` | Analytics events; verify app ID/config and event policy in native setup |
| Update checks | `upgrader`, `in_app_update` | Cross-platform update prompt plus Android immediate update support; checked at startup/resume |
| App Links | `app_links` | URI stream currently logs received URI; no in-app destination mapping in `main.dart` |
| Shorebird | Shorebird project config and scripts | Dart code push; native/plugin changes still require store builds |

All credentials, signing material, and environment secrets must be supplied through protected build configuration and restricted provider consoles. Firebase platform config files are present in the repository; review their sensitivity and distribution policy separately. Integration failures should degrade safely: image failures use placeholders, notification image download falls back to text, and transaction state is confirmed with the backend.
