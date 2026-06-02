import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/favorites/presentation/widgets/favorites_shimmers.dart';
import 'package:tressy/shared/widgets/explore_salon_card.dart';
import 'package:tressy/shared/widgets/login_required_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    _loadFavoritesIfAuthenticated();
  }

  void _loadFavoritesIfAuthenticated() {
    final isAuthenticated = LocalStorageService.accessToken != null &&
        LocalStorageService.accessToken!.isNotEmpty;

    if (isAuthenticated) {
      context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return LoginRequiredWidget(
      title: 'Login to View Favorites',
      message: 'Please login to save and view your favorite salons.',
      showBrowseAsGuest: false,
      onLoginSuccess: () {
        context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
      },
      child: BlocListener<FavoritesBloc, FavoritesState>(
        listenWhen: (previous, current) {
          // Only listen for status changes to reload list
          return current.status == FavoritesStatus.success &&
              previous.status != current.status;
        },
        listener: (context, state) {
          // Reload favorites after successful toggle (no toast)
          if (state.status == FavoritesStatus.success) {
            context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
          }
        },
        child: Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.backgroundDark : AppColors.background,
          appBar: AppBar(
            backgroundColor:
                isDarkMode ? AppColors.backgroundDark : AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: AppSizes.appBarHeight,
            shape: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: AppSizes.borderWidthThin,
              ),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/ic_search.svg',
                    width: AppSizes.iconS,
                    height: AppSizes.iconS,
                    colorFilter: ColorFilter.mode(
                      isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search favorites...',
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppColors.textHintDark
                              : AppColors.textHint,
                          fontSize: AppSizes.fontS,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
                  // Wait a bit for the refresh
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppSizes.spaceL)),

                    // Section Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Favorites',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Your collection of favorite salons',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppSizes.spaceL)),

                    // Loading state - Show shimmer
                    if (state.listStatus == FavoritesListStatus.loading)
                      SliverToBoxAdapter(
                        child: FavoritesShimmers.favoritesSalonListShimmer(
                            context),
                      ),

                    // Error state
                    if (state.listStatus == FavoritesListStatus.failure)
                      SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingL),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: context.colorScheme.error,
                                ),
                                const SizedBox(height: AppSizes.spaceM),
                                Text(
                                  state.listErrorMessage ??
                                      'Failed to load favorites',
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: AppSizes.spaceM),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<FavoritesBloc>()
                                        .add(const LoadFavoritesEvent());
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Empty state
                    if (state.listStatus == FavoritesListStatus.loaded &&
                        state.favoritesList.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingL),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 64,
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: AppSizes.spaceM),
                                Text(
                                  'No favorites yet',
                                  style: context.textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSizes.spaceS),
                                Text(
                                  'Start adding salons to your favorites to see them here',
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.spaceL),
                                ElevatedButton(
                                  onPressed: () {
                                    context.go(RouteNames.home);
                                  },
                                  child: const Text('Explore Salons'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Favorites List
                    if (state.listStatus == FavoritesListStatus.loaded &&
                        state.favoritesList.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingL),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final salon = state.favoritesList[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSizes.paddingM),
                                child: ExploreSalonCard(
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
                                  address: salon.displayAddress,
                                  categories: salon.categories,
                                  languageCodes: salon.languageCodes,
                                  showDistance: false,
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
                            childCount: state.favoritesList.length,
                          ),
                        ),
                      ),

                    // Bottom spacing
                    const SliverToBoxAdapter(
                        child: SizedBox(height: AppSizes.spaceXXL)),
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
