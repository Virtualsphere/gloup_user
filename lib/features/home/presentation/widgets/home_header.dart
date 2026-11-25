import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/home/domain/entities/home_gender.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Top of the Home screen (Figma 3-2): location pill, wallet chip, avatar,
/// search with the UNI SEX switch, and the Male / Female tabs.
class HomeHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLoadingLocation;
  final VoidCallback onLocationTap;

  /// Formatted wallet amount, e.g. "₹250". Null hides the chip (guests).
  final String? walletLabel;
  final VoidCallback? onWalletTap;

  /// Profile avatar, kept as a slot so the header stays free of bloc wiring.
  final Widget avatar;

  final VoidCallback onSearchTap;
  final HomeGender gender;
  final ValueChanged<HomeGender> onGenderChanged;

  /// Extra row under the location line, e.g. the "location blocked" banner.
  final Widget? banner;

  const HomeHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isLoadingLocation,
    required this.onLocationTap,
    required this.avatar,
    required this.onSearchTap,
    required this.gender,
    required this.onGenderChanged,
    this.walletLabel,
    this.onWalletTap,
    this.banner,
  });

  /// "250.00" -> "₹250", "99.5" -> "₹99.50". Null for missing or invalid input.
  static String? formatWallet(String? raw) {
    final value = double.tryParse(raw?.trim() ?? '');
    if (value == null) return null;
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '₹$text';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      color: isDark ? AppColors.surfaceDark : HomeDesignTokens.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            HomeDesignTokens.screenGutter,
            8.h,
            HomeDesignTokens.screenGutter,
            12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _LocationPill(
                      title: title,
                      subtitle: subtitle,
                      isLoading: isLoadingLocation,
                      onTap: onLocationTap,
                    ),
                  ),
                  if (walletLabel != null) ...[
                    _WalletChip(label: walletLabel!, onTap: onWalletTap),
                    SizedBox(width: 10.w),
                  ],
                  avatar,
                ],
              ),
              if (banner != null) banner!,
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _SearchField(onTap: onSearchTap)),
                  SizedBox(width: 10.w),
                  _UniSexSwitch(
                    value: gender.includeUnisex,
                    onChanged: (v) =>
                        onGenderChanged(gender.copyWith(includeUnisex: v)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _GenderTabs(
                selected: gender.tab,
                onChanged: (t) => onGenderChanged(gender.copyWith(tab: t)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  const _LocationPill({
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary =
        isDark ? AppColors.textPrimaryDark : HomeDesignTokens.textPrimary;
    final secondary =
        isDark ? AppColors.textSecondaryDark : HomeDesignTokens.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20.w, color: primary),
            SizedBox(width: 6.w),
            Expanded(
              child: isLoading
                  ? Text(
                      'Getting location...',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: secondary,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18.w, color: primary),
                          ],
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: secondary,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _WalletChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color =
        isDark ? AppColors.textPrimaryDark : HomeDesignTokens.textPrimary;
    return Semantics(
      button: true,
      label: 'Wallet balance $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeDesignTokens.chipRadius.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeDesignTokens.chipRadius.r),
            border: Border.all(
              color: isDark ? AppColors.borderDark : HomeDesignTokens.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 16.w, color: color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchField({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hint = isDark ? AppColors.textHintDark : HomeDesignTokens.textHint;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : HomeDesignTokens.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? AppColors.borderDark : HomeDesignTokens.border,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 20.w, color: hint),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Search "hair spa"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 14.sp, color: hint),
              ),
            ),
            Icon(Icons.mic_none_rounded, size: 20.w, color: hint),
          ],
        ),
      ),
    );
  }
}

class _UniSexSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _UniSexSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color =
        isDark ? AppColors.textPrimaryDark : HomeDesignTokens.textPrimary;
    return Semantics(
      label: 'Include unisex salons',
      toggled: value,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'UNI\nSEX',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 8.sp,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 20.h,
            child: FittedBox(
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: HomeDesignTokens.surface,
                activeTrackColor: HomeDesignTokens.accentBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderTabs extends StatelessWidget {
  final HomeGenderTab selected;
  final ValueChanged<HomeGenderTab> onChanged;

  const _GenderTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      height: 40.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.backgroundDark : HomeDesignTokens.pageBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _tab(context, HomeGenderTab.male, 'Male', Icons.male_rounded),
          _tab(context, HomeGenderTab.female, 'Female', Icons.female_rounded),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    HomeGenderTab tab,
    String label,
    IconData icon,
  ) {
    final isDark = context.isDarkMode;
    final isSelected = tab == selected;
    final color = isSelected
        ? (isDark ? AppColors.textPrimaryDark : HomeDesignTokens.textPrimary)
        : (isDark
            ? AppColors.textSecondaryDark
            : HomeDesignTokens.textSecondary);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.surfaceDark : HomeDesignTokens.surface)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              border: isSelected
                  ? Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : HomeDesignTokens.border,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16.w, color: color),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
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
