# 10. Local Storage and Caching

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

`LocalStorageService` initializes `SharedPreferences`, migrates the legacy `access_token` value if present, and loads the secure token into an in-memory cache for synchronous interceptor reads.

| Storage | Current use |
|---|---|
| `FlutterSecureStorage` | Access token (Keychain / encrypted platform storage) |
| `SharedPreferences` | Onboarding completion, logged-in flag, location city/area, theme selection, FCM token, generic UX state, dismissed pending-review appointment IDs |
| Image cache | `cached_network_image`, `HdCachedNetworkImage`, and image sizing helpers |

The preference-backed logged-in flag is a UX/session hint; the access token and server response determine authenticated API access. Token migration removes the legacy preference after transfer. Session expiry clears tokens and logged-in state. Explicit logout/profile deletion currently call `clearAll()`, which clears all preferences and the secure token; ensure any desired onboarding or user-independent state is intentionally restored afterward.

No general persistent API cache or offline database is documented in the current implementation. Image caching is a rendering optimization, not an offline guarantee. When adding persisted data, define sensitivity, lifetime, logout behavior, migration, and failure handling alongside the feature.
