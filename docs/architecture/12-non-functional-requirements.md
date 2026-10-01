# 12. Non-Functional Requirements

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

## Security and privacy

- Use HTTPS for API calls; production base URL is HTTPS. Do not log access tokens, payment secrets, or sensitive personal data.
- Store access tokens in `FlutterSecureStorage`; public auth endpoints omit the `userauth` header.
- Keep signing credentials and provider secrets out of source control and client-visible configuration where server-side credentials are required.
- Android release builds enable R8/resource shrinking and reference ProGuard rules. Audit provider SDK configuration and platform permissions as part of release review.

## Resilience and performance

Network calls can take up to 60 seconds before Dio timeout. Connectivity checks and repository guards exist, but there is no general offline cache. Loading, empty, and error states should remain explicit. Images use cached network widgets and dimension helpers. Product targets for cold start, screen load, and image transfer have not been set in this repository; establish measurable budgets before treating performance as verified.

## Platform and accessibility

iOS deployment target is 15.0 in `ios/Podfile`. Android uses Flutter's minimum SDK setting and currently targets SDK 36; verify the resolved minimum against generated Flutter configuration during release. Accessibility and localization policy are not specified in the repository. New screens should support scalable text, semantic labels, contrast, and keyboard/screen-reader operation; localization requires a product decision.

The application is built for Android and iOS. Presence of Windows, web, or macOS scaffolding does not imply production support.
