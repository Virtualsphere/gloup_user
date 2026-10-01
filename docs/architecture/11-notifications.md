# 11. Notifications

> Owner: Mobile Engineering · Last reviewed: 2026-09-28 · Applies to version: Android `2.8.14+73`

Firebase initialization and local notifications are set up before `runApp`. The service requests notification permission, registers the top-level background handler, listens to foreground messages and notification taps, and stores/updates the FCM token through the backend device-ID endpoint. Token refresh is observed and persisted.

For notification payloads containing a platform notification block, the OS handles background/terminated display. Foreground iOS uses system presentation settings; foreground Android creates a local notification. Data-only messages use title/body aliases and create a local notification. Optional images are downloaded with a five-second timeout; failures fall back to text. JSON data is preserved as local notification payload and parsed defensively on tap.

`NotificationRoutes` accepts explicit route keys (`route`, `screen`, `deep_link`, `link`, `path`) or type aliases. Booking/appointment types open bookings; salon/store types require a salon/store ID; promotion types open home; category carries optional category values. Unknown types route to home, and missing salon IDs fall back to home. Backend teams should preserve the documented payload keys or coordinate a client update.

The app uses channel ID `gloup_default_channel` on Android. Check platform permission behavior and notification delivery in physical-device release testing; simulator success does not prove production delivery.
