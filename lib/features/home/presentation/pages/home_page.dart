import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/services/user_location_sync_service.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/home/presentation/bloc/home_bloc.dart';
import 'package:tressy/features/home/presentation/bloc/home_event.dart';
import 'package:tressy/features/home/presentation/bloc/home_state.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';
import 'package:tressy/features/category/presentation/bloc/category_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_state.dart';
import 'package:tressy/features/home/data/datasources/service_discovery_datasource.dart';
import 'package:tressy/features/home/data/models/service_category_model.dart';
import 'package:tressy/features/home/presentation/pages/services_at_49_page.dart';
import 'package:tressy/features/home/presentation/widgets/home_category_grid.dart';
import 'package:tressy/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:tressy/features/home/presentation/widgets/popular_services_rail.dart';
import 'package:tressy/features/home/data/home_gender_store.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';
import 'package:tressy/features/home/domain/entities/home_gender.dart';
import 'package:tressy/features/home/data/datasources/welcome_offer_datasource.dart';
import 'package:tressy/features/home/presentation/widgets/filters_sheet.dart';
import 'package:tressy/features/home/presentation/widgets/welcome_offer_dialog.dart';
import 'package:tressy/features/home/presentation/widgets/home_salon_card.dart';
import 'package:tressy/shared/domain/usecases/get_salons_usecase.dart';
import 'package:tressy/features/home/presentation/widgets/home_sort_sheet.dart';
import 'package:tressy/features/home/presentation/widgets/salon_list_header.dart';
import 'package:tressy/features/home/presentation/widgets/home_header.dart';
import 'package:tressy/features/home/presentation/widgets/home_shimmers.dart';
import 'package:tressy/features/home/presentation/widgets/home_profile_avatar.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/location/presentation/pages/location_page.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/core/services/firebase_notification_service.dart';
import 'package:tressy/shared/widgets/notification_permission_sheet.dart';
import 'package:tressy/shared/widgets/location_required_dialog.dart';
import 'package:tressy/shared/widgets/location_permission_dialog.dart';
import 'package:tressy/shared/widgets/salon_card.dart';
import 'package:tressy/shared/widgets/section_header.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/core/services/review_service.dart';
import 'package:tressy/features/profile/presentation/model/review_data.dart';
import 'package:tressy/features/widgets/add_rating_dialogue.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  /// GPS-off soft prompt (Figma 38) is shown at most once per app session.
  static bool _gpsPromptShownThisSession = false;

  /// Location permission is permanently denied (Figma 39 banner).
  bool _locationBlocked = false;

  /// Re-check location when the user returns from device settings.
  bool _recheckLocationOnResume = false;

  List<ServiceCategoryModel> _popularServiceItems = const [];
  bool _popularServicesLoading = true;
  final ScrollController _scrollController = ScrollController();
  HomeGender _gender = HomeGenderStore.load();
  FilterState _filters = FilterState.empty;
  bool _isLoadingLocation = true;
  bool _profileRequested = false;
  bool _homeDataRequested = false;
  bool _pendingReviewChecked = false;
  LocationProvider? _locationProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadPopularServices();
    _loadCategoriesIfNeeded();
    _getCurrentLocation().whenComplete(() async {
      await _maybeAskNotificationPermission();
      await _maybeShowWelcomeOffer();
    });
    _checkPendingReviews();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<LocationProvider>();
    if (_locationProvider != provider) {
      _locationProvider?.removeListener(_onLocationToastChanged);
      _locationProvider = provider;
      provider.addListener(_onLocationToastChanged);
    }
    _requestProfileIfNeeded();
    _requestHomeDataIfNeeded();
  }

  void _requestHomeDataIfNeeded() {
    final bloc = context.read<HomeBloc>();
    final state = bloc.state;

    final hasData = state.carouselBanners.isNotEmpty ||
        state.popularServices.isNotEmpty ||
        state.topSalons.isNotEmpty ||
        state.recommendedSalons.isNotEmpty;

    if (_homeDataRequested && (hasData || state.isAnyLoading)) return;

    _homeDataRequested = true;
    final locationProvider = context.read<LocationProvider>();
    bloc.add(LoadAllHomeDataEvent(
      latitude: locationProvider.latitude,
      longitude: locationProvider.longitude,
      gender: _gender.apiValue,
      filters: _listFilters,
    ));
  }

  HomeBloc get _homeBloc => context.read<HomeBloc>();

  /// List filters as query params. A gender picked in the Filters sheet
  /// overrides the header tabs for the salon list.
  Map<String, dynamic> get _listFilters => _filters.toRequest();

  Future<void> _openFilters() async {
    final picked = await FiltersSheet.show(
      context,
      initial: _filters,
      countFor: _countSalons,
    );
    if (picked != null) _onFiltersChanged(picked);
  }

  /// Live "Show N salons" count for a draft filter (one-item page).
  Future<int?> _countSalons(FilterState draft) async {
    final location = context.read<LocationProvider>();
    final result = await sl<GetSalonsUseCase>().callPage(GetSalonsParams(
      latitude: location.latitude,
      longitude: location.longitude,
      limit: 1,
      page: 1,
      gender: _gender.apiValue,
      filters: draft.toRequest(),
    ));
    return result.fold((_) => null, (page) => page.totalRecords);
  }

  void _reloadSalonList() {
    final location = context.read<LocationProvider>();
    _homeBloc.add(LoadRecommendedSalonsEvent(
      latitude: location.latitude,
      longitude: location.longitude,
      limit: 10,
      page: 1,
      gender: _gender.apiValue,
      filters: _listFilters,
    ));
  }

  void _onFiltersChanged(FilterState next) {
    if (next == _filters) return;
    setState(() => _filters = next);
    _reloadSalonList();
  }

  Future<void> _openSort() async {
    final picked = await HomeSortSheet.show(context, _filters.sort);
    if (picked != null) _onFiltersChanged(_filters.copyWith(sort: picked));
  }

  Future<void> _refresh() async {
    final location = context.read<LocationProvider>();
    _homeBloc.add(LoadAllHomeDataEvent(
      latitude: location.latitude,
      longitude: location.longitude,
      gender: _gender.apiValue,
      filters: _listFilters,
    ));
    unawaited(_loadPopularServices());
    // Wait for the list to settle so the spinner matches the reload.
    await _homeBloc.stream
        .firstWhere((s) => !s.isAnyLoading)
        .timeout(const Duration(seconds: 10), onTimeout: () => _homeBloc.state);
  }

  /// Both genders map to a `sex` the top-categories API understands.
  String get _servicesSex =>
      _gender.tab == HomeGenderTab.female ? 'female' : 'male';

  void _loadCategoriesIfNeeded() {
    final bloc = context.read<CategoryBloc>();
    if (bloc.state.categories.isEmpty &&
        bloc.state.status != CategoryStatus.loading) {
      bloc.add(const LoadCategoriesEvent());
    }
  }

  Future<void> _loadPopularServices() async {
    final sex = _servicesSex;
    setState(() => _popularServicesLoading = true);
    try {
      final items =
          await sl<ServiceDiscoveryDataSource>().getTopCategories(sex: sex);
      // Ignore a stale response if the gender changed while loading.
      if (!mounted || sex != _servicesSex) return;
      setState(() => _popularServiceItems = items);
    } catch (e) {
      debugPrint('Error fetching popular services: $e');
      if (mounted && sex == _servicesSex) {
        setState(() => _popularServiceItems = const []);
      }
    } finally {
      if (mounted && sex == _servicesSex) {
        setState(() => _popularServicesLoading = false);
      }
    }
  }

  void _openServices({ServiceCategoryModel? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicesAt49Page(
          initialCategory: category?.name ?? 'All',
          categoryId: category?.id,
          sex: _servicesSex,
        ),
      ),
    );
  }

  void _requestProfileIfNeeded() {
    if (!LocalStorageService.isLoggedIn) {
      _profileRequested = false;
      return;
    }

    final profileState = context.read<ProfileBloc>().state;
    final shouldFetch = profileState is ProfileInitial ||
        profileState is ProfileLoggedOut ||
        profileState is ProfileFailure;

    if (_profileRequested && !shouldFetch) return;

    _profileRequested = true;
    context.read<ProfileBloc>().add(const GetProfileEvent());
  }

  Future<void> _checkPendingReviews() async {
    if (_pendingReviewChecked) return;
    if (!LocalStorageService.isLoggedIn) return;
    _pendingReviewChecked = true;

    // Small delay so the home page renders first
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final pending = await ReviewService.fetchPendingReviews();
    if (pending.isEmpty || !mounted) return;

    // Skip appointments the user already dismissed with "Not Now"
    final dismissed =
        LocalStorageService.getDismissedPendingReviewAppointmentIds();
    PendingReview? item;
    for (final p in pending) {
      if (!dismissed.contains(p.appointmentId)) {
        item = p;
        break;
      }
    }
    if (item == null || !mounted) return;

    await AddRatingDialogue().showAddReviewDialogue(
      context: context,
      reviewData: ReviewData(
        storeId: item.storeId,
        storeName: item.storeName,
        rating: 0,
        reviewDescription: '',
      ),
      isEditReview: false,
      onSubmit: (rating, description) async {
        return ReviewService.submitReview(
          storeId: item!.storeId,
          rating: rating,
          description: description,
        );
      },
    );

    if (!mounted) return;

    // After submit or "Not Now" → never prompt again for this booking
    await LocalStorageService.dismissPendingReviewAppointment(
      item.appointmentId,
    );
  }

  void _onLocationToastChanged() {
    if (!mounted) return;
    final provider = _locationProvider;
    if (provider == null ||
        !provider.locationJustUpdated ||
        provider.lastUpdateMessage == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CustomToast.showInfo(context, provider.lastUpdateMessage!);
      provider.clearUpdateFlag();
    });
  }

  Future<void> _setChennaiDefault() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.updateLocation(
      latitude: 13.0827,
      longitude: 80.2707,
      city: 'Chennai',
      area: '',
      silent: true,
    );
    setState(() => _isLoadingLocation = false);
  }

  /// Opens the location picker and applies the picked location, if any.
  Future<void> _openLocationPicker() async {
    final locationProvider = context.read<LocationProvider>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPage()),
    );

    // Update location if user selected one
    if (result != null && result is Map<String, dynamic>) {
      final pickedLat = (result['latitude'] as num).toDouble();
      final pickedLng = (result['longitude'] as num).toDouble();
      await locationProvider.updateLocation(
        latitude: pickedLat,
        longitude: pickedLng,
        city: result['city']?.toString(),
        area: result['area']?.toString(),
      );
      unawaited(
        UserLocationSyncService.instance.reportManual(
          lat: pickedLat,
          lng: pickedLng,
        ),
      );

      if (!mounted) return;

      // Reload home data with new location
      _homeBloc.add(LoadAllHomeDataEvent(
        latitude: locationProvider.latitude,
        longitude: locationProvider.longitude,
        gender: _gender.apiValue,
        filters: _listFilters,
      ));
    }
  }

  /// Key of the salon list header, so "Book a salon" can scroll to it.
  final GlobalKey _salonListKey = GlobalKey();

  static const String _welcomeShownStorageKey = 'welcome_offer_shown';

  /// Welcome gift pop-up (Figma 4-2): signed-in users only, once per offer
  /// window, and never an expired offer.
  Future<void> _maybeShowWelcomeOffer() async {
    if (!mounted || !LocalStorageService.isLoggedIn) return;

    final offer = await sl<WelcomeOfferDataSource>().fetch();
    if (!mounted || offer == null) return;
    if (offer.isExpired(DateTime.now())) return;
    if (LocalStorageService.getString(_welcomeShownStorageKey) ==
        offer.shownKey) {
      return;
    }

    // Record first so a crash or force-quit cannot make it nag.
    await LocalStorageService.setString(
        _welcomeShownStorageKey, offer.shownKey);
    if (!mounted) return;

    await WelcomeOfferDialog.show(
      context,
      offer: offer,
      onBookSalon: _scrollToSalonList,
      onTerms: () => context.pushNamed(RouteNames.termsConditions),
    );
  }

  void _scrollToSalonList() {
    final target = _salonListKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  /// Shows the notification soft prompt once, after the location flow.
  Future<void> _maybeAskNotificationPermission() async {
    if (!mounted) return;
    if (!await FirebaseNotificationService.shouldShowPermissionPrompt()) {
      return;
    }
    if (!mounted) return;
    final allowed = await NotificationPermissionSheet.show(context);
    await FirebaseNotificationService.markPermissionPromptShown();
    if (allowed) {
      await FirebaseNotificationService.requestPermission();
    }
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        debugPrint('Location services are disabled');
        if (!_gpsPromptShownThisSession && mounted) {
          _gpsPromptShownThisSession = true;
          bool turnOn = false;
          bool enterManually = false;
          await LocationPermissionDialog.show(
            context,
            onAllow: () => turnOn = true,
            onDeny: () {},
            onEnterManually: () => enterManually = true,
          );
          if (turnOn) {
            _recheckLocationOnResume = true;
            await Geolocator.openLocationSettings();
          } else if (enterManually && mounted) {
            await _openLocationPicker();
          }
        }
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Show pre-permission dialog once per install
        final dialogShown =
            LocalStorageService.getBool('location_permission_dialog_shown') ??
                false;
        if (!dialogShown) {
          bool userAllowed = false;
          bool enterManually = false;
          if (!mounted) return;
          await LocationPermissionDialog.show(
            context,
            onAllow: () => userAllowed = true,
            onDeny: () => userAllowed = false,
            onEnterManually: () => enterManually = true,
          );
          await LocalStorageService.setBool(
              'location_permission_dialog_shown', true);
          if (!userAllowed) {
            await _setChennaiDefault();
            if (enterManually && mounted) await _openLocationPicker();
            return;
          }
        }

        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _setChennaiDefault();
          debugPrint('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Keep a location the user picked manually; otherwise fall back.
        if (LocalStorageService.getDouble('user_latitude') == null) {
          await _setChennaiDefault();
        } else {
          setState(() => _isLoadingLocation = false);
        }
        if (mounted) setState(() => _locationBlocked = true);
        debugPrint('Location permission denied forever');
        return;
      }

      if (_locationBlocked && mounted) {
        setState(() => _locationBlocked = false);
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint('Got position: ${position.latitude}, ${position.longitude}');

      // Get address from coordinates using reverse geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        debugPrint('Placemarks count: ${placemarks.length}');

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          debugPrint('Locality: ${place.locality}');
          debugPrint('SubLocality: ${place.subLocality}');
          debugPrint('AdministrativeArea: ${place.administrativeArea}');

          final city =
              place.locality ?? place.administrativeArea ?? 'Unknown City';
          final area =
              place.subLocality ?? place.thoroughfare ?? 'Unknown Area';

          // Update LocationProvider - this will save to SharedPreferences and notify all listeners
          // Silent update (no toast) for GPS location
          await locationProvider.updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            city: city,
            area: area,
            silent: true, // Don't show toast for GPS updates
          );
        }
      } catch (e) {
        debugPrint('Error getting address: $e');
        // Keep existing location on error
      }

      setState(() {
        _isLoadingLocation = false;
      });

      // Reload home data with new coordinates
      _homeBloc.add(LoadAllHomeDataEvent(
        latitude: locationProvider.latitude,
        longitude: locationProvider.longitude,
        gender: _gender.apiValue,
        filters: _listFilters,
      ));
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_recheckLocationOnResume || _locationBlocked) {
      _recheckLocationOnResume = false;
      _getCurrentLocation();
    }
  }

  Future<void> _fixBlockedLocation() async {
    final area = context.read<LocationProvider>().area;
    final city = context.read<LocationProvider>().city;
    final place = area.isNotEmpty ? area : city;
    final openSettings = await LocationRequiredDialog.show(
      context,
      type: LocationRequiredDialogType.permissionDeniedForever,
      cancelLabel: place.isNotEmpty ? 'Keep using $place' : null,
    );
    if (openSettings == true) {
      await Geolocator.openAppSettings();
    }
  }

  /// "Location access is blocked" banner (Figma 39).
  Widget _buildLocationBlockedBanner(bool isDarkMode) {
    final provider = context.watch<LocationProvider>();
    final place = provider.area.isNotEmpty ? provider.area : provider.city;
    const amber = Color(0xFFB45309);

    return Padding(
      padding: EdgeInsets.only(top: AppSizes.spaceM),
      child: Material(
        color:
            const Color(0xFFF59E0B).withValues(alpha: isDarkMode ? 0.18 : 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: BorderSide(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          onTap: _fixBlockedLocation,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location access is blocked',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? const Color(0xFFFCD34D) : amber,
                        ),
                      ),
                      if (place.isNotEmpty)
                        Text(
                          'Distances are estimated from $place',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : amber.withValues(alpha: 0.85),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  'Fix',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? const Color(0xFFFCD34D) : amber,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onGenderChanged(HomeGender gender) {
    if (gender == _gender) return;
    final locationProvider = context.read<LocationProvider>();

    setState(() {
      _gender = gender;
    });
    HomeGenderStore.save(gender);
    _loadPopularServices();

    final genderParam = gender.apiValue;

    // Reload popular services with new gender filter
    _homeBloc.add(LoadPopularServicesEvent(
      latitude: locationProvider.latitude,
      longitude: locationProvider.longitude,
      limit: 10, // Set limit to 10 for home screen
      gender: genderParam,
    ));

    // Reload top salons with new gender filter
    _homeBloc.add(LoadTopSalonsEvent(
      latitude: locationProvider.latitude,
      longitude: locationProvider.longitude,
      limit: 10, // Set limit to 10 for home screen
      gender: genderParam,
    ));

    // Also reload recommended salons with new gender filter
    _homeBloc.add(LoadRecommendedSalonsEvent(
      latitude: locationProvider.latitude,
      longitude: locationProvider.longitude,
      limit: 10,
      page: 1, // Reset to page 1 when filter changes
      gender: genderParam,
      isLoadMore: false, // This is a fresh load, not load more
      filters: _listFilters,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationProvider?.removeListener(_onLocationToastChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Infinite scroll for recommended salons
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const double scrollThreshold = 200.0; // Load more when 200px from bottom

    if (maxScroll - currentScroll <= scrollThreshold) {
      final locationProvider = context.read<LocationProvider>();
      _homeBloc.add(LoadRecommendedSalonsEvent(
        latitude: locationProvider.latitude,
        longitude: locationProvider.longitude,
        limit: 10,
        gender: _gender.apiValue,
        isLoadMore: true,
        filters: _listFilters,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOut) {
          _profileRequested = false;
        }
      },
      child: BlocListener<FavoritesBloc, FavoritesState>(
        listener: (context, state) {
          if (state.status == FavoritesStatus.failure &&
              state.lastToggledStoreId != null) {
            CustomToast.showError(
                context, 'Failed to update favorite. Please try again.');
          }
        },
        child: Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.backgroundDark : AppColors.background,
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header: location, wallet, search, gender
                    SliverToBoxAdapter(
                      child: BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, profileState) {
                          final wallet = LocalStorageService.isLoggedIn
                              ? HomeHeader.formatWallet(
                                  switch (profileState) {
                                    ProfileLoaded(:final profile) =>
                                      profile.wallet,
                                    ProfileUpdating(:final profile) =>
                                      profile.wallet,
                                    ProfileUpdateSuccess(:final profile) =>
                                      profile.wallet,
                                    ProfileUpdateFailure(:final profile) =>
                                      profile.wallet,
                                    _ => null,
                                  },
                                )
                              : null;
                          return Consumer<LocationProvider>(
                            builder: (context, locationProvider, _) {
                              final area = locationProvider.area.trim();
                              final city = locationProvider.city.trim();
                              return HomeHeader(
                                title: area.isNotEmpty ? area : city,
                                subtitle: area.isNotEmpty && city.isNotEmpty
                                    ? (_locationBlocked
                                        ? '$city (set manually)'
                                        : city)
                                    : '',
                                isLoadingLocation: _isLoadingLocation,
                                onLocationTap: _openLocationPicker,
                                walletLabel: wallet,
                                onWalletTap: () =>
                                    context.pushNamed(RouteNames.wallet),
                                avatar: const HomeProfileAvatar(),
                                onSearchTap: () => GoRouter.of(context)
                                    .push(RouteNames.salonSearch),
                                gender: _gender,
                                onGenderChanged: _onGenderChanged,
                                banner: _locationBlocked
                                    ? _buildLocationBlockedBanner(isDarkMode)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Hero banner carousel
                    SliverToBoxAdapter(
                      child: HomeHeroBanner(
                        banners: state.carouselBanners,
                        isLoading: state.isCarouselLoading,
                      ),
                    ),

                    // "What are you looking for?" category grid
                    SliverToBoxAdapter(
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, categoryState) => HomeCategoryGrid(
                          categories: categoryState.categories,
                          isLoading:
                              categoryState.status == CategoryStatus.loading,
                          error: categoryState.errorMessage,
                          onRetry: () => context
                              .read<CategoryBloc>()
                              .add(const LoadCategoriesEvent()),
                          onSeeAll: () => context.go(RouteNames.explore),
                          onCategoryTap: (category, index) {
                            GoRouter.of(context).push(
                              RouteNames.category,
                              extra: {
                                'categoryName': category.label,
                                'categoryIndex': index + 1,
                                'categoryId': category.id,
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Popular services nearby (price + struck-through MRP)
                    SliverToBoxAdapter(
                      child: PopularServicesRail(
                        services: _popularServiceItems,
                        isLoading: _popularServicesLoading,
                        onSeeAll: _openServices,
                        onServiceTap: (service) =>
                            _openServices(category: service),
                      ),
                    ),

                    SliverToBoxAdapter(child: AppSizes.heightM),

                    // Popular Services Nearby Section Header
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Salons Nearby',
                        subtitle: 'Based on your location',
                        onSeeAllTap: () {
                          // Navigate to Explore tab
                          context.go(RouteNames.explore);
                        },
                      ),
                    ),

                    SliverToBoxAdapter(child: AppSizes.heightM),

                    // Horizontal Scrollable Salon Cards - Popular Services
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: SalonCard.horizontalListExtent,
                        child: state.isPopularServicesLoading
                            ? HomeShimmers.buildSalonCardsShimmer(context)
                            : state.popularServices.isEmpty
                                ? const Center(
                                    child: Text('No popular services found'))
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingM),
                                    itemCount: state.popularServices.length,
                                    itemBuilder: (context, index) {
                                      final salon =
                                          state.popularServices[index];
                                      return SalonCard(
                                        storeId: int.tryParse(salon.id) ?? 0,
                                        salonName: salon.salonName,
                                        salonImage: salon.salonImage,
                                        images: salon.images,
                                        rating: salon.rating,
                                        reviewCount: salon.reviewCount,
                                        distance: salon.distance,
                                        isPremium: salon.isPremium,
                                        isFavorite: salon.isFavorite,
                                        serviceName: salon.serviceName,
                                        servicePrice: salon.servicePrice,
                                        dynamicServices: salon.dynamicServices,
                                        address: salon.displayAddress,
                                        categories: salon.categories,
                                        languageCodes: salon.languageCodes,
                                        onTap: () {
                                          GoRouter.of(context).push(
                                            RouteNames.salonDetails,
                                            extra: {
                                              'salonId': salon.id,
                                              'salonName': salon.salonName,
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ),

                    // Content spacing
                    SliverToBoxAdapter(child: AppSizes.heightL),

                    // Top Salons Section Header
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Top Salons',
                        subtitle: 'Highest rated salons in your area',
                        onSeeAllTap: () {
                          // Navigate to see all top salons
                          context.go(RouteNames.explore);
                        },
                      ),
                    ),

                    SliverToBoxAdapter(child: AppSizes.heightS),
                    // Horizontal Scrollable Salon Cards - Top Salons
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: SalonCard.horizontalListExtent,
                        child: state.isTopSalonsLoading
                            ? HomeShimmers.buildSalonCardsShimmer(context)
                            : state.topSalons.isEmpty
                                ? const Center(
                                    child: Text('No top salons found'))
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingM),
                                    itemCount: state.topSalons.length,
                                    itemBuilder: (context, index) {
                                      final salon = state.topSalons[index];
                                      return SalonCard(
                                        storeId: int.tryParse(salon.id) ?? 0,
                                        salonName: salon.salonName,
                                        salonImage: salon.salonImage,
                                        images: salon.images,
                                        rating: salon.rating,
                                        reviewCount: salon.reviewCount,
                                        distance: salon.distance,
                                        isPremium: salon.isPremium,
                                        isFavorite: salon.isFavorite,
                                        serviceName: salon.serviceName,
                                        servicePrice: salon.servicePrice,
                                        dynamicServices: salon.dynamicServices,
                                        address: salon.displayAddress,
                                        categories: salon.categories,
                                        languageCodes: salon.languageCodes,
                                        onTap: () {
                                          GoRouter.of(context).push(
                                            RouteNames.salonDetails,
                                            extra: {
                                              'salonId': salon.id,
                                              'salonName': salon.salonName,
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ),

                    // Bottom spacing
                    SliverToBoxAdapter(child: AppSizes.heightXXL),

                    // "N salons around you" with filter chips
                    SliverToBoxAdapter(
                      child: SalonListHeader(
                        key: _salonListKey,
                        totalRecords: state.recommendedTotalRecords,
                        filters: _filters,
                        onChanged: _onFiltersChanged,
                        onSortTap: _openSort,
                        onFiltersTap: _openFilters,
                      ),
                    ),

                    SliverToBoxAdapter(child: AppSizes.heightS),

                    // Vertical Full-Width Salon Cards with infinite scroll
                    state.isRecommendedSalonsLoading &&
                            state.recommendedSalons.isEmpty
                        ? SliverPadding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingM),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: EdgeInsets.only(
                                      bottom: AppSizes.paddingM),
                                  child: HomeShimmers
                                      .buildVerticalSalonCardShimmer(context),
                                ),
                                childCount: 3,
                              ),
                            ),
                          )
                        : state.recommendedSalons.isEmpty
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSizes.paddingXL),
                                  child: Center(
                                    child: Text(
                                      _filters.activeCount > 0 ||
                                              _filters.sort !=
                                                  SalonSort.relevance
                                          ? 'No salons match these filters'
                                          : 'No salons found nearby',
                                    ),
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingM),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final salon =
                                          state.recommendedSalons[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: AppSizes.paddingM),
                                        child: HomeSalonCard(
                                          salon: salon,
                                          onTap: () {
                                            GoRouter.of(context).push(
                                              RouteNames.salonDetails,
                                              extra: {
                                                'salonId': salon.id,
                                                'salonName': salon.salonName,
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    childCount: state.recommendedSalons.length,
                                  ),
                                ),
                              ),

                    // Loading indicator for infinite scroll
                    if (state.isLoadingMoreRecommended)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.paddingM),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Bottom spacing
                    SliverToBoxAdapter(child: AppSizes.heightXXL),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
