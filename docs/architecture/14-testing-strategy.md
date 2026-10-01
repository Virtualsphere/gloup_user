# 14. Testing Strategy

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

The repository contains Flutter tests under `test/` for authentication pages/BLoC, booking order state and price calculation, profile state, home, cancellation dialog, cancellation policy, notification routing and service behavior, API auth routes, connectivity, token migration, and fixtures/widget helpers. `bloc_test` and `mocktail` are available. CI runs `flutter test` after formatting and static analysis.

For changes, prioritize tests at the boundary where behavior can regress:

- Domain calculations and validation: deterministic unit tests, including malformed and boundary values.
- BLoCs: success, loading, failure, duplicate events, and lifecycle-sensitive behavior.
- Repositories/data sources: model mapping and API error propagation.
- Navigation/notification contracts: route aliases, missing identifiers, auth redirects, and payload parsing.
- Booking and payment: order creation, gateway success/failure/dismissal, server verification, cancellation, and repeat-submit behavior.

Release confidence requires end-to-end smoke coverage of OTP, discovery, salon detail, slot selection, checkout, booking status, and push notification taps on physical Android and iOS devices. Current CI does not sign or publish store artifacts, and repository tests do not replace provider/backend integration testing.
