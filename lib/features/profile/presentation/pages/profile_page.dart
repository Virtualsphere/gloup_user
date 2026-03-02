import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/strings.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/theme_image_toggle.dart';

class ProfilePage extends StatelessWidget {
  static const String userName = 'Muthupandi Murugaiah';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Scaffold(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 60,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: SvgPicture.asset(
                            AppIcons.arrowBack,
                            height: 20.0,
                            width: 20.0,
                            colorFilter: ColorFilter.mode(
                              isDarkMode ? AppColors.white : AppColors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.displaySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Personal Profile',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.displaySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.fontM,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    // Fixed-size avatar — always visible, never overflows
                    /* Container(
                      height: 72,
                      width: 72,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: CustomNetworkImage(
                        imageUrl: (SessionManager.getProfile() ?? ' '),
                        imageType: ImageType.profilepic,
                        placeHolderHeight: 25,
                      ),
                    ),*/
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingL),

                // ── Wallet Balance Card ────────────────────────────────
                WalletBalanceContainer(
                  amount: '500.00', // Static value
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
                    _MenuItem(
                      icon: Icons.star_border,
                      label: 'My Reviews',
                      onTap: () {
                        context.pushNamed(RouteNames.reviews);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.person_add_alt_1_outlined,
                      label: 'Invite & Earn',
                      onTap: () {
                        context.pushNamed(RouteNames.inviteAndEarn);
                      },
                    ),
                    _MenuItem(
                      icon: null,
                      label: 'Switch Theme',
                      trailing: true,
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () {
                        context.pushNamed(RouteNames.settings);
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
                            // SessionManager.clearSession();
                            // context.read<HomeController>().setIndex(0);
                            context.pushNamed(RouteNames.login);
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
      height: 170,
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
                  style: context.textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w300,
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
                      style: context.textTheme.labelLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                ),
                if (isViewWalletButton) ...{
                  GestureDetector(
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
                          style: context.textTheme.labelLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  )
                } else ...{
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Text(
                      'Wallet balance is non-transferable and can be used only for salon bookings.',
                      style: context.textTheme.labelLarge?.copyWith(
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
                  color: isDarkMode ? AppColors.white : Colors.grey.shade100,
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
                color: isDarkMode
                    ? AppColors.white
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: AppSizes.paddingM),
            ],
            Expanded(
              child: Text(
                item.label,
                style: context.textTheme.displaySmall?.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.textPrimary,
                  fontSize: AppSizes.fontM,
                  fontWeight: FontWeight.w400,
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
