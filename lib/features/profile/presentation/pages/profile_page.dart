import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/strings.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/login_required_widget.dart';
import 'package:tressy/shared/widgets/theme_image_toggle.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return LoginRequiredWidget(
      title: 'Login to View Profile',
      message:
          'Please login to see your profile details, wallet balance, and personalized features.',
      showBrowseAsGuest: false,
      child: BlocProvider(
        create: (context) => sl<ProfileBloc>()..add(const GetProfileEvent()),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // Show loading shimmer
            if (state is ProfileLoading) {
              return Scaffold(
                appBar: ProfileAppBar(title: 'Personal Profile', centerTitle: false),
                body: _ProfilePageShimmer(isDarkMode: isDarkMode),
              );
            }

            // Get profile data from state
            final profile = state is ProfileLoaded ? state.profile : null;
            final userName = profile?.fullName ?? 'Guest User';
            final walletAmount = profile?.wallet ?? '0.00';
            final profilePicUrl = profile?.fullProfilePicUrl ?? '';

            return Scaffold(
        appBar: ProfileAppBar(title: 'Personal Profile',centerTitle: false,),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: Name + Avatar ──────────────────────────────
                  Container(
                    padding: EdgeInsets.only(left: 16.0,right: 16.0,top: 10.0,bottom: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: isDarkMode ? AppColors.black : AppColors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurface,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Personal Profile',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurface,
                                  fontSize: AppSizes.fontM,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        // Profile Avatar
                        Container(
                          height: 50,
                          width: 50,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(shape: BoxShape.circle),
                          child: profilePicUrl.isNotEmpty
                              ? CustomNetworkImage(
                                  imageUrl: profilePicUrl,
                                  imageType: ImageType.profilepic,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingL),

                  // ── Wallet Balance Card ────────────────────────────────
                  WalletBalanceContainer(
                    amount: walletAmount,
                    isViewWalletButton: true,
                    viewWalletOnTap: () {
                      context.pushNamed(RouteNames.wallet);
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                  // ── Main Menu Card ─────────────────────────────────────
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        onTap: () {
                          context.pushNamed(RouteNames.profile);
                        },
                      ),
                     /* _MenuItem(
                        icon: Icons.star_border,
                        label: 'My Reviews',
                        onTap: () {
                          context.pushNamed(RouteNames.reviews);
                        },
                      ),*/
                      _MenuItem(
                        icon: Icons.person_add_alt_1_outlined,
                        label: 'Invite & Earn',
                        onTap: () {
                          context.pushNamed(RouteNames.inviteAndEarn);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.color_lens_outlined,
                        label: 'Switch Theme',
                        trailing: true,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          context.pushNamed(RouteNames.settings, extra: profile);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // ── Support & Logout Card ──────────────────────────────
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline,
                        label: 'Support',
                        onTap: () {
                          context.pushNamed(RouteNames.support);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.logout,
                        label: 'Logout',
                        onTap: () {
                          CustomDialogues.showCancelDialogue(
                            context,
                            title: 'Logout',
                            submitOnTap: () async {
                              // Clear all user data
                              await LocalStorageService.clearAll();

                              // Set onboarding as completed so it doesn't show again
                              await LocalStorageService.setOnboardingCompleted(true);

                              // Pop the dialog first
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              // Navigate to login page and clear stack
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.paddingL),
                ],
              ),
            ),
          ),
        ),
      );
          },
        ),
      ),
    );
  }
}

// ── Wallet Balance Card ──────────────────────────────────────────────────────

class WalletBalanceContainer extends StatelessWidget {
  const WalletBalanceContainer({
    super.key,
    required this.amount,
    this.viewWalletOnTap,
    this.isViewWalletButton = false,
  });

  final String amount;
  final VoidCallback? viewWalletOnTap;
  final bool isViewWalletButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppIcons.walletBg,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 10,
            right: 15,
            child: Image.asset(AppIcons.gloUpBg),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Wallet Balance',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontSize: 16.0,
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.rupee,
                      height: 32,
                      width: 32,
                      colorFilter: ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      amount == Strings.loading
                          ? Strings.loading
                          : double.parse(amount).toStringAsFixed(2),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                ),
                if (isViewWalletButton) ...{
                  /*GestureDetector(
                    onTap: viewWalletOnTap,
                    child: Container(
                      height: 32,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: AppColors.white,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'View Wallet',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  )*/
                } else ...{
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Text(
                      'Wallet balance is non-transferable and can be used only for salon bookings.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 14.0,
                      ),
                    ),
                  )
                }
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable card wrapper ──────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(16.0)),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              _MenuTile(item: item),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                  indent: 56,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Reusable menu tile ─────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: 18,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 24,
                color: isDarkMode ? AppColors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: AppSizes.paddingM),
            ],
            Expanded(
              child: Text(
                item.label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.textPrimary,
                  fontSize: AppSizes.font,
                ),
              ),
            ),
            if (item.trailing == true) ThemeImageToggle(),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _MenuItem {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final bool? trailing;

  const _MenuItem({
    this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
}

// ── Profile Page Shimmer ─────────────────────────────────────────────────────
class _ProfilePageShimmer extends StatelessWidget {
  final bool isDarkMode;

  const _ProfilePageShimmer({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingL,
          ),
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
            highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header shimmer
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: isDarkMode ? AppColors.black : AppColors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Wallet shimmer
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Menu items shimmer
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkMode ? AppColors.black : AppColors.white,
                  ),
                  child: Column(
                    children: List.generate(5, (index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingL,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingM),
                                Container(
                                  width: 120,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index < 4)
                            Divider(
                              height: 1,
                              color: isDarkMode ? AppColors.borderDark : AppColors.divider,
                            ),
                        ],
                      );
                    }),
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // Support & Logout shimmer
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkMode ? AppColors.black : AppColors.white,
                  ),
                  child: Column(
                    children: List.generate(2, (index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingL,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingM),
                                Container(
                                  width: 100,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index < 1)
                            Divider(
                              height: 1,
                              color: isDarkMode ? AppColors.borderDark : AppColors.divider,
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
