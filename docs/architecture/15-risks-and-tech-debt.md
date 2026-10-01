# 15. Risks and Technical Debt

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

| Risk | Current evidence | Recommended follow-up |
|---|---|---|
| Mixed state management | BLoC is primary, while Provider handles theme/location | Keep new feature state consistent; document exceptions and lifecycle |
| Broad auth attachment | Interceptor attaches token to every non-public auth path; `requiresAuth` uses same classification | Maintain explicit public/optional/protected route policy with backend contract |
| Deep links do not navigate | `AppLinks` listener logs only | Decide supported URL contract and implement/test destination mapping |
| Client/server billing drift | Client calculator contains 5% default GST and accepts platform fee/wallet values | Treat server totals as authoritative and contract-test the displayed breakdown |
| Release version ambiguity | iOS version declaration is commented while Android declaration is active | Define one release source of truth and automate monotonic build-number validation |
| Debug signing fallback | Android release config uses debug signing if release secrets are absent | Fail release CI when production signing is not configured |
| Limited offline support | Network guard exists; no general persistent API cache | Document per-flow retry and degraded behavior; avoid unsafe transaction retries |
| SDK configuration sensitivity | Firebase configuration and a Razorpay key constant are present | Review key restrictions, config exposure, and provider console ownership |
| Dependency overrides | Map plugin override and exact package-info pin are build-sensitive | Keep rationale and validate Android release/Shorebird builds on upgrades |
| Incomplete quality targets | No explicit performance budgets, accessibility/localization policy, or owner per feature | Agree measurable targets and assign accountable owners |

These are observations from the checked-in application, not confirmed production incidents. Reassess each item when its adjacent code or provider configuration changes.
