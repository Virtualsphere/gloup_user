import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/strings.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';

class ProfilePage extends StatelessWidget {
  static const String userName = 'Muthupandi Murugaiah';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      height: 60, // same height as avatar
                      child: Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgPicture.asset(
                            AppIcons.arrowBack,
                            height: 20.0,
                            width: 20.0,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Personal Profile',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppSizes.fontM,
                              color: AppColors.textSecondary,
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
                BodyTextColors(
                  title: 'Wallet Balance',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: AppColors.white,
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
                    BodyTextColors(
                      title: amount == Strings.loading
                          ? Strings.loading
                          : double.parse(amount).toStringAsFixed(2),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    )
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
                          color: AppColors.background,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: BodyTextColors(
                          title: 'View Wallet',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  )
                } else ...{
                  Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: BodyTextColors(
                      title:
                          'Wallet balance is non-transferable and can be used only for salon bookings.',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.white,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
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
                  color: Colors.grey.shade100,
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
            Icon(
              item.icon,
              size: 24,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: AppSizes.fontM,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
