import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/favorites/favorites_feature_flags.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/features/favorites/presentation/widgets/favorite_salon_card.dart';
import 'package:tressy/features/favorites/presentation/widgets/favorites_shimmers.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/login_required_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  /// Salons whose heart was tapped; hidden locally until the list reloads,
  /// so the card can animate out and be restored by Undo.
  final Set<String> _removedIds = {};

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

  void _remove(String id, String name) {
    final storeId = int.tryParse(id) ?? 0;
    setState(() => _removedIds.add(id));
    context.read<FavoritesBloc>().add(ToggleFavoriteEvent(storeId, true));

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed $name'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _undo(id),
        ),
      ));
  }

  void _undo(String id) {
    if (!mounted) return;
    final storeId = int.tryParse(id) ?? 0;
    setState(() => _removedIds.remove(id));
    // Toggling again re-adds the favourite.
    context.read<FavoritesBloc>().add(ToggleFavoriteEvent(storeId, false));
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
          return current.status == FavoritesStatus.success &&
              previous.status != current.status;
        },
        listener: (context, state) {
          // Reload favorites after a successful toggle (no toast)
          context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
        },
        child: BlocListener<FavoritesBloc, FavoritesState>(
          listenWhen: (a, b) => a.favoritesList != b.favoritesList,
          listener: (context, state) {
            // A reload dropped the removed salons; forget them so a later
            // re-favourite is not hidden.
            final ids = state.favoritesList.map((s) => s.id).toSet();
            _removedIds.retainWhere(ids.contains);
          },
          child: Scaffold(
            backgroundColor:
                isDarkMode ? AppColors.backgroundDark : AppColors.background,
            body: SafeArea(
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  final visible = state.favoritesList
                      .where((s) => !_removedIds.contains(s.id))
                      .toList();
                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<FavoritesBloc>()
                          .add(const LoadFavoritesEvent());
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _Header(
                            savedCount: visible.length,
                            showCount:
                                state.listStatus == FavoritesListStatus.loaded,
                          ),
                        ),
                        if (FavoritesFeatureFlags.servicesTab)
                          SliverToBoxAdapter(
                            child: _Tabs(salonCount: visible.length),
                          ),
                        if (state.listStatus == FavoritesListStatus.loading &&
                            state.favoritesList.isEmpty)
                          SliverToBoxAdapter(
                            child: FavoritesShimmers.favoritesSalonListShimmer(
                                context),
                          ),
                        if (state.listStatus == FavoritesListStatus.failure)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _Message(
                              key: const Key('favorites_error'),
                              icon: Icons.error_outline,
                              title: state.listErrorMessage ??
                                  'Failed to load favorites',
                              actionLabel: 'Retry',
                              onAction: () => context
                                  .read<FavoritesBloc>()
                                  .add(const LoadFavoritesEvent()),
                            ),
                          ),
                        if (state.listStatus == FavoritesListStatus.loaded &&
                            visible.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _Message(
                              key: const Key('favorites_empty'),
                              icon: Icons.favorite_border,
                              title: 'No favorites yet',
                              subtitle:
                                  'Tap the heart on a salon to save it here',
                              actionLabel: 'Explore salons',
                              onAction: () => context.go(RouteNames.home),
                            ),
                          ),
                        if (state.favoritesList.isNotEmpty &&
                            state.listStatus != FavoritesListStatus.failure)
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: HomeDesignTokens.screenGutter,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final salon = state.favoritesList[index];
                                  return FavoriteSalonCard(
                                    key: ValueKey('fav_${salon.id}'),
                                    salon: salon,
                                    removed: _removedIds.contains(salon.id),
                                    onRemove: () =>
                                        _remove(salon.id, salon.salonName),
                                    onTap: () => GoRouter.of(context).push(
                                      RouteNames.salonDetails,
                                      extra: {
                                        'salonId': salon.id,
                                        'salonName': salon.salonName,
                                      },
                                    ),
                                  );
                                },
                                childCount: state.favoritesList.length,
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(
                            child: SizedBox(height: AppSizes.spaceXXL)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int savedCount;
  final bool showCount;

  const _Header({required this.savedCount, required this.showCount});

  /// "8 saved"
  static String savedLabel(int n) => '$n saved';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        HomeDesignTokens.screenGutter,
        16,
        HomeDesignTokens.screenGutter,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorites',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: HomeDesignTokens.textPrimary,
            ),
          ),
          if (showCount)
            Text(
              savedLabel(savedCount),
              key: const Key('favorites_saved'),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: HomeDesignTokens.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Salons / Services tabs. Only built while the Services flag is on.
class _Tabs extends StatelessWidget {
  final int salonCount;

  const _Tabs({required this.salonCount});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool selected) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? HomeDesignTokens.textPrimary
                  : HomeDesignTokens.textHint,
            ),
          ),
        );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: HomeDesignTokens.screenGutter,
        vertical: 8,
      ),
      child: Row(
        children: [
          tab('Salons · $salonCount', true),
          tab('Services · 0', false),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _Message({
    super.key,
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 64,
                color: context.colorScheme.onSurface.withValues(alpha: 0.3)),
            SizedBox(height: AppSizes.spaceM),
            Text(title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium),
            if (subtitle != null) ...[
              SizedBox(height: AppSizes.spaceS),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            SizedBox(height: AppSizes.spaceL),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
