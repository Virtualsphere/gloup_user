# 07. Networking and Authentication

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

## HTTP client and session

`DioClient` configures JSON responses, `Content-Type: application/json; charset=UTF-8`, and 60-second send/receive timeouts. It adds `AuthInterceptor` and `LoggerInterceptor`. API base URL is `String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.v1.gloup.in')`; image URLs use `https://storage.googleapis.com/gloup-images`.

For non-public auth paths, `AuthInterceptor` adds the token as the `userauth` header when present. OTP send/verify and Google/Apple login are public. A 401 from a route that requires auth stops presence heartbeat, clears secure tokens and logged-in state, and invokes the root callback to navigate to login. The legacy SharedPreferences token is migrated to secure storage at startup. Optional-auth endpoints should be identified explicitly in backend contract review; current client logic treats every non-public auth path as requiring a session on 401.

Transport and status errors map to typed `ApiException` subclasses in `DioClient`. Connectivity is exposed by `NetworkInfo`; repositories may use `repository_network_guard.dart` to short-circuit offline requests. Retries are not globally configured; transactional retry policy must be designed per operation to avoid duplicate orders.

## Endpoint inventory

Paths are relative to `API_BASE_URL` unless noted. This inventory follows `ApiRoutes`; verify HTTP verbs and payloads in the data sources/backend spec.

| Area | Client endpoint paths |
|---|---|
| Auth | `/user/auth/sendOTP`, `/user/auth/verifyOTP`, `/user/auth/deviceId`, `/user/auth/googlelogin`, `/user/auth/appleLogin`, `/user/auth/logout` |
| Presence | `/user/app/v2/heartbeat` |
| Discovery | `/user/app/v2/getbanner`, `/user/app/v2/getallcategory`, `/user/app/v2/store/nearby`, `/user/app/v2/get-all-stores`, `/user/app/v2/salons/top`, `/user/app/v2/services/top-categories`, `/user/app/v2/stores/by-category` |
| Salon and maps | `/user/app/v2/store/details`, `/user/app/v2/salons/map-markers-clustered` |
| Favorites | `/user/app/v2/favourites` |
| Availability and guests | `/user/app/v2/getslotstatus`, `/user/app/v2/store/holidays`, `/user/app/v2/guest/all`, `/user/app/v2/guest/add`, `/user/app/v2/guest/update` |
| Orders and appointments | `/user/app/v2/createorder`, `/user/app/v2/paymentsuccess`, `/user/app/v2/cancel-pending-order`, `/user/app/getallapointments` |
| Profile and offers | `/user/app/v2/profile`, `/user/app/v2/get/activecoupons` |
| Reviews | `/user/app/addreview`, `/user/app/v2/pending-reviews`, `/user/app/v2/reviews` |

Google Places endpoints are also declared for nearby search, autocomplete, and place details. See [integrations](09-integrations.md). Never put credentials or production secrets into architecture docs.
