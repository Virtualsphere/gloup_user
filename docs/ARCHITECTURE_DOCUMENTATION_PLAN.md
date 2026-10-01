# GloUp User App — Architecture Documentation Plan

This file lists **what architecture documentation the GloUp user app (`tressy`) needs**, how it should be structured, and how it stays current. It is the blueprint; each section below becomes its own document under `docs/architecture/`.

Architecture docs sit **above the code**: they explain how the app is structured, how its parts interact, and *why* it was built that way. Code comments and API references are separate.

---

## 1. Goals and audience

| Audience | What they need from these docs |
|---|---|
| New Flutter developers | How features are laid out, how data flows, where to add new code |
| Existing developers | Why things are built a certain way before changing them |
| Backend developers | Which endpoints the app calls, auth headers, payload shapes it depends on |
| QA | Critical flows (booking, payment, review), environments, deep links |
| Release / DevOps | Build flavors, versioning, Shorebird patching, store release steps |
| Product / non-technical | What the app does, main user journeys, known constraints |

**Rule of thumb:** document what someone needs to know to safely modify the app without being the person who built it.

---

## 2. Frameworks we will use

- **C4 model** for diagrams (Level 1–3; Level 4 is the code itself).
- **arc42 (trimmed)** for the written sections.
- **ADRs** (Architecture Decision Records) for every significant decision, stored in `docs/adr/`.
- **Mermaid** for diagrams so they live in Markdown and render on GitHub.

---

## 3. Target folder layout

```
docs/
├── ARCHITECTURE_DOCUMENTATION_PLAN.md   ← this file
├── architecture/
│   ├── 01-system-overview.md
│   ├── 02-c4-context.md
│   ├── 03-c4-containers.md
│   ├── 04-app-architecture.md           (layers, state management, DI)
│   ├── 05-feature-catalog.md
│   ├── 06-navigation-and-deep-links.md
│   ├── 07-networking-and-auth.md
│   ├── 08-data-flows.md                 (booking, payment, review, etc.)
│   ├── 09-integrations.md
│   ├── 10-local-storage-and-caching.md
│   ├── 11-notifications.md
│   ├── 12-non-functional-requirements.md
│   ├── 13-build-release-deployment.md
│   ├── 14-testing-strategy.md
│   ├── 15-risks-and-tech-debt.md
│   └── 16-glossary.md
└── adr/
    ├── 0000-adr-template.md
    ├── 0001-clean-architecture-with-bloc.md
    └── ...
```

---

## 4. What each document must include

### 4.1 System overview (`01-system-overview.md`)
- What the app does: discover salons, view services and prices, book slots, pay, review.
- Who uses it: end customers (guest and logged-in).
- Where it fits in the GloUp platform: User App, Partner App, Admin Panel, Backend API.
- Platforms supported: Android, iOS (web/desktop folders exist but are not shipped).
- Current version scheme (Android and iOS lines in `pubspec.yaml`).
- Links to every other architecture doc.

### 4.2 C4 Level 1 — System context (`02-c4-context.md`)
Diagram and short description showing the app in relation to:
- **Customer** (user)
- **GloUp Backend API** (`api.v1.gloup.in`)
- **CDN / image storage** (salon, banner, category images)
- **Firebase** (FCM push notifications)
- **Razorpay** (payments)
- **Google Maps / Places / Geocoding**
- **Google Sign-In / Sign in with Apple**
- **Facebook App Events** (analytics)
- **Play Store / App Store** (force update, in-app update)
- **Shorebird** (code push)

### 4.3 C4 Level 2 — Containers (`03-c4-containers.md`)
- Flutter app (UI + BLoC + repositories)
- Local storage: `SharedPreferences` and `FlutterSecureStorage`
- Backend REST API (user endpoints)
- Push notification channel (FCM → local notifications)
- How they communicate (HTTPS/JSON via Dio, FCM, deep links)

### 4.4 App architecture (`04-app-architecture.md`) — C4 Level 3
- **Layering:** `presentation` → `domain` → `data` per feature (Clean Architecture).
- **Data flow:** `Page → Bloc/Cubit → UseCase → Repository → DataSource → Dio → API`, and `Model → Entity` mapping.
- **State management:** where BLoC, Cubit, and Provider are used and why (e.g. `LocationProvider`, `ThemeProvider` vs feature BLoCs).
- **Dependency injection:** `get_it` setup in `core/di/injection_container.dart`, registration rules (singleton vs factory).
- **Error handling:** `ApiException` → `Failure` (`dartz` `Either`), how errors reach the UI (toasts, error widgets).
- **`core/` vs `shared/` vs `features/`**: what belongs where.
- Checklist for **adding a new feature**.

### 4.5 Feature catalog (`05-feature-catalog.md`)
One short entry per feature: purpose, main screens, BLoCs, endpoints used, dependencies on other features, owner.

| Feature | Covers |
|---|---|
| `splash` | App start, session restore, force-update check |
| `onboarding` | First-launch screens |
| `auth` | OTP login, Google, Apple, logout, token handling |
| `location` | Location permission, address selection |
| `home` | Banners, categories, gender filter, recommended/nearby salons, pending review prompt |
| `category` | Salons/services by category |
| `explore` | Explore listing and filters |
| `salon_search` | Search, map view, filters |
| `map_markers` | Clustered map markers |
| `salon_details` | Salon info, services, prices (fake price strikethrough), gender icons, reviews, gallery |
| `slot_booking` | Date/slot selection, holidays |
| `booking_confirmation` | Review & confirm, guests, coupons, billing summary (GST, ₹3 platform fee, Gloup Cash), Razorpay |
| `bookings` | Upcoming/past bookings, cancel, rate & review |
| `coupons` | Active coupons, validation |
| `favorites` | Favourite salons |
| `my_reviews` | User's reviews (edit/delete) |
| `profile` | Profile, settings, support/legal pages |

### 4.6 Navigation and deep links (`06-navigation-and-deep-links.md`)
- `go_router` setup (`core/router/app_router.dart`, `route_names.dart`).
- Route map (all routes and their params/`extra` payloads).
- Auth guards / redirects.
- Notification tap routing (`notification_routes.dart`).
- App Links hosts (`www.gloup.in`, `api.v1.gloup.in`) and which paths open which screens (e.g. `/download`).

### 4.7 Networking and auth (`07-networking-and-auth.md`)
- `DioClient` configuration, timeouts, interceptors (`AuthInterceptor`, logging).
- `baseUrl` via `--dart-define` (`String.fromEnvironment`), image base URL.
- Auth header (`userauth`), public vs authenticated endpoints, optional-auth endpoints (e.g. store details).
- Session handling (`AuthSessionManager`), token storage and migration (`access_token_migration.dart`).
- Connectivity checks (`NetworkInfo`, `repository_network_guard.dart`).
- Endpoint inventory table (grouped by feature) — link to backend API docs instead of duplicating schemas.

### 4.8 Data flows (`08-data-flows.md`)
Sequence diagrams (happy path + error/retry/fallback) for:
- Login (OTP / Google / Apple) and session restore.
- Home load (banners, categories, nearby salons, gender filter).
- Salon details → select services → slot booking.
- Booking confirmation → create order → Razorpay → payment success/failure.
- Cancellation and refund.
- Pending review prompt (dismiss per appointment, never re-prompt).
- Push notification received → tap → navigation.
- Price display rules: `price`, `originalPrice`, `fakePrice` fallback, discount % calculation.

### 4.9 Integrations (`09-integrations.md`)
For each: purpose, SDK/package, config location, keys/secrets handling, failure behavior.
- Firebase (`firebase_options.dart`, FCM)
- Razorpay
- Google Maps / Places / Geocoding / Geolocator
- Google Sign-In, Sign in with Apple
- Facebook App Events
- `upgrader` / `in_app_update` (force update)
- `app_links`
- Shorebird

### 4.10 Local storage and caching (`10-local-storage-and-caching.md`)
- What is stored in `FlutterSecureStorage` vs `SharedPreferences` (`LocalStorageService`, `Keys`).
- Persisted UX state (e.g. dismissed pending-review appointment IDs, onboarding seen).
- Image caching (`cached_network_image`, `HdCachedNetworkImage`, cache dimensions).
- What is cleared on logout.

### 4.11 Notifications (`11-notifications.md`)
- FCM token registration (`device_id` endpoint), refresh handling.
- Foreground vs background vs terminated handling.
- Local notification channels, images in notifications, duplicate prevention.
- Payload contract with backend (types → routes).

### 4.12 Non-functional requirements (`12-non-functional-requirements.md`)
- Performance targets (cold start, home load, image sizes — e.g. banner ratio 1 : 0.85).
- Offline/poor-network behavior.
- Security: token storage, no secrets in repo, HTTPS only, ProGuard/R8.
- Supported OS versions (min SDK, iOS minimum).
- Accessibility and localization (if any).

### 4.13 Build, release, deployment (`13-build-release-deployment.md`)
- Versioning rules (Android vs iOS lines in `pubspec.yaml`; build number must always increase for Play Store).
- `--dart-define` values per environment (UAT vs prod `baseUrl`).
- Signing (keystore via `key.properties` / env vars — never commit secrets).
- Shorebird: release vs patch, commands, what cannot be patched (native/plugin changes).
- Pinned dependency overrides and why (e.g. `package_info_plus: 10.1.0`, `google_maps_flutter_android`).
- CI (`.github/workflows/ci.yml`): format, analyze, test, build.
- Store release checklist.

### 4.14 Testing strategy (`14-testing-strategy.md`)
- Unit tests (BLoCs with `bloc_test`, repositories with `mocktail`).
- Test fixtures (`test/helpers/`).
- What must be tested before release (booking + payment flow, pricing, auth).

### 4.15 Risks and tech debt (`15-risks-and-tech-debt.md`)
- Known risks (e.g. mixed state management, hardcoded values like Gloup Cash, platform fee duplicated in app and backend).
- Dependency upgrade blockers.
- Areas with thin or missing tests.

### 4.16 Glossary (`16-glossary.md`)
Salon/store, partner, slot, appointment, Gloup Cash, platform fee, fake price, tier discount, store type/gender, etc.

---

## 5. ADRs to write first

Use the template below. One decision per ADR, one page max. Never delete; mark as *Superseded by ADR-XXXX*.

| ADR | Decision |
|---|---|
| 0001 | Clean Architecture per feature with BLoC |
| 0002 | `get_it` for dependency injection |
| 0003 | `go_router` for navigation and deep links |
| 0004 | Dio with interceptors for networking and auth header |
| 0005 | `dartz` `Either<Failure, T>` for error handling |
| 0006 | Secure storage for access token (with legacy migration) |
| 0007 | Firebase Cloud Messaging for push notifications |
| 0008 | Razorpay as payment gateway |
| 0009 | Shorebird for over-the-air patches |
| 0010 | Force update via `upgrader` / `in_app_update` |
| 0011 | Separate Android and iOS version lines in `pubspec.yaml` |
| 0012 | Show `fakePrice` as strikethrough on the frontend (fallback to `originalPrice`) |
| 0013 | Pending review prompt dismissed per appointment, stored locally |
| 0014 | Pin `package_info_plus` to 10.1.0 (10.2.x breaks Android release builds) |

### ADR template (`docs/adr/0000-adr-template.md`)

```markdown
# ADR-XXXX: <Title>

## Status
Proposed | Accepted | Superseded by ADR-XXXX

## Date
YYYY-MM-DD

## Context
What problem are we solving? What constraints and options exist?

## Decision
What we decided.

## Consequences
- Positive outcomes
- Trade-offs we accept
- When we should revisit this
```

---

## 6. Level of detail

| Area | Depth |
|---|---|
| System overview, C4 L1–L2 | Short: 2–3 pages total |
| App architecture, C4 L3 | Medium; focus on patterns, not every class |
| Feature catalog | One short block per feature; deeper only for complex features (booking, payment, salon details) |
| Data flows, integrations | Thorough: happy path, errors, retries, fallbacks |
| ADRs | One page each |

---

## 7. How we keep it up to date

1. **Definition of done:** any PR that adds a feature, changes an integration, endpoint, data flow, or build process updates the relevant doc in the same PR.
2. **New ADR for every architectural change** (new package with app-wide impact, new pattern, dependency pin, release process change).
3. **Owners:** each document has a named owner listed in its header.
4. **Quarterly review:** compare docs against the code; fix drift; mark stale sections.
5. **Automate where possible:** route list and endpoint list can be generated from `route_names.dart` and `api_routes.dart`; dependency graph from `pubspec.lock`.
6. **Header on every doc:**

```markdown
> Owner: <name> · Last reviewed: YYYY-MM-DD · Applies to version: x.y.z+N
```

---

## 8. Rollout order

1. System overview + C4 context/container diagrams
2. App architecture + feature catalog
3. Networking/auth + booking/payment data flows
4. First 5 ADRs
5. Build/release/Shorebird doc
6. Remaining sections, then quarterly review cadence
