# 05. Feature Catalog

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

| Feature | Responsibility and main screens | Notable state / dependencies |
|---|---|---|
| `splash` | Startup screen and transition | Root route; update check is app-level |
| `onboarding` | First-use introduction | Onboarding preference |
| `auth` | OTP, Google/Apple sign-in, logout | `AuthBloc`, secure token storage |
| `location` | Location selection and saved area | `LocationProvider`, permission/location plugins |
| `home` | Banners, categories, salon discovery, review prompt | Shared `HomeBloc`, categories, salon use case |
| `category` | Category and category-based discovery | Shared `CategoryBloc` |
| `explore` | Explore listings | `ExploreBloc`, shared salon use case |
| `salon_search` / `map_markers` | Search, nearby results, map markers | Search and marker BLoCs, Google Maps |
| `salon_details` | Salon profile, services, gallery, reviews | Detail BLoC and page Cubit |
| `slot_booking` | Availability dates, slots, holidays | `SlotBloc`, slot API |
| `booking_confirmation` | Guests, coupons, bill, order and payment | `GuestBloc`, `OrderBloc`, calculator, Razorpay |
| `bookings` | Appointment list and cancellation/review entry points | `AppointmentsBloc` |
| `coupons` | Active coupon discovery | `CouponBloc` |
| `favorites` | Favorite salon list and toggle | Shared `FavoritesBloc` |
| `my_reviews` | User review screens | Route integration; API paths in `ApiRoutes` |
| `profile` | Profile, wallet, settings, support and legal content | `ProfileBloc`, profile repository |
| `shared` | Reusable salon data access and domain entities | Shared repository and use case |
| `widgets` | Common presentation components | No feature ownership |

The catalog describes source folders, not a guarantee that every screen is reachable in every release. Owners are collectively Mobile Engineering; assign an individual feature owner in the relevant project tracker.
