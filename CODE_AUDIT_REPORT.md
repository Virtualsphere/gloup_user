# GloUp User App — Industrial Code Audit Report

**Project:** `gloup_user` (Flutter / BLoC / Clean Architecture)  
**Audit date:** 2026-06-30  
**Methods:** `flutter analyze`, graphify knowledge graph, manual review of core paths, CI config, dependency & security review

---

## Executive summary

| Area | Grade | Notes |
|------|-------|-------|
| Architecture | **B-** | Clean Architecture + BLoC in place; god-widgets and duplicate bloc scope undermine it |
| Security | **C** | Auth tokens in `SharedPreferences`; no env/flavor separation |
| Testing | **F** | **Zero** `*_test.dart` files |
| CI/CD | **D** | Build runs; analyze, format, and tests are **commented out** |
| Maintainability | **C+** | `salon_details_page.dart` ~2,300 lines; 202 graph communities, many low-cohesion |
| Static analysis | **B+** | 10 analyzer issues (2 warnings, 8 info) |

**Overall:** Solid feature-delivery app with good structural intent, but **not yet at industrial production standard** until security, testing, CI gates, and large-file refactors are addressed.

---

## Critical findings (fix before next production release)

### 1. No automated tests

- **Finding:** 0 test files in the repo.
- **Risk:** Regressions in booking, payment (Razorpay), auth, and FCM go undetected.
- **Standard:** Unit tests for blocs/repos; widget tests for critical flows; integration test for login → book → pay.

### 2. CI quality gates disabled

In `.github/workflows/ci.yml`, the following steps are commented out:

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`

**Risk:** Broken code can merge and ship if the APK build alone passes.

### 3. Auth token stored in plain SharedPreferences

**File:** `lib/core/utils/local_storage_service.dart`

- `access_token` is read/written via `SharedPreferences`.
- **Risk:** Token readable on rooted/jailbroken devices and some backup surfaces.
- **Standard:** `flutter_secure_storage` (Android Keystore / iOS Keychain) for `access_token`.

### 4. Broken network connectivity check

**File:** `lib/core/network/network_info_impl.dart`

- `connectivity_plus` 7.x returns `List<ConnectivityResult>`, not a single enum — analyzer flags `unrelated_type_equality_checks`.
- `NetworkInfo` is registered in DI but **never used** in repositories — offline checks are inconsistent or missing.

### 5. Cancellation policy inconsistency (legal / UX)

| Location | Policy stated |
|----------|----------------|
| `lib/features/profile/presentation/pages/support_screens/cancellation.dart` | **2 hours** |
| `lib/features/widgets/custom_dialogues.dart` | **8 hours** |

**Risk:** User confusion, support disputes, store policy issues.

### 6. Hardcoded API environment

**File:** `lib/core/constants/api_routes.dart`

- Production URL is a compile-time constant; dev URLs have been committed locally in the past.
- **Standard:** `--dart-define=API_BASE_URL=...` or flavors (`dev` / `staging` / `prod`).

---

## High-priority findings

### 7. God widget — `salon_details_page.dart` (~2,300 lines)

- Dense UI hub with tabs, reviews, services, gallery, and booking in one file.
- **Risk:** Untestable UI, merge conflicts, slow onboarding.
- **Fix:** Split into section widgets and a smaller coordinator page.

### 8. Duplicate / fragmented BLoC scope

- `ProfileBloc` is global in `main.dart`, but `review_confirm_page.dart` still creates a local `BlocProvider<ProfileBloc>`.
- `HomeBloc` is created inside `HomePage.build()` via `BlocProvider` — new instance on some rebuild/navigation patterns.
- **Risk:** Stale profile state, duplicate API calls, inconsistent UI.

### 9. FCM / notification handling incomplete

**File:** `lib/core/services/firebase_notification_service.dart`

- TODOs remain for notification tap and `onMessageOpenedApp` deep-link navigation.
- Duplicate-notification fix is in place; tap → route mapping is not.

### 10. Per-request auth headers instead of central interceptor

- Many datasources manually pass `{'userauth': token}`.
- **Risk:** Missed auth on new endpoints, inconsistent 401 handling.
- **Standard:** `AuthInterceptor` on `DioClient` that injects token and triggers logout on 401.

### 11. Incomplete features shipped with TODOs

- Share salon, add service, all-reviews navigation — user-visible gaps unless UI is hidden.

---

## Medium-priority findings

### 12. `flutter analyze` — 10 issues

| Severity | Issue | File |
|----------|-------|------|
| info | `ConnectivityResult` vs `List` | `network_info_impl.dart` |
| info | Unnecessary `provider` import | `category_page.dart`, `explore_page.dart` |
| info | Deprecated `Share.share` | `invite_and_earn.dart` |
| info | Missing curly braces | `my_profile.dart` |
| warning | Unused `_scrollToSection` | `salon_details_page.dart` |
| warning | Unused import | `section_header.dart` |

### 13. Mixed state management

- `flutter_bloc` + `provider` (`LocationProvider`, `ThemeProvider`) — acceptable, but some `provider` imports are redundant where `flutter_bloc` re-exports them.

### 14. Debug logging in production paths

- `debugPrint` / `AppLogger` in home, search, auth — ensure sensitive logs stay `kDebugMode`-gated (`LoggerInterceptor` already is).

### 15. Package / branding drift

- Pub package name `tressy`, app branding GloUp, Android paths mix `com.gloup` / `com.tressy` — confusing for onboarding.

### 16. Graph health (graphify, 2026-06-30)

- **4,210 nodes**, **6,473 edges**, **202 communities**
- **God nodes:** `ProfileBloc` (40 edges), `AuthBloc` (30), `GuestBloc`, `SearchBloc`, `FavoritesBloc`
- **239 dangling-endpoint edges** — tight coupling to constants (`AppColors`, `AppSizes`, `ApiRoutes`)
- **2,745 weakly-connected nodes** — platform/generated code and asset clusters
- Interactive graph: `graphify-out/graph.html`

---

## What is working well

- Clean Architecture layers (data / domain / presentation) across features
- `Either<Failure, T>` in repositories
- Dio error mapping in `DioClient`
- Sensitive field redaction in `LoggerInterceptor`
- Shorebird OTA setup (`shorebird.yaml`)
- Global `ProfileBloc`, home profile avatar, FCM deduplication fix
- Static legal/support pages (privacy, terms, FAQ, cancellation, contact)

---

## Phase-wise fix prompts

Copy each prompt into Cursor as a separate task. Execute **in order**.

---

### Phase 1 — Release blockers (1–2 weeks)

#### Prompt 1A — Secure token storage

```
Audit lib/core/utils/local_storage_service.dart and all call sites that read/write access_token.

1. Add flutter_secure_storage for the access token (and any refresh token if present).
2. Keep SharedPreferences only for non-sensitive flags (onboarding_completed, is_logged_in).
3. Migrate existing users: on first launch after update, read old token from SharedPreferences, write to secure storage, delete from SharedPreferences.
4. Add a small unit test for the migration logic.

Do not change unrelated features. List every file changed.
```

#### Prompt 1B — Fix connectivity + use it in repositories

```
Fix lib/core/network/network_info_impl.dart for connectivity_plus 7.x (List<ConnectivityResult>).

Then wire NetworkInfo into ALL repository implementations:
- Before remote calls, if !isConnected return Left(NetworkFailure(...))
- Remove duplicate ad-hoc connectivity checks if any exist

Run flutter analyze and confirm the unrelated_type_equality_checks info is gone.
```

#### Prompt 1C — Align cancellation policy

```
Search the entire codebase for "8 hour", "8-hour", "8 hours" and any cancellation time constants.

Align ALL user-facing cancellation copy with the 2-hour policy in:
- lib/features/profile/presentation/pages/support_screens/cancellation.dart
- lib/features/widgets/custom_dialogues.dart
- any booking cancellation API error messages shown in UI

Use a single constant e.g. CancellationPolicy.hoursBeforeAppointment = 2 in lib/core/constants/ and reference it everywhere.
```

#### Prompt 1D — Enable CI quality gates

```
Update .github/workflows/ci.yml:
1. Uncomment dart format --set-exit-if-changed .
2. Uncomment flutter analyze (must pass with 0 warnings — fix any warnings first)
3. Uncomment flutter test (will need at least one passing test — add a smoke test if needed)

Ensure code-quality job fails the pipeline on analyze/format/test failure.
```

#### Prompt 1E — Environment-based API URL

```
Replace hardcoded baseUrl in lib/core/constants/api_routes.dart with:

const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.v1.gloup.in',
);

Document in README how to run:
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5678

Ensure no local dev IP is committed. Add a sample env note in README if helpful.
```

---

### Phase 2 — Architecture & reliability (2–3 weeks)

#### Prompt 2A — Central Dio auth interceptor

```
Create an AuthInterceptor in lib/core/network/ that:
1. Injects header 'userauth' from secure token storage on every request (except public auth endpoints: sendOTP, verifyOTP, googlelogin, appleLogin)
2. On 401 response: clear tokens, emit a global logout event or call a registered callback

Remove duplicate manual userauth header passing from all datasources. Use DioClient's interceptor chain only.

Verify login, home API, booking, and profile still work.
```

#### Prompt 2B — Unify ProfileBloc scope

```
ProfileBloc is global in main.dart but review_confirm_page.dart still creates a local BlocProvider.

Refactor so review_confirm_page uses context.read<ProfileBloc>() from the global provider.
Same pattern for any other screen still creating local ProfileBloc instances.

Ensure profile data is not re-fetched unnecessarily on every navigation to review_confirm_page.
```

#### Prompt 2C — Stabilize HomeBloc lifecycle

```
HomePage currently creates HomeBloc inside BlocProvider in build().

Move HomeBloc to either:
- global MultiBlocProvider in main.dart (like FavoritesBloc), OR
- shell route provider in app_router.dart for the main tab scaffold

HomeBloc should survive tab switches and not re-fetch all home data on every rebuild.
Preserve existing LoadAllHomeDataEvent behavior on first load and pull-to-refresh only.
```

#### Prompt 2D — FCM deep links

```
Complete TODOs in lib/core/services/firebase_notification_service.dart:

1. onDidReceiveNotificationResponse (local notification tap)
2. FirebaseMessaging.onMessageOpenedApp
3. getInitialMessage() on cold start

Map message.data keys to go_router routes (booking detail, promotions, profile, etc.).
Add a small routing table in lib/core/router/notification_routes.dart.

Test: foreground, background, and killed app tap flows.
```

#### Prompt 2E — Split salon_details_page.dart

```
Refactor lib/features/salon_details/presentation/pages/salon_details_page.dart (~2300 lines):

Extract into:
- widgets/salon_header_section.dart
- widgets/salon_services_section.dart
- widgets/salon_reviews_section.dart
- widgets/salon_team_section.dart
- widgets/salon_gallery_section.dart
- controllers or cubit for tab index and scroll state

Target: main page file under 400 lines. No behavior change. Run flutter analyze after.
```

---

### Phase 3 — Code quality & test foundation (2–4 weeks)

#### Prompt 3A — Fix all analyzer issues + format

```
Run flutter analyze and dart format on the project.

Fix all 10 current issues including:
- network_info_impl.dart connectivity fix (if not done in Phase 1)
- deprecated Share → SharePlus in invite_and_earn.dart
- curly braces in my_profile.dart
- remove unused _scrollToSection and unused imports

Goal: flutter analyze with 0 issues.
```

#### Prompt 3B — Bloc unit test suite (critical paths)

```
Add test/ folder with flutter_test and bloc_test.

Priority bloc tests:
1. AuthBloc — send OTP, verify OTP success/failure
2. OrderBloc — create order, payment verify, error states
3. ProfileBloc — load profile, logout
4. FirebaseNotificationService.handleRemoteMessage — no duplicate local notification when message.notification != null in background

Mock DioClient or repositories with mocktail. Target 80%+ coverage on bloc layer for auth, order, profile.
```

#### Prompt 3C — Widget smoke tests

```
Add widget tests for:
1. LoginPage — phone field validation
2. HomePage — shows shimmer when loading (mock HomeBloc)
3. Cancellation dialog — shows 2-hour policy text

Use pumpWidget with MaterialApp + required BlocProviders.
```

#### Prompt 3D — Complete TODO features or remove dead UI

```
Audit all TODO comments in lib/:

- salon_details share button
- service_card add service
- all reviews navigation
- FCM navigation (if not done in 2D)

Either implement minimal MVP for each OR hide/disable the UI control until implemented. No clickable buttons that do nothing.
```

---

### Phase 4 — Industrial maturity (ongoing)

#### Prompt 4A — Build flavors

```
Add Flutter flavors: development, staging, production.

Each flavor gets:
- API_BASE_URL dart-define
- App name suffix (GloUp Dev / GloUp)
- applicationId suffix for Android (.dev, .staging)

Update Shorebird release docs accordingly.
```

#### Prompt 4B — Observability

```
Integrate Firebase Crashlytics (or Sentry) for:
- Uncaught Flutter errors
- Dio 5xx and payment verification failures
- FCM registration failures

Add breadcrumbs for navigation (go_router) and key user actions (book, pay, cancel).

No PII in crash logs.
```

#### Prompt 4C — Dependency hygiene

```
Run flutter pub outdated. Produce a safe upgrade plan:

Priority: firebase_*, flutter_local_notifications, go_router, flutter_bloc major versions.

Upgrade in small PRs with flutter analyze + test after each batch.
Address the Kotlin Gradle Plugin built-in Kotlin migration warning from the Android build.
```

#### Prompt 4D — Release hardening

```
Android release checklist:
- Enable minifyEnabled + shrinkResources with tested ProGuard rules
- Verify Razorpay, Google Maps, Firebase keep rules
- android:usesCleartextTraffic false in production flavor
- Review network security config

iOS: ATS enforced, no arbitrary loads in production.
```

---

## Recommended execution order

| Phase | Focus | Suggested duration |
|-------|--------|-------------------|
| **1** | Security, CI, policy, API env | 1–2 weeks |
| **2** | Architecture, FCM, split large files | 2–3 weeks |
| **3** | Analyzer clean, tests, TODO cleanup | 2–4 weeks |
| **4** | Flavors, observability, deps, release hardening | Ongoing |

---

## Quick wins (< 1 hour)

1. Fix `network_info_impl.dart` list check  
2. Change cancellation dialog from 8h → 2h  
3. Uncomment `flutter analyze` in CI  
4. Remove unused import/warning in `section_header.dart`  
5. Switch `review_confirm_page` to global `ProfileBloc`  

---

## Related artifacts

| Artifact | Path |
|----------|------|
| Knowledge graph (interactive) | `graphify-out/graph.html` |
| Graph audit report | `graphify-out/GRAPH_REPORT.md` |
| API documentation | `API_DOCUMENTATION.md` |
| Folder structure guide | `lib/FOLDER_STRUCTURE.md` |

---

*Generated from codebase audit on 2026-06-30. Re-run graphify and `flutter analyze` after major refactors to refresh this report.*
