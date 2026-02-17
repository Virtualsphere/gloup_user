import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

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
                    // Expanded ensures the text column takes remaining space
                    // and never pushes the avatar off screen
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A1A1A),
                        Color(0xFF2D1F3D),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Subtle decorative circle (brand mark)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Image.asset(
                          'assets/logos/walletlogo.png',
                          width: 80,
                          height: 80,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(
                              fontSize: AppSizes.fontM,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '₹ 0.00',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Colors.white, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'View Wallet',
                              style: TextStyle(
                                fontSize: AppSizes.fontM,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingL),

                // ── Main Menu Card ─────────────────────────────────────
                _MenuCard(
                  items: const [
                    _MenuItem(icon: Icons.person_outline, label: 'Profile'),
                    _MenuItem(icon: Icons.favorite_border, label: 'Favorites'),
                    _MenuItem(icon: Icons.star_border, label: 'My Reviews'),
                    _MenuItem(
                        icon: Icons.person_add_alt_1_outlined,
                        label: 'Invite & Earn'),
                    _MenuItem(icon: Icons.settings_outlined, label: 'Settings'),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingM),

                // ── Support & Logout Card ──────────────────────────────
                _MenuCard(
                  items: const [
                    _MenuItem(icon: Icons.help_outline, label: 'Support'),
                    _MenuItem(icon: Icons.logout, label: 'Logout'),
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
      onTap: () {},
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

  const _MenuItem({required this.icon, required this.label});
}
