# Graph Report - gloup_user  (2026-07-26)

## Corpus Check
- 356 files · ~484,946 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 4581 nodes · 7236 edges · 210 communities (205 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9ab9e31f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 5
- Community 6
- Community 7
- Community 8
- Community 9
- Community 10
- Community 11
- Community 12
- Community 13
- Community 14
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 83
- Community 84
- Community 85
- Community 86
- Community 87
- Community 88
- Community 89
- Community 90
- Community 91
- Community 92
- Community 93
- Community 94
- Community 95
- Community 96
- Community 97
- Community 98
- Community 99
- Community 100
- Community 101
- Community 102
- Community 103
- Community 104
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 111
- Community 112
- Community 113
- Community 114
- Community 115
- Community 116
- Community 117
- Community 118
- Community 119
- Community 120
- Community 121
- Community 122
- Community 123
- Community 124
- Community 125
- Community 126
- Community 127
- Community 128
- Community 129
- Community 130
- Community 131
- Community 132
- Community 133
- Community 134
- Community 135
- Community 136
- Community 137
- Community 138
- Community 139
- Community 140
- Community 141
- Community 142
- Community 143
- Community 144
- Community 145
- Community 146
- Community 147
- Community 148
- Community 149
- Community 150
- Community 151
- Community 152
- Community 153
- Community 154
- Community 155
- Community 156
- Community 157
- Community 158
- Community 159
- Community 160
- Community 161
- Community 162
- Community 163
- Community 164
- Community 165
- Community 166
- Community 167
- Community 168
- Community 169
- Community 170
- Community 171
- Community 172
- Community 173
- Community 174
- Community 175
- build
- Community 177
- Community 178
- Community 179
- Community 181
- Community 182
- Community 183
- Community 184
- Community 185
- Community 188
- Community 189
- Community 191
- Community 192
- Community 195
- Community 196
- Community 198
- Community 199
- Community 200
- Community 201
- Community 202
- Community 203
- Community 204
- Community 205
- Community 206
- Community 207
- Community 208
- Community 209
- Community 216
- Community 217

## God Nodes (most connected - your core abstractions)
1. `ProfileBloc` - 46 edges
2. `LocationProvider` - 38 edges
3. `AuthBloc` - 31 edges
4. `GuestBloc` - 22 edges
5. `FavoritesBloc` - 22 edges
6. `SearchBloc` - 22 edges
7. `Win32Window` - 22 edges
8. `CategoryBloc` - 21 edges
9. `DioClient` - 17 edges
10. `HomeBloc` - 17 edges

## Surprising Connections (you probably didn't know these)
- `main` --calls--> `SendOtpEvent`  [EXTRACTED]
  test/features/auth/login_page_test.dart → lib/features/auth/presentation/bloc/auth_event.dart
- `MockAuthBloc` --implements--> `AuthBloc`  [EXTRACTED]
  test/features/auth/login_page_test.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `MockCategoryBloc` --implements--> `CategoryBloc`  [EXTRACTED]
  test/helpers/widget_test_helpers.dart → lib/features/category/presentation/bloc/category_bloc.dart
- `MockFavoritesBloc` --implements--> `FavoritesBloc`  [EXTRACTED]
  test/helpers/widget_test_helpers.dart → lib/features/favorites/presentation/bloc/favorites_bloc.dart
- `MockHomeBloc` --implements--> `HomeBloc`  [EXTRACTED]
  test/helpers/widget_test_helpers.dart → lib/features/home/presentation/bloc/home_bloc.dart

## Import Cycles
- None detected.

## Communities (210 total, 5 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.02
Nodes (101): appBarElevation, appBarHeight, AppSizes, borderWidth, borderWidthSmall, borderWidthThick, borderWidthThin, bottomNavHeight (+93 more)

### Community 1 - "Community 1"
Cohesion: 0.02
Nodes (83): accent, accentLight, AppColors, background, backgroundDark, black, border, borderColor (+75 more)

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (72): DioClient, BookingRemoteDataSource, BookingRemoteDataSourceImpl, cancelPendingOrder, createOrder, dioClient, _handleDioException, verifyPayment (+64 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (56): AppIcons, arrowBack, bfButton, call, camera, cancel, cancelNotAllowed, copy (+48 more)

### Community 4 - "Community 4"
Cohesion: 0.03
Nodes (79): IconData?, build, CountryCodeSelector, initialSelection, _guestCardShimmer, guestListShimmer, GuestShimmers, build (+71 more)

### Community 5 - "Community 5"
Cohesion: 0.04
Nodes (48): about, address, AmbientModel, ambients, category, closingTime, discountPercentage, duration (+40 more)

### Community 6 - "Community 6"
Cohesion: 0.10
Nodes (21): _activeFilterIndex, build, createState, initialFilterIndex, initState, isDarkMode, SalonAllReviewsSheet, _SalonAllReviewsSheetState (+13 more)

### Community 7 - "Community 7"
Cohesion: 0.04
Nodes (46): addGuest, ApiRoutes, appleLogin, bannerImageBaseUrl, baseUrl, cancelPendingOrder, categoryImageBaseUrl, createOrder (+38 more)

### Community 8 - "Community 8"
Cohesion: 0.08
Nodes (25): fromJson, toEntity, toJson, addGuest, getAllGuests, GuestRepositoryImpl, networkInfo, remoteDataSource (+17 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (38): MapMarkersEntity, dataSource, getClusteredMarkers, getNearbySalons, networkInfo, SearchRepositoryImpl, searchSalons, getClusteredMarkers (+30 more)

### Community 10 - "Community 10"
Cohesion: 0.05
Nodes (39): dataSource, getCarouselBanners, getPopularServices, getTopSalons, HomeRepositoryImpl, networkInfo, getCarouselBanners, getPopularServices (+31 more)

### Community 11 - "Community 11"
Cohesion: 0.05
Nodes (43): brushFill, brushHeight, build, _buildServiceList, cardBase, cardGradient, cardHeight, cardOverlay (+35 more)

### Community 12 - "Community 12"
Cohesion: 0.04
Nodes (47): addedServices, availableCoupons, _billingBreakdown, bookingData, _buildGloupCashCheckbox, _buildRecommendedServices, _buildSectionTitle, _calculateAge (+39 more)

### Community 13 - "Community 13"
Cohesion: 0.05
Nodes (41): @pragma, @visibleForTesting, FlutterLocalNotificationsPlugin, androidDetails, androidSettings, body, clearPendingLaunchMessage, darwinDetails (+33 more)

### Community 14 - "Community 14"
Cohesion: 0.06
Nodes (32): Connectivity, Future, any, hasActiveConnectivity, connectivity, NetworkInfoImpl, isConnected, NetworkInfo (+24 more)

### Community 15 - "Community 15"
Cohesion: 0.05
Nodes (39): bool isReadOnly,, BoxShadow, EdgeInsetsGeometry get, InputBorder, build, child, controller, copyWith (+31 more)

### Community 16 - "Community 16"
Cohesion: 0.05
Nodes (38): accentBlue, addButtonBg, addedButtonBg, addedButtonBorder, addedButtonText, carouselGradient, carouselHeightFraction, chipCategoryBg (+30 more)

### Community 17 - "Community 17"
Cohesion: 0.05
Nodes (38): avgRating, bounds, categoryId, ClusterBoundsModel, clusteringEnabled, ClusterModel, clusters, count (+30 more)

### Community 18 - "Community 18"
Cohesion: 0.05
Nodes (38): about, address, ambients, category, closingTime, discountPercentage, duration, gender (+30 more)

### Community 19 - "Community 19"
Cohesion: 0.05
Nodes (39): Dio, Interceptor, initializeDependencies, sl, AuthInterceptor, delete, _dio, _handleDioException (+31 more)

### Community 20 - "Community 20"
Cohesion: 0.05
Nodes (37): address, averageRating, basicInfo, bookedDate, bookingDate, categoryId, commonData, data (+29 more)

### Community 21 - "Community 21"
Cohesion: 0.11
Nodes (19): authBloc, build, createState, dispose, _formKey, initState, _isLoading, LoginPage (+11 more)

### Community 22 - "Community 22"
Cohesion: 0.09
Nodes (36): getCarouselBannersUseCase, getPopularServicesUseCase, getSalonsUseCase, getTopSalonsUseCase, HomeBloc, _mapFailureToMessage, _onLoadAllHomeData, _onLoadCarouselBanners (+28 more)

### Community 23 - "Community 23"
Cohesion: 0.06
Nodes (35): class, BookingContactDetails, _BookingDetailsBottomSheet, _BookingDetailsBottomSheetState, build, controller, createState, dispose (+27 more)

### Community 24 - "Community 24"
Cohesion: 0.03
Nodes (79): @gloup, answer, build, children, company, email, emails, fontWeight (+71 more)

### Community 25 - "Community 25"
Cohesion: 0.08
Nodes (35): int?, addGuestUseCase, getAllGuestsUseCase, GuestBloc, _onAddGuest, _onLoadGuests, _onSelectGuest, _onUpdateGuest (+27 more)

### Community 26 - "Community 26"
Cohesion: 0.06
Nodes (34): add, appName, AppStrings, back, cancel, confirm, delete, done (+26 more)

### Community 27 - "Community 27"
Cohesion: 0.07
Nodes (32): SendOtpUseCase, VerifyOtpUseCase, authRepository, _mapFailureToMessage, _onAppleSignIn, _onGoogleSignIn, _onResetAuth, _onSendOtp (+24 more)

### Community 28 - "Community 28"
Cohesion: 0.09
Nodes (32): ExploreBloc, getSalonsUseCase, _mapFailureToMessage, _onLoadSalons, _onRefreshSalons, ExploreEvent, LoadExploreSalonsEvent, RefreshExploreSalonsEvent (+24 more)

### Community 29 - "Community 29"
Cohesion: 0.06
Nodes (33): build, _buildCategoriesRow, _buildCategoryShimmer, _buildFiltersRow, _buildSliverAppBar, _buildStatusText, _carouselImages, _categories (+25 more)

### Community 30 - "Community 30"
Cohesion: 0.06
Nodes (32): _accessTokenCacheReady, _cachedAccessToken, clearAll, clearTokens, getBool, getDouble, getInt, getString (+24 more)

### Community 31 - "Community 31"
Cohesion: 0.09
Nodes (25): getFavoritesUseCase, _mapFailureToMessage, _onLoadFavorites, _onToggleFavorite, toggleFavoriteUseCase, currentIsFavorite, FavoritesEvent, LoadFavoritesEvent (+17 more)

### Community 32 - "Community 32"
Cohesion: 0.06
Nodes (34): build, calculateAge, calculatedAge, cityController, countryController, createState, dateOfBirthController, dispose (+26 more)

### Community 33 - "Community 33"
Cohesion: 0.06
Nodes (32): age, _ageCtrl, build, controller, createState, dispose, _EditPersonBottomSheet, _EditPersonBottomSheetState (+24 more)

### Community 34 - "Community 34"
Cohesion: 0.08
Nodes (30): AnimationController, Cubit, SalonDetailsPageCubit, _bottomNavAnimation, _bottomNavController, build, _buildContent, createState (+22 more)

### Community 35 - "Community 35"
Cohesion: 0.26
Nodes (11): authEntity, AuthFailure, AuthInitial, AuthLoading, AuthState, message, OtpSentSuccess, OtpVerifiedSuccess (+3 more)

### Community 36 - "Community 36"
Cohesion: 0.06
Nodes (31): build, _buildCurrentLocationCard, _buildLocationCard, _buildPredictionCard, createState, _currentArea, _currentCity, _currentFullAddress (+23 more)

### Community 37 - "Community 37"
Cohesion: 0.17
Nodes (11): deleteProfileUseCase, getProfileUseCase, logoutUseCase, _mapFailureToMessage, _onDeleteProfile, _onGetProfile, _onLogout, _onRefreshProfile (+3 more)

### Community 38 - "Community 38"
Cohesion: 0.10
Nodes (19): activeTabIndex, build, _buildInfoSection, _buildInfoSheet, _buildLanguageBadge, _buildSalonGenderTag, _buildTabBar, _buildTitleAndCrownSection (+11 more)

### Community 39 - "Community 39"
Cohesion: 0.12
Nodes (15): Animation, bottomNavAnimation, build, _buildBottomNavBar, highestOfferPercentage, isDarkMode, _profileFromState, salonId (+7 more)

### Community 40 - "Community 40"
Cohesion: 0.06
Nodes (30): AppRouter, build, error, _ErrorPage, router, _routes, package:tressy/features/auth/presentation/pages/otp_page.dart, package:tressy/features/booking_confirmation/presentation/pages/review_confirm_page.dart (+22 more)

### Community 41 - "Community 41"
Cohesion: 0.06
Nodes (30): build, _buildSearchInput, categoryIndex, categoryName, _CategorySectionDelegate, createState, _debounceTimer, didChangeDependencies (+22 more)

### Community 42 - "Community 42"
Cohesion: 0.07
Nodes (29): Alignment, Color buttonColor,, Color outlineColor,, double borderRadius,, alignment, backgroundColor, build, buttonColor (+21 more)

### Community 43 - "Community 43"
Cohesion: 0.07
Nodes (29): BorderRadius get, GenderTab get, Gradient?, accentColor, borderColor, build, createState, _current (+21 more)

### Community 44 - "Community 44"
Cohesion: 0.07
Nodes (29): BuildContext, Color get, ColorScheme get, appSurface, canPop, colorScheme, ContextExtensions, goTo (+21 more)

### Community 45 - "Community 45"
Cohesion: 0.07
Nodes (28): CameraPosition?, DraggableScrollableController, GoogleMapController?, build, createState, _debounceTimer, dispose, _draggableController (+20 more)

### Community 46 - "Community 46"
Cohesion: 0.07
Nodes (29): HomeBloc get, createState, _currentCarouselIndex, didChangeDependencies, dispose, _getCurrentLocation, _homeBloc, _homeDataRequested (+21 more)

### Community 47 - "Community 47"
Cohesion: 0.07
Nodes (29): bookings, cancellation, category, contact, devInfo, editProfile, explore, faqs (+21 more)

### Community 48 - "Community 48"
Cohesion: 0.09
Nodes (26): class MockCancelPendingOrderUseCase extends, CancelPendingOrderUseCase, CreateOrderUseCase, VerifyPaymentUseCase, cancelPendingOrderUseCase, createOrderUseCase, _onCreateOrder, _onPaymentFailed (+18 more)

### Community 49 - "Community 49"
Cohesion: 0.14
Nodes (13): build, imageRadius, imageSize, imageUrl, isDarkMode, itemWidth, labelGap, onTap (+5 more)

### Community 50 - "Community 50"
Cohesion: 0.07
Nodes (26): build, imageUrl, name, role, TeamMemberCard, build, _buildInitialAvatar, _buildProfileAvatar (+18 more)

### Community 51 - "Community 51"
Cohesion: 0.07
Nodes (28): address, categories, displayAddress, distance, fromJson, id, images, isFavorite (+20 more)

### Community 52 - "Community 52"
Cohesion: 0.10
Nodes (20): GlobalKey?, build, _buildAboutSection, _buildAmbientsSection, _buildLocationSection, _buildOpeningHoursSection, _buildSection, _buildSectionShimmer (+12 more)

### Community 53 - "Community 53"
Cohesion: 0.22
Nodes (8): build, centerTitle, onBack, preferredSize, ProfileAppBar, title, PreferredSizeWidget, Size get

### Community 54 - "Community 54"
Cohesion: 0.07
Nodes (27): addressLine1, addressLine2, amount, AppointmentItemModel, AppointmentModel, appointmentStatus, averageRating, bookingDate (+19 more)

### Community 55 - "Community 55"
Cohesion: 0.05
Nodes (35): _ApplyToggle, build, CouponCard, couponCode, disabledReason, discountAmount, discountType, isEnabled (+27 more)

### Community 56 - "Community 56"
Cohesion: 0.18
Nodes (10): copyWithError, copyWithFavoriteToggled, copyWithLoading, copyWithSuccess, errorMessage, initial, isFavorite, isLoading (+2 more)

### Community 57 - "Community 57"
Cohesion: 0.07
Nodes (27): address, build, _buildContent, _buildImageCarousel, _buildSalonInfo, categories, createState, _currentImageIndex (+19 more)

### Community 58 - "Community 58"
Cohesion: 0.19
Nodes (15): SlotBloc, ClearSelectedSlotEvent, date, LoadSlotsEvent, props, salonId, SelectSlotEvent, SlotEvent (+7 more)

### Community 59 - "Community 59"
Cohesion: 0.08
Nodes (25): addressLine1, addressLine2, amount, AppointmentEntity, AppointmentItemEntity, appointmentStatus, averageRating, bookingDate (+17 more)

### Community 60 - "Community 60"
Cohesion: 0.08
Nodes (26): build, HomeProfileAvatar, amount, createState, icon, isDarkMode, isViewWalletButton, item (+18 more)

### Community 61 - "Community 61"
Cohesion: 0.05
Nodes (41): build, _buildIndicator, createState, _currentPage, dispose, initState, _nextPage, _onboardingBackgrounds (+33 more)

### Community 62 - "Community 62"
Cohesion: 0.08
Nodes (25): address, build, _buildContent, _buildImage, _buildRatingAndDistance, categories, createState, distance (+17 more)

### Community 63 - "Community 63"
Cohesion: 0.10
Nodes (20): FlPluginRegistry, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins(), main() (+12 more)

### Community 64 - "Community 64"
Cohesion: 0.12
Nodes (15): fromJson, toJson, AuthRepositoryImpl, appleLogin, AuthRepository, googleLogin, sendOtp, verifyOtp (+7 more)

### Community 65 - "Community 65"
Cohesion: 0.12
Nodes (16): _appointmentsBloc, _bannerPlaceholder, _buildBookingCard, _buildContent, _buildList, createState, dispose, _formatDate (+8 more)

### Community 66 - "Community 66"
Cohesion: 0.05
Nodes (41): ../../helpers/test_fixtures.dart, DeleteProfileUseCase, GetProfileUseCase, LogoutUseCase, UpdateProfileUseCase, Mock, package:bloc_test/bloc_test.dart, package:mocktail/mocktail.dart (+33 more)

### Community 67 - "Community 67"
Cohesion: 0.09
Nodes (22): _area, _city, clearLocation, clearUpdateFlag, _defaultArea, _defaultCity, _defaultLatitude, _defaultLongitude (+14 more)

### Community 68 - "Community 68"
Cohesion: 0.08
Nodes (27): cancelPendingOrder, createOrder, dataSource, networkInfo, OrderRepositoryImpl, verifyPayment, cancelPendingOrder, createOrder (+19 more)

### Community 69 - "Community 69"
Cohesion: 0.06
Nodes (31): bookingDate, bookingFor, couponCode, couponDiscount, couponId, customerEmail, customerName, customerPhone (+23 more)

### Community 70 - "Community 70"
Cohesion: 0.08
Nodes (23): avgRating, bounds, ClusterBoundsEntity, ClusterEntity, clusteringEnabled, clusters, count, hasPremium (+15 more)

### Community 71 - "Community 71"
Cohesion: 0.10
Nodes (20): build, _buildLoginPrompt, buttonText, _checkAuthentication, child, createState, didChangeAppLifecycleState, dispose (+12 more)

### Community 72 - "Community 72"
Cohesion: 0.08
Nodes (23): address, build, _buildImageCarousel, _buildRatingAndDistance, _buildSalonInfo, categories, createState, _currentImageIndex (+15 more)

### Community 73 - "Community 73"
Cohesion: 0.04
Nodes (45): Color, FormFieldValidator, AppleSignInButton, build, isLoading, onPressed, text, build (+37 more)

### Community 74 - "Community 74"
Cohesion: 0.09
Nodes (22): FormState, amountController, amounts, build, capitalizeWords, cleanDateTime, createState, DepositBottomSheet (+14 more)

### Community 75 - "Community 75"
Cohesion: 0.06
Nodes (31): AppTextStyle, BodyTextColors, BodyTextHint, build, color, decoration, decorationColor, fontSize (+23 more)

### Community 76 - "Community 76"
Cohesion: 0.14
Nodes (24): LocationProvider, CategoryBloc, CategoryEvent, categoryId, gender, isLoadMore, latitude, limit (+16 more)

### Community 77 - "Community 77"
Cohesion: 0.07
Nodes (26): id, imageUrl, label, props, CouponModel, code, CouponEntity, discountAmount (+18 more)

### Community 78 - "Community 78"
Cohesion: 0.06
Nodes (44): CustomPainter, CouponBloc, getActiveCouponsUseCase, _mapFailureToMessage, _onGetActiveCoupons, _onRefreshCoupons, CouponEvent, GetActiveCouponsEvent (+36 more)

### Community 79 - "Community 79"
Cohesion: 0.10
Nodes (20): age, city, copyWith, country, dateOfBirth, email, firstname, fullName (+12 more)

### Community 80 - "Community 80"
Cohesion: 0.13
Nodes (14): activeServiceCategoryIndex, build, _buildDiscountSeal, _buildServiceCardWithCallback, _buildServiceGenderIcon, _buildServicesSection, _formatDiscountLabel, isDarkMode (+6 more)

### Community 81 - "Community 81"
Cohesion: 0.11
Nodes (17): bookingData, _buildBottomBar, _buildEmptyState, _buildErrorState, _cachedSlotInterval, createState, _formatTime, _formatTimeRange (+9 more)

### Community 82 - "Community 82"
Cohesion: 0.08
Nodes (23): AddPersonResult, age, _ageCtrl, build, controller, createState, dispose, _formKey (+15 more)

### Community 83 - "Community 83"
Cohesion: 0.29
Nodes (9): ChangeNotifier, ThemeProvider, build, ThemeImageToggle, build, ThemeToggleButton, package:flutter_svg/svg.dart, package:provider/provider.dart (+1 more)

### Community 84 - "Community 84"
Cohesion: 0.22
Nodes (13): _requestProfileIfNeeded, _requestProfileIfNeeded, GetProfileEvent, LogoutEvent, profile, ProfileEvent, props, RefreshProfileEvent (+5 more)

### Community 85 - "Community 85"
Cohesion: 0.06
Nodes (38): getAllAppointments, CategoryRepositoryImpl, dataSource, getCategories, getCategorySalons, networkInfo, CategoryRepository, getCategories (+30 more)

### Community 86 - "Community 86"
Cohesion: 0.10
Nodes (20): carouselBanners, carouselError, copyWith, hasAllData, hasMoreRecommended, isAnyLoading, isCarouselLoading, isLoadingMoreRecommended (+12 more)

### Community 87 - "Community 87"
Cohesion: 0.10
Nodes (20): GenderTab, build, createState, _fetchCategories, initState, _isLoading, _isMenSelected, _mapItems (+12 more)

### Community 88 - "Community 88"
Cohesion: 0.10
Nodes (20): BookingPriceBreakdown, BookingPriceCalculator, couponDiscount, defaultGstPercentage, finalTotal, fromServices, gstAmount, gstPercentage (+12 more)

### Community 89 - "Community 89"
Cohesion: 0.15
Nodes (12): int get, GuestModel, age, gender, GuestEntity, guestId, hashCode, isActive (+4 more)

### Community 90 - "Community 90"
Cohesion: 0.10
Nodes (19): FocusNode?, build, controller, focusNode, hintText, includeOuterPadding, inputAction, inputType (+11 more)

### Community 91 - "Community 91"
Cohesion: 0.20
Nodes (19): CreateOrderRequest, OrderBloc, CreateOrderEvent, OrderEvent, orderId, PaymentFailedEvent, props, RazorpayOpenedEvent (+11 more)

### Community 92 - "Community 92"
Cohesion: 0.10
Nodes (20): addSuccessMessage, copyWithAdding, copyWithAddSuccess, copyWithError, copyWithLoading, copyWithSelectedGuest, copyWithSuccess, copyWithUpdateSuccess (+12 more)

### Community 93 - "Community 93"
Cohesion: 0.07
Nodes (31): favorites, FavoritesListModel, fromJson, message, status, success, toJson, dioClient (+23 more)

### Community 94 - "Community 94"
Cohesion: 0.40
Nodes (5): _navigateToLogin, _navigateToNextScreen, main, RouteNames.login, RouteNames.onboarding

### Community 95 - "Community 95"
Cohesion: 0.10
Nodes (20): addressLine1, addressLine2, city, cretaedAt, district, id, landmark, latitude (+12 more)

### Community 96 - "Community 96"
Cohesion: 0.07
Nodes (27): build, Cancellation, _CancellationContent, _launchWebsite, _WebsiteLinkText, build, Contact, _launchURL (+19 more)

### Community 97 - "Community 97"
Cohesion: 0.18
Nodes (16): ApplyFiltersEvent, categoryId, ClearSearchEvent, gender, latitude, limit, LoadMoreSalonsEvent, LoadNearbySalonsEvent (+8 more)

### Community 98 - "Community 98"
Cohesion: 0.11
Nodes (18): FontWeight?, backgroundColor, borderRadius, build, disabledBackgroundColor, disabledTextColor, fontSize, fontWeight (+10 more)

### Community 99 - "Community 99"
Cohesion: 0.10
Nodes (19): build, _countdownTimer, createState, dispose, initState, _isLoading, _isOtpComplete, _isResending (+11 more)

### Community 100 - "Community 100"
Cohesion: 0.09
Nodes (20): SalonDetailEntity, getSalonDetails, build, _buildCarousel, carouselHeight, currentImageIndex, isDarkMode, isFullyExpanded (+12 more)

### Community 101 - "Community 101"
Cohesion: 0.07
Nodes (27): getCategoriesUseCase, getSalonsUseCase, _mapFailureToMessage, _onLoadCategories, _onLoadCategorySalons, _onRefreshCategories, build, _buildCategory (+19 more)

### Community 102 - "Community 102"
Cohesion: 0.11
Nodes (18): getNearbySalonsUseCase, _lastCategoryId, _lastGender, _lastLatitude, _lastLimit, _lastLongitude, _lastQuery, _mapFailureToMessage (+10 more)

### Community 103 - "Community 103"
Cohesion: 0.14
Nodes (21): SearchBloc, categoryId, copyWith, currentPage, currentSalons, gender, hasMore, isSearchActive (+13 more)

### Community 104 - "Community 104"
Cohesion: 0.11
Nodes (17): build, _countdownTimer, createState, dispose, _formKey, _fullPhoneNumber, _goBackToPhone, _isLoading (+9 more)

### Community 105 - "Community 105"
Cohesion: 0.11
Nodes (17): dataSource, getSalons, networkInfo, SalonRepositoryImpl, SalonRepository, call, category, gender (+9 more)

### Community 106 - "Community 106"
Cohesion: 0.11
Nodes (17): app_links, connectivity_plus, file_selector_macos, firebase_core, firebase_messaging, flutter_local_notifications, flutter_secure_storage_darwin, Foundation (+9 more)

### Community 107 - "Community 107"
Cohesion: 0.20
Nodes (9): AuthSessionManager, handleSessionExpired, _handling, onSessionExpired, SessionExpiredCallback, package:tressy/core/utils/local_storage_service.dart, static bool, static SessionExpiredCallback? (+1 more)

### Community 108 - "Community 108"
Cohesion: 0.12
Nodes (17): DateTime, build, createState, currentMonth, dates, dispose, _generateDates, initState (+9 more)

### Community 109 - "Community 109"
Cohesion: 0.12
Nodes (16): _categoryExtra, extra, _firstNonEmpty, location, navigateFromData, navigateFromMessage, _NotificationRouteKind, NotificationRoutes (+8 more)

### Community 110 - "Community 110"
Cohesion: 0.09
Nodes (22): AppTheme, darkTheme, lightTheme, build, controller, createState, _fetchSimData, _formatPhoneNumber (+14 more)

### Community 111 - "Community 111"
Cohesion: 0.11
Nodes (17): copyWith, copyWithError, copyWithLoading, copyWithPaymentVerified, copyWithReset, copyWithSuccess, copyWithVerifyError, copyWithVerifyingPayment (+9 more)

### Community 112 - "Community 112"
Cohesion: 0.14
Nodes (13): fromJson, toJson, CouponRepositoryImpl, dataSource, getActiveCoupons, networkInfo, CouponRepository, call (+5 more)

### Community 113 - "Community 113"
Cohesion: 0.11
Nodes (17): age, createState, gender, imageUrl, name, onDelete, onEdit, phone (+9 more)

### Community 114 - "Community 114"
Cohesion: 0.18
Nodes (14): Point, Size, wchar_t, Scale(), Create, Destroy, UpdateTheme, Win32Window::Win32Window() (+6 more)

### Community 115 - "Community 115"
Cohesion: 0.15
Nodes (16): AppleCredential, authorizationCode, getAppleCredential, getGoogleCredential, _googleClientId, GoogleCredential, _googleSignIn, identityToken (+8 more)

### Community 116 - "Community 116"
Cohesion: 0.12
Nodes (16): build, couponCode, CouponData, coupons, _CouponsBottomSheet, _CouponsBottomSheetState, createState, discountAmount (+8 more)

### Community 117 - "Community 117"
Cohesion: 0.18
Nodes (10): double?, build, distanceKm, isDarkMode, locationLabel, SalonLocationRow, showDistance, useTwoLines (+2 more)

### Community 118 - "Community 118"
Cohesion: 0.23
Nodes (19): AuthBloc, AppleSignInEvent, AuthEvent, GoogleSignInEvent, otp, phone, props, ResetAuthEvent (+11 more)

### Community 119 - "Community 119"
Cohesion: 0.12
Nodes (16): copyWith, errorMessage, favoritesList, FavoritesListStatus, FavoritesState, FavoritesStatus, isFavorite, lastToggledStoreId (+8 more)

### Community 120 - "Community 120"
Cohesion: 0.11
Nodes (17): address, categories, distance, id, images, imageUrl, isFavorite, isPremium (+9 more)

### Community 121 - "Community 121"
Cohesion: 0.06
Nodes (28): ImageType, ServiceStatus, build, buildServiceChip, createState, deleteOnTap, dummyReviews, formatDateTime (+20 more)

### Community 122 - "Community 122"
Cohesion: 0.25
Nodes (17): ProfileBloc, message, profile, ProfileDeleted, ProfileDeleting, ProfileError, ProfileFailure, ProfileInitial (+9 more)

### Community 123 - "Community 123"
Cohesion: 0.12
Nodes (16): availableSlots, bookedSlots, copyWithError, copyWithLoading, copyWithSelectedSlot, copyWithSuccess, currentDate, currentSalonId (+8 more)

### Community 124 - "Community 124"
Cohesion: 0.12
Nodes (16): address, categories, displayAddress, distance, id, images, isFavorite, isPremium (+8 more)

### Community 125 - "Community 125"
Cohesion: 0.11
Nodes (17): build, _buildCategoryBadges, _buildLanguageBadges, categories, chipFontSize, fallbackCategories, fallbackLanguages, languageCodes (+9 more)

### Community 126 - "Community 126"
Cohesion: 0.15
Nodes (12): dataSource, deleteProfile, getProfile, logout, networkInfo, ProfileRepositoryImpl, updateProfile, ProfileRepository (+4 more)

### Community 127 - "Community 127"
Cohesion: 0.07
Nodes (26): bool isBackButton, isClearButton,, double containerHeight,, build, child, CircleBorderContainer, CircleContainer, createState, height (+18 more)

### Community 128 - "Community 128"
Cohesion: 0.12
Nodes (14): EdgeInsetsGeometry?, build, onSettingsTap, onTap, padding, SearchBarWidget, showBorder, build (+6 more)

### Community 129 - "Community 129"
Cohesion: 0.10
Nodes (18): double activeWidth, inactiveWidth,, CustomDialogues, showCancelDialogue, showLoadingDialogue, showLocationPermissionDialogue, showNotAllowedCancelDialogue, activeColor, borderHeight (+10 more)

### Community 130 - "Community 130"
Cohesion: 0.12
Nodes (15): email, indianPhone, isEmail, isPhone, maxLength, minLength, number, password (+7 more)

### Community 131 - "Community 131"
Cohesion: 0.12
Nodes (15): CarouselBannerModel, fromJson, id, imageUrl, limit, NearbyStoresResponseModel, page, pagination (+7 more)

### Community 132 - "Community 132"
Cohesion: 0.20
Nodes (15): MapMarkersBloc, clusteringEnabled, clusters, MapMarkersEmpty, MapMarkersFailure, MapMarkersInitial, MapMarkersLoaded, MapMarkersLoading (+7 more)

### Community 133 - "Community 133"
Cohesion: 0.22
Nodes (9): appleLogin, AuthRemoteDataSource, AuthRemoteDataSourceImpl, dioClient, googleLogin, _handleDioException, sendOtp, verifyOtp (+1 more)

### Community 134 - "Community 134"
Cohesion: 0.13
Nodes (13): unique_ptr, DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+5 more)

### Community 135 - "Community 135"
Cohesion: 0.13
Nodes (14): dart:convert, _elapsedMs, _formatPayload, _maxBodyChars, onError, onRequest, onResponse, _sanitizeHeaders (+6 more)

### Community 136 - "Community 136"
Cohesion: 0.13
Nodes (14): double get, calculateStarCounts, getUniqueCategories, sectionKeys, serviceCount, setActiveTab, setCollapsed, setImageIndex (+6 more)

### Community 137 - "Community 137"
Cohesion: 0.20
Nodes (9): build, cancelText, CustomAlertDialog, description, onCancel, onSubmit, show, submitText (+1 more)

### Community 138 - "Community 138"
Cohesion: 0.13
Nodes (14): area, areaAndCity, _capLength, city, _cleanSegment, hasArea, hasCity, _isBuildingOrStreet (+6 more)

### Community 139 - "Community 139"
Cohesion: 0.13
Nodes (14): categories, CategoryState, CategoryStatus, copyWith, currentPage, errorMessage, hasMoreSalons, isLoadingMoreSalons (+6 more)

### Community 140 - "Community 140"
Cohesion: 0.15
Nodes (15): Bloc, getSalonDetailsUseCase, _onLoadSalonDetail, _onToggleFavorite, SalonDetailBloc, LoadSalonDetailEvent, props, SalonDetailEvent (+7 more)

### Community 141 - "Community 141"
Cohesion: 0.16
Nodes (12): getSlotStatus, networkInfo, remoteDataSource, SlotRepositoryImpl, getSlotStatus, SlotRepository, call, GetSlotStatusUseCase (+4 more)

### Community 142 - "Community 142"
Cohesion: 0.13
Nodes (13): build, _buildCheckIcon, CouponAppliedDialog, couponCode, discountAmount, onContinue, show, build (+5 more)

### Community 143 - "Community 143"
Cohesion: 0.07
Nodes (25): BorderRadius?, BoxFit, apiCategories, build, CategoryImage, categoryName, _fallbackAsset, fit (+17 more)

### Community 144 - "Community 144"
Cohesion: 0.14
Nodes (13): AppImages, call, cancellation, faq, loginBg, logo, logoDark, noData (+5 more)

### Community 145 - "Community 145"
Cohesion: 0.14
Nodes (13): isDarkMode, isLightMode, _loadThemeMode, setDarkTheme, setLightTheme, setSystemTheme, setThemeMode, _themeKey (+5 more)

### Community 146 - "Community 146"
Cohesion: 0.11
Nodes (17): build, init, initialize, initializeApp, initializeDependencies, initializeLocalNotifications, package:app_links/app_links.dart, package:tressy/core/providers/location_provider.dart (+9 more)

### Community 147 - "Community 147"
Cohesion: 0.20
Nodes (14): RECT, OnCreate, OnDestroy, HWND, Win32Window, child_content_, GetClientArea, OnCreate (+6 more)

### Community 148 - "Community 148"
Cohesion: 0.22
Nodes (8): age, build, gender, isSelected, name, onEdit, onTap, ProfileCard

### Community 149 - "Community 149"
Cohesion: 0.12
Nodes (15): class MockServiceDiscoveryDataSource extends, ../../helpers/widget_test_helpers.dart, ServiceDiscoveryDataSource, ServiceDiscoveryDataSourceImpl, package:flutter_test/flutter_test.dart, package:tressy/core/di/injection_container.dart, package:tressy/core/utils/access_token_migration.dart, package:tressy/features/home/data/datasources/service_discovery_datasource.dart (+7 more)

### Community 150 - "Community 150"
Cohesion: 0.15
Nodes (12): dateFormat, DateFormatter, dateTimeFormat, dayMonthFormat, formatDate, formatDateTime, formatTime, fullDateFormat (+4 more)

### Community 151 - "Community 151"
Cohesion: 0.24
Nodes (9): SendOtpModel, VerifyOtpModel, AuthEntity, message, props, SendOtpEntity, status, token (+1 more)

### Community 152 - "Community 152"
Cohesion: 0.31
Nodes (8): AppointmentsBloc, AppointmentsEvent, LoadAppointmentsEvent, BookingsPage, _BookingsPageState, build, initState, SingleTickerProviderStateMixin

### Community 153 - "Community 153"
Cohesion: 0.17
Nodes (12): categoryId, gender, isPremium, LoadMapMarkersEvent, MapMarkersEvent, northEastLat, northEastLng, props (+4 more)

### Community 154 - "Community 154"
Cohesion: 0.15
Nodes (12): build, controller, CustomSearchField, hintText, inputAction, inputType, isReadOnly, onTap (+4 more)

### Community 155 - "Community 155"
Cohesion: 0.17
Nodes (11): dart:ui, clearCache, _createClusterIcon, createClusterMarkers, createIndividualMarkers, dispose, _getClusterSize, _getClusterSizeRange (+3 more)

### Community 156 - "Community 156"
Cohesion: 0.17
Nodes (12): Equatable, CarouselBannerEntity, HomeState, DeleteProfile, DeleteProfileEntity, AmbientEntity, LocationEntity, ReviewEntity (+4 more)

### Community 157 - "Community 157"
Cohesion: 0.24
Nodes (11): Exception?, ApiException, error, message, NetworkException, NotFoundException, ServerException, statusCode (+3 more)

### Community 158 - "Community 158"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 159 - "Community 159"
Cohesion: 0.17
Nodes (11): authBoxDecoration, borderDecoration, bottomSheetDecoration, containerDecoration, dropDownBoxDecoration, primaryBoxDecorationPurple, primaryCircleDecoration, saloonBoxDecoration (+3 more)

### Community 160 - "Community 160"
Cohesion: 0.17
Nodes (11): appliedCouponCode, BillingSummaryCard, build, _buildRow, couponDiscount, gloupCash, gstPercentage, isPlatformFeeWaived (+3 more)

### Community 161 - "Community 161"
Cohesion: 0.31
Nodes (5): MainActivity, Bundle, FlutterActivity, FlutterEngine, Override

### Community 162 - "Community 162"
Cohesion: 0.22
Nodes (8): gender, isLoadMore, latitude, limit, longitude, page, props, search

### Community 163 - "Community 163"
Cohesion: 0.22
Nodes (8): CustomToast, show, showError, showInfo, showSuccess, showWarning, package:fluttertoast/fluttertoast.dart, package:google_fonts/google_fonts.dart

### Community 164 - "Community 164"
Cohesion: 0.25
Nodes (7): getSlotStatusUseCase, _onClearSelectedSlot, _onLoadSlots, _onSelectSlot, package:tressy/features/slot_booking/domain/usecases/get_slot_status_usecase.dart, package:tressy/features/slot_booking/presentation/bloc/slot_event.dart, package:tressy/features/slot_booking/presentation/bloc/slot_state.dart

### Community 165 - "Community 165"
Cohesion: 0.31
Nodes (10): AuthenticationFailure, AuthorizationFailure, CacheFailure, Failure, message, NetworkFailure, NotFoundFailure, props (+2 more)

### Community 166 - "Community 166"
Cohesion: 0.18
Nodes (10): apiImageFromJson, CategoryImageResolver, defaultAsset, isAssetPath, isSvgAsset, localAssetForCategory, _namesMatch, networkUrlForCategory (+2 more)

### Community 167 - "Community 167"
Cohesion: 0.11
Nodes (27): ReviewConfirmPage, CategoryPage, FavoritesBloc, HomePage, FilterBadges, _FilterBadgesState, MyReviews, _MyReviewsState (+19 more)

### Community 168 - "Community 168"
Cohesion: 0.25
Nodes (7): AddRatingDialogue, reviewController, reviewRating, showAddReviewDialogue, package:tressy/features/widgets/custom_text_field.dart, package:tressy/shared/widgets/primary_button.dart, TextEditingController

### Community 169 - "Community 169"
Cohesion: 0.25
Nodes (7): dart:async, _isUnauthorizedResponse, onError, onRequest, _shouldForceLogout, package:tressy/core/constants/keys.dart, package:tressy/core/network/auth_session_manager.dart

### Community 170 - "Community 170"
Cohesion: 0.18
Nodes (10): all, discountedAmount, fromJson, id, imageUrl, name, searchCategory, ServiceCategoryModel (+2 more)

### Community 171 - "Community 171"
Cohesion: 0.29
Nodes (6): _bookingCardShimmer, bookingListShimmer, BookingsShimmer, _serviceRowShimmer, _shimmerBox, _shimmerPill

### Community 172 - "Community 172"
Cohesion: 0.18
Nodes (10): isEmptyOrNull, isNullOrEmpty, isNumeric, NullableStringExtensions, orDefault, removeWhitespace, StringExtensions, toTitleCase (+2 more)

### Community 173 - "Community 173"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 174 - "Community 174"
Cohesion: 0.29
Nodes (6): build, isCollapsed, isDarkMode, onShare, SalonDetailsActionBar, package:tressy/core/constants/salon_detail_design_tokens.dart

### Community 175 - "Community 175"
Cohesion: 0.33
Nodes (5): getAllAppointmentsUseCase, _onLoadAppointments, package:tressy/features/bookings/domain/usecases/get_all_appointments_usecase.dart, package:tressy/features/bookings/presentation/bloc/appointments_event.dart, package:tressy/features/bookings/presentation/bloc/appointments_state.dart

### Community 176 - "build"
Cohesion: 0.29
Nodes (7): build, Route /login, RouteNames.inviteAndEarn, RouteNames.profile, RouteNames.settings, RouteNames.support, RouteNames.wallet

### Community 177 - "Community 177"
Cohesion: 0.11
Nodes (16): activeReviewFilterIndex, activeServiceCategoryIndex, activeTabIndex, copyWith, currentImageIndex, isCollapsed, props, SalonDetailsPageState (+8 more)

### Community 178 - "Community 178"
Cohesion: 0.14
Nodes (12): dart:io, fromEntity, fromJson, ProfileModel, toFormData, toJson, ProfileEntity, deleteProfile (+4 more)

### Community 179 - "Community 179"
Cohesion: 0.36
Nodes (10): HWND, LPARAM, LRESULT, UINT, WPARAM, EnableFullDpiSupportIfAvailable(), GetHandle, GetThisFromHandle (+2 more)

### Community 181 - "Community 181"
Cohesion: 0.22
Nodes (8): dart:developer, AppLogger, debug, error, info, _tag, warning, static const String

### Community 182 - "Community 182"
Cohesion: 0.22
Nodes (8): cancellationDeadlineMessage, CancellationPolicy, hoursBeforeAppointment, hoursLabel, lessThanBeforeAppointmentTitle, moreThanBeforeAppointmentTitle, static const int, static String get

### Community 183 - "Community 183"
Cohesion: 0.22
Nodes (8): loading, noDataFound, noInternet, sessionManagerInitializeError, Strings, tokenExpired, unauthorized, unauthorizedException

### Community 184 - "Community 184"
Cohesion: 0.22
Nodes (8): capitalize, formatDobDate, formatSingleDate, getShortMonthName, StringExtension, titleCase, toHoursAndMinutes, package:intl/intl.dart

### Community 185 - "Community 185"
Cohesion: 0.22
Nodes (8): _cleanBase, ImageUrlResolver, isAbsoluteUrl, resolveCdnAsset, resolveProfileImage, resolveStoreGallery, resolveStoreImage, resolveTeamMemberImage

### Community 188 - "Community 188"
Cohesion: 0.22
Nodes (9): _buildContent, build, build, _buildSalonList, _buildContent, RouteNames.category, RouteNames.explore, RouteNames.salonDetails (+1 more)

### Community 189 - "Community 189"
Cohesion: 0.25
Nodes (7): FavoriteModel, fromJson, message, status, success, toEntity, toJson

### Community 191 - "Community 191"
Cohesion: 0.25
Nodes (7): build, CustomRatingBar, iconSize, ignoreGestures, isGradient, rating, package:flutter_rating_bar/flutter_rating_bar.dart

### Community 192 - "Community 192"
Cohesion: 0.38
Nodes (5): FlutterAppDelegate, AppDelegate, AppDelegate, Bool, NSApplication

### Community 195 - "Community 195"
Cohesion: 0.25
Nodes (7): AppointmentsState, copyWith, errorMessage, isLoading, past, upcoming, package:tressy/features/bookings/domain/entities/appointment_entity.dart

### Community 196 - "Community 196"
Cohesion: 0.29
Nodes (6): getClusteredMarkersUseCase, _onLoadMapMarkers, package:flutter_bloc/flutter_bloc.dart, package:tressy/features/salon_search/domain/usecases/get_clustered_markers_usecase.dart, package:tressy/features/salon_search/presentation/bloc/map_markers_event.dart, package:tressy/features/salon_search/presentation/bloc/map_markers_state.dart

### Community 198 - "Community 198"
Cohesion: 0.47
Nodes (3): Cocoa, FlutterMacOS, XCTest

### Community 199 - "Community 199"
Cohesion: 0.33
Nodes (5): FlutterPluginRegistry, FlutterViewController, RegisterGeneratedPlugins(), MainFlutterWindow, NSWindow

### Community 200 - "Community 200"
Cohesion: 0.33
Nodes (5): existingSecure, migrateLegacyAccessToken, removeLegacy, true, return

### Community 201 - "Community 201"
Cohesion: 0.33
Nodes (5): CategoryModel, fromJson, toJson, CategoryEntity, package:tressy/core/utils/image_url_resolver.dart

### Community 202 - "Community 202"
Cohesion: 0.13
Nodes (13): bool get, fromJson, SlotModel, toEntity, toJson, hashCode, isAvailable, isBooked (+5 more)

### Community 203 - "Community 203"
Cohesion: 0.20
Nodes (8): android, DefaultFirebaseOptions, ios, package:firebase_core/firebase_core.dart, package:firebase_messaging/firebase_messaging.dart, package:flutter/foundation.dart, static const FirebaseOptions, main

### Community 204 - "Community 204"
Cohesion: 0.50
Nodes (3): Flutter, GoogleMaps, UIKit

### Community 205 - "Community 205"
Cohesion: 0.40
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 206 - "Community 206"
Cohesion: 0.50
Nodes (3): Any, Bool, UIApplication

## Knowledge Gaps
- **3021 isolated node(s):** `GoogleMaps`, `ApiRoutes`, `_logTag`, `baseUrl`, `imageBaseUrl` (+3016 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SearchBloc` connect `Community 103` to `Community 97`, `Community 132`, `Community 102`, `Community 140`, `Community 45`, `Community 19`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `CancelPendingOrderUseCase` connect `Community 48` to `Community 19`, `Community 68`, `Community 12`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Why does `CategoryBloc` connect `Community 76` to `Community 66`, `Community 101`, `Community 41`, `Community 139`, `Community 140`, `Community 146`, `Community 19`, `Community 22`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `GoogleMaps`, `ApiRoutes`, `_logTag` to the rest of the system?**
  _3021 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.0196078431372549 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.023809523809523808 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.03702615339406406 - nodes in this community are weakly interconnected._