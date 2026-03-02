import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/shared/widgets/empty_widget.dart';
import 'package:tressy/shared/widgets/error_widget.dart' as custom_error;
import 'package:tressy/shared/widgets/explore_salon_card.dart';
import 'package:tressy/shared/widgets/loading_widget.dart';
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
          backgroundColor: context.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: context.colorScheme.surface,
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
                  InkWell(
                    onTap: () {
                      // Handle settings tap
                    },
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                    child: Container(
                      decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.primaryDark.withValues(alpha: 0.05)
                              : AppColors.primary.withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusS)),
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        AppIcons.icSettings,
                        width: AppSizes.iconS,
                        height: AppSizes.iconS,
                        colorFilter: ColorFilter.mode(
                          isDarkMode
                              ? AppColors.primaryDark
                              : AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              // Loading state
              if (state.listStatus == FavoritesListStatus.loading) {
                return const LoadingWidget();
              }

              // Error state
              if (state.listStatus == FavoritesListStatus.failure) {
                return custom_error.ErrorDisplayWidget(
                  message: state.listErrorMessage ?? 'Failed to load favorites',
                  onRetry: () {
                    context
                        .read<FavoritesBloc>()
                        .add(const LoadFavoritesEvent());
                  },
                );
              }

              // Empty state
              if (state.listStatus == FavoritesListStatus.loaded &&
                  state.favoritesList.isEmpty) {
                return EmptyWidget(
                  icon: Icons.favorite_border,
                  message:
                      'Start adding salons to your favorites to see them here',
                  actionLabel: 'Explore Salons',
                  onAction: () {
                    // Navigate to home or explore
                    context.go(RouteNames.home);
                  },
                );
              }

              // Success state with data
              if (state.listStatus == FavoritesListStatus.loaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<FavoritesBloc>()
                        .add(const LoadFavoritesEvent());
                    // Wait a bit for the refresh
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    itemCount: state.favoritesList.length,
                    itemBuilder: (context, index) {
                      final salon = state.favoritesList[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSizes.paddingM),
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
                          address: salon.address,
                          categories: salon.categories,
                          languageCodes: salon.languageCodes,
                          showDistance: false, // Hide distance in favorites
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
                  ),
                );
              }

              // Initial state
              return const Center(
                child: Text('Loading...'),
              );
            },
          ),
        ),
      ),
    );
  }
}
