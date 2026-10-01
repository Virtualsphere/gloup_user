# 06. Navigation and Deep Links

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

Routing is configured with `go_router` in `core/router/app_router.dart`; canonical path constants live in `route_names.dart`. The route tree includes splash/onboarding/login/OTP, the home shell (home, explore, favorites, bookings), category, salon details with nested slot booking and review-confirmation, salon search, profile, wallet, reviews, settings, invite, and support/legal screens.

Routes pass screen data through path/query values and `extra` maps or typed entities. Salon detail and booking routes depend on those payloads; keep keys and types synchronized with callers. Review the router when changing any payload. The global `GoRouter.redirect` callback currently returns `null` and enforces no auth guard. Session expiry separately clears tokens and navigates to login. Do not infer authorization from route visibility: protected API operations remain server-authorized.

`NotificationRoutes` maps notification type aliases, explicit route/path keys, and salon/category identifiers to router destinations. Supported aliases include bookings, salon/store, promotion/home, profile, wallet, favorites, explore, category, and invite. Unknown types fall back to home; empty data is ignored.

The app listens to `AppLinks().uriLinkStream` in `main.dart`, but currently logs received URIs only. Native App Links declarations include `www.gloup.in` and `api.v1.gloup.in`; routing of those inbound URLs is not implemented by that listener. Treat this as a documented limitation and test before relying on a link to open a specific screen.
