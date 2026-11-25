# GloUp Home & Discovery redesign — requirements and phased prompts

Source: Figma "GloUp app for development", section **04 · Home & discovery**
(nodes 3-2 Home, 4-2 Offer pop-up, 5-2 Category page, 6-2 Filter options, 67-2 Favorites).
Frames are 390 × 844 (Home is 390 × 2010, scrolling).

Only the Sort-by tab of the filter sheet is visible in Figma; the other seven tabs
(Gender, Rating, Distance, Price, Offers, Services, Open now) are inferred from the tab
list and the "Quick picks" chips. Confirm them with design before Phase 4.

---

## 1. Screen inventory

### 1.1 Home (3-2)
| Block | Contents |
|---|---|
| Header | Location pill "Home ▾" + address line "12, 3rd Ave, Anna Nagar, Chennai"; wallet chip "₹250"; profile avatar "U" |
| Search | "Search 'hair spa'" with mic icon; **UNI/SEX toggle** at the right |
| Gender tabs | Male (default) / Female segmented control |
| Hero carousel | Dark card "FESTIVE GLOW-UP · Services start @ ₹9 · On 200+ salons near you · Book now"; page dots; next card peeks |
| Categories | "What are you looking for?" + See all; 4×2 grid of rounded image tiles (Haircut, Beard, Facial, Nails, Massage, Makeup, Styling, Threading) |
| Popular services nearby | Horizontal cards: image, service name, price + struck-through MRP (Men's haircut ₹99 ₹149, Head massage ₹149 ₹249, Cleanup ₹399) + See all |
| Salon list | "142 salons around you"; chips Filters, Sort ▾, Nearest (selected), Rating 4.0+ |
| Salon card | Hero image, optional "Promoted" tag, offer badge ("FLAT ₹150 OFF", "50% OFF up to ₹100"), heart, name, rating pill (4.7 ★), rating count (2.1k ratings), services line (Haircut · Beard · Hair colour), "0.8 km · Anna Nagar West · Men", "Next slot today, 11:30 AM" |
| Bottom nav | Home, Bookings, Favorites, Profile |

### 1.2 Welcome offer pop-up (4-2)
Modal over dimmed Home: close ✕, hero image, "WELCOME GIFT", "Flat 50% off your first booking",
"Up to ₹100 off on any service. Valid for 48 hours.", code box `GLOWNEW` with Copy,
"Book a salon" primary button, "T&C apply".

### 1.3 Category page (5-2)
Back arrow, title "Haircut", "86 salons · Anna Nagar", search icon; sub-category avatar row
(All, Men's cut, Women's cut, Beard trim, Kids …); chips Filters (2 active), Sort: Nearest,
Male, Rating; strip "24 salons have offers on haircuts today"; list rows with image, offer badge
("₹50 OFF"), name, rating pill, count · distance, area · gender, "Haircut from ₹99 ~~₹149~~", **Book** button.

### 1.4 Filters and sorting sheet (6-2)
Bottom sheet with ✕. Left rail: Sort by, Gender•, Rating•, Distance, Price, Offers, Services,
Open now (dot = has a selection). Right pane for Sort by: Relevance (default), Distance: nearest
first, Rating: high to low, Price: low to high, Price: high to low, Earliest available slot.
Quick picks: Rating 4.0+, Unisex, Under ₹300. Footer: Clear all, "Show 38 salons" (live count).

### 1.5 Favorites (67-2)
Title "Favorites", "8 saved"; tabs **Salons · 8** / **Services · 3**; cards with image, name,
rating pill, rating count, services · distance, heart (filled), "Next slot · 1:00 PM", offer text
("50% off", "Flat ₹150 off"); closed state "Closed today · opens 10 AM".

---

## 2. Data required per screen vs what exists

| Need | Endpoint | Status |
|---|---|---|
| Banners | `GET /user/app/v2/getbanner` (image only) | **Gap:** no title/subtitle/CTA/deep-link; Figma card is text-driven |
| Categories | `GET /v2/getallcategory` | OK (id, name, image). Ordering for the 8-tile grid is by id DESC; add a `sort_order` if design wants a fixed order |
| Popular services nearby | `POST /v2/services/top-categories` | **Partial:** has category, discounted price, image; no MRP, no geo filter |
| Nearby salons + total | `POST /v2/store/nearby` | **Done now:** sort, minRating, minPrice, maxPrice, hasOffers, `offerBadge`, count respects filters |
| Salon cards: rating count, distance, area, gender, services | nearby response | OK (`reviewCount`, `distance`, `area`, `categories`, `dynamicServices`) |
| Promoted tag | `isPremium` | OK (mapped to "Promoted") |
| Next slot today / open now / closed | none | **Gap** (needs slot + holiday logic, see Phase 5) |
| Wallet chip | `POST /getwalletamout` | OK |
| Welcome pop-up | `GET /v2/home/welcome-offer` | **Done now** (code, title, discount, `validUntil`; null once used) |
| Category page list | `POST /v2/stores/by-category` | Exists; needs sort/offer count/sub-category (Phase 3) |
| Sub-category chips (Men's cut …) | none | **Gap** |
| "24 salons have offers" | none | **Gap** (can reuse `hasOffers` count) |
| Distance / Services / Open-now / Gender filters | nearby | **Gap:** gender exists; distance (radius is fixed at 10 km), services, open-now not yet |
| Favorite salons | `GET/POST /v2/favourites` | Exists; response lacks `dynamicServices`, `offerBadge`, next slot, open state |
| Favorite services (tab 2) | none | **Gap:** needs a new `FavouriteServices` table + endpoints |
| UNI/SEX toggle | `gender` param (male/female/unisex) | OK; confirm toggle semantics (Phase 1) |

### Backend pushed to `uat` (commit 0d2ac6e)
1. `POST /v2/store/nearby` accepts `sort` (`distance|rating|price_asc|price_desc`), `minRating`,
   `minPrice`, `maxPrice`, `hasOffers`; `pagination.totalRecords` is the filtered count, so it
   drives "Show 38 salons" (call with `limit: 1`).
2. Salon objects now include `offerBadge`: `{ type, percent, flat, label, serviceName } | null`.
3. `GET /v2/home/welcome-offer` (auth): coupon code from env `WELCOME_COUPON_CODE`
   (default `GLOWNEW`), window from `WELCOME_OFFER_HOURS` (default 48) after `registered_at`,
   capped by the coupon `end_date`. Returns `data: null` if the user has a paid booking, already
   used the coupon, or it is missing/expired.

**Needs your action:** create an active coupon with code `GLOWNEW` (percentage, 50) in the admin
panel on UAT. "Up to ₹100" has no column today (Coupons has no max-discount); the pop-up copy
comes from the coupon `description`, and the cap must also be enforced in `validatecoupon`
(Phase 6).

### Still to build in the backend
- Banner fields: `title`, `subtitle`, `cta_label`, `deeplink` (migration on `Banner`).
- Next-slot / open-now on nearby and favourites (reuse the slot and holiday utilities).
- Distance filter (radius param, currently fixed 10 km), services filter, open-now filter,
  "earliest slot" sort.
- Category page: sub-category list and `offerCount` per category.
- Favourite services table and endpoints.
- Coupon `max_discount_amount`, `min_order_value`, `first_booking_only` columns.
- Note: `GROUP_CONCAT` for `servicesList` is limited by `group_concat_max_len`; raise it
  or limit per store if salons with many services lose chips.

---

## 3. App-side work map (Flutter, `lib/`)

Existing: `features/home` (HomePage, HomeBloc, widgets for category, gender toggle, search,
service ticker), `features/category`, `features/favorites`, `features/coupons`,
`shared/widgets/service_ticker.dart`. Design tokens come from `AppColors`/`AppSizes`.

New or changed: `HomeHeader` (wallet chip, UNI/SEX), `HeroBannerCarousel`, `CategoryGrid`,
`PopularServicesRail`, `SalonCard` (shared by Home, Category, Favorites), `OfferBadge`,
`FiltersSheet` (+ `FilterState` model shared with the API request), `WelcomeOfferDialog`,
`CategoryPage`, `FavoritesPage` with two tabs.

---

## 4. Phase-wise prompts

Paste one phase at a time into a new Claude Code session in `gloup_user`. Each phase ends with
`flutter analyze` clean and a build to the Android emulator.

### Phase 0 — Foundations
> Read `docs/home-redesign-requirements.md`. In `gloup_user`, add the design tokens needed for
> the Home & discovery redesign (colours, radii, text styles) to the existing theme, matching
> Figma section 04. Create the shared models: `OfferBadge`, extend the salon model with
> `offerBadge` and `dynamicServices`, add a `FilterState` (sort, gender, minRating, minPrice,
> maxPrice, hasOffers, maxDistance, serviceIds, openNow) with `toRequest()`. Do not change screens yet.
> Add unit tests for parsing and `toRequest()`.

### Phase 1 — Home header, search, gender
> Rebuild the Home header per Figma 3-2: location pill with address, wallet chip (data from the
> wallet API, hidden for guests), profile avatar, search bar with mic, UNI/SEX toggle and the
> Male/Female segmented control. Keep existing location logic from `home_page.dart`. Map the
> toggle to the `gender` param (`male`/`female`/`unisex`) and make it persist. Add widget tests.

### Phase 2 — Hero carousel, categories, popular services
> Build the hero banner carousel (dots, peek of the next card, Book now deep link), the 4×2
> category grid ("What are you looking for?" + See all) and the "Popular services nearby" rail
> showing price and struck-through MRP. Use `v2/getbanner`, `v2/getallcategory` and
> `v2/services/top-categories`. Add skeletons and empty/error states. Until the backend adds
> banner text fields, fall back to image-only banners.

### Phase 3 — Salon list and card
> Replace the Home salon list with the new `SalonCard`: promoted tag, offer badge from
> `offerBadge`, favourite heart (optimistic toggle with rollback), rating pill, rating count,
> services line from `dynamicServices`, distance · area, and a "Next slot today" line shown only
> when the API returns it. Show "N salons around you" from `pagination.totalRecords`, with chips
> Filters, Sort and Nearest / Rating 4.0+ quick picks wired to `FilterState`. Pagination and
> pull-to-refresh must keep working.

### Phase 4 — Filters and sorting sheet
> Build the Filters and sorting bottom sheet (Figma 6-2): left rail with dot indicators, Sort by
> options, quick picks, Clear all and a live "Show N salons" button (debounced call to
> `v2/store/nearby` with `limit: 1`, reading `totalRecords`). Implement the Gender, Rating,
> Distance, Price, Offers, Services and Open now panes from the same `FilterState`; confirm the
> design for those panes first. Use it from Home and the Category page.

### Phase 5 — Category page
> Build the Category page (Figma 5-2) for a tapped category: header with count and area,
> sub-category avatar row, Filters/Sort/Gender chips, the "N salons have offers today" strip, and
> rows with "Haircut from ₹X ~~₹Y~~" and a Book button that opens the salon with the service
> preselected. Reuse `SalonCard` or a compact variant and `FiltersSheet`. Needs the backend
> sub-category and offer-count endpoints (see section 2).

### Phase 6 — Welcome offer pop-up
> Add the Welcome gift dialog (Figma 4-2). After the first Home load for a signed-in user, call
> `GET /v2/home/welcome-offer`; if `data` is not null and not shown this session, show the dialog
> with title, description, code and Copy (clipboard + toast), "Book a salon" (closes and scrolls
> to the salon list) and "T&C apply". Show it at most once per `validUntil` window and never
> for guests. Show a countdown if `validUntil` is under 6 hours away.

### Phase 7 — Favorites
> Rebuild Favorites (Figma 67-2): "N saved" header, Salons / Services tabs with counts, cards
> with next slot, offer text and the closed state ("Closed today · opens 10 AM"). Removing a
> heart animates the card out with Undo. The Services tab is behind a flag until the backend has
> favourite-services endpoints.

### Phase 8 — QA and release
> Run `flutter analyze` and all tests, check small phones (360 dp) and large text scale, dark
> mode, no-network and empty-location states, then build the UAT release APK with
> `--dart-define=API_BASE_URL=http://169.58.105.116:5678`.

---

## 5. Open questions for design / product
1. What does UNI/SEX do exactly: show unisex salons only, or both genders together?
2. Is "Promoted" paid placement (separate field) or the current `is_premium` flag?
3. Offer badge: show the best percentage, the largest flat amount, or a coupon-driven label?
4. Distance filter steps, Price range steps and the Services list for the Filters sheet.
5. Is the welcome offer first booking only, and is the "up to ₹100" cap enforced at checkout?
6. Are favourite services a real feature for this release?
