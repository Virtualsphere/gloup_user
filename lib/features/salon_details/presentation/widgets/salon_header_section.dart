import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_state.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_details_shimmers.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SalonHeaderSection extends StatelessWidget {
  final bool isDarkMode;
  final SalonDetailState state;
  final int activeTabIndex;
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;

  const SalonHeaderSection({
    super.key,
    required this.isDarkMode,
    required this.state,
    required this.activeTabIndex,
    required this.tabs,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildInfoSheet(
        context: context, isDarkMode: isDarkMode, state: state);
  }

  Widget _buildInfoSheet({
    required BuildContext context,
    required bool isDarkMode,
    required SalonDetailState state,
  }) {
    final sheetColor = isDarkMode
        ? AppColors.surfaceDark
        : SalonDetailDesignTokens.pageBackground;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(SalonDetailDesignTokens.infoSheetTopRadius),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SalonDetailDesignTokens.infoSheetTopRadius),
          ),
          boxShadow:
              isDarkMode ? null : SalonDetailDesignTokens.infoSheetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: state.isLoading || state.salonDetail == null
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSizes.padding,
                          AppSizes.paddingS,
                          AppSizes.padding,
                          0,
                        ),
                        child: SalonDetailsShimmers.buildHeaderShimmer(
                          context,
                          isDarkMode,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSizes.padding,
                          AppSizes.paddingS,
                          AppSizes.padding,
                          0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndCrownSection(
                              context,
                              isDarkMode,
                              state.salonDetail!,
                            ),
                            const SizedBox(
                              height:
                                  SalonDetailDesignTokens.infoSheetSectionGap,
                            ),
                            _buildInfoSection(
                              context,
                              isDarkMode,
                              state.salonDetail!,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            _buildTabBar(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndCrownSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                salonDetail.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  height: 28 / 18,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF171717),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (salonDetail.isNew)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C8CE9),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    height: 15 / 10,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (salonDetail.isPremium)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFC02E),
                      Color(0xFFC88C00),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_crown.svg',
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            if (salonDetail.isPremium) const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0x1A21C45D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC02E),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    salonDetail.rating.toString(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 16 / 12,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${salonDetail.reviewCount})',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 16 / 12,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildSalonGenderTag(salonDetail.gender, isDarkMode),
          ],
        ),
      ],
    );
  }

  Widget _buildSalonGenderTag(String gender, bool isDarkMode) {
    final normalized = gender.toLowerCase().trim();
    final labelColor =
        isDarkMode ? AppColors.textSecondaryDark : const Color(0xFF727272);

    final List<Widget> icons;
    if (normalized.contains('unisex')) {
      icons = [
        SvgPicture.asset(AppIcons.icMale,
            width: 20, height: 20, fit: BoxFit.fitHeight),
        SvgPicture.asset(AppIcons.icFemale,
            width: 20, height: 20, fit: BoxFit.fitHeight),
      ];
    } else if ((normalized.contains('male') || normalized.contains('men')) &&
        !normalized.contains('women') &&
        !normalized.contains('female')) {
      icons = [
        SvgPicture.asset(AppIcons.icMale,
            width: 20, height: 20, fit: BoxFit.fitHeight),
      ];
    } else if (normalized.contains('women') || normalized.contains('female')) {
      icons = [
        SvgPicture.asset(AppIcons.icFemale,
            width: 20, height: 20, fit: BoxFit.fitHeight),
      ];
    } else {
      icons = [
        Icon(Icons.wc, size: 20, color: labelColor),
      ];
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...icons,
        const SizedBox(width: 4),
        Text(
          gender,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: labelColor,
            height: 24 / 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: SvgPicture.asset(
                'assets/icons/ic_location.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isDarkMode
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF737373),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                salonDetail.address,
                style: GoogleFonts.inter(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF737373),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 20 / 12,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_clock.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF737373),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            if (salonDetail.openingTime.isNotEmpty &&
                salonDetail.closingTime.isNotEmpty) ...[
              Text(
                '${salonDetail.isOpen ? 'Open' : 'Closed'} · ${salonDetail.openingTime} - ${salonDetail.closingTime}',
                style: GoogleFonts.inter(
                  color: salonDetail.isOpen
                      ? const Color(0xFF21C45D)
                      : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
            ] else ...[
              Text(
                'Hours not set',
                style: GoogleFonts.inter(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF737373),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 16 / 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_translate.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF737373),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: salonDetail.languages.isEmpty
                  ? Text(
                      'Language not set',
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF737373),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 20 / 12,
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: salonDetail.languages
                          .map((lang) => _buildLanguageBadge(lang, isDarkMode))
                          .toList(),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageBadge(String language, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFFEDEDED).withValues(alpha: 0.2)
            : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        language,
        style: GoogleFonts.inter(
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : const Color(0xFF737373),
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 15 / 10,
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.surfaceDark
            : SalonDetailDesignTokens.pageBackground,
        border: const Border(
          bottom: BorderSide(
            color: SalonDetailDesignTokens.tabBarDivider,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = activeTabIndex == index;

            return GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? (isDarkMode
                              ? AppColors.primaryDark
                              : AppColors.primary)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? (isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary)
                        : (isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SalonStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  SalonStickyHeaderDelegate({
    required this.child,
    required this.extent,
  });

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: extent,
      width: double.infinity,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SalonStickyHeaderDelegate oldDelegate) {
    return extent != oldDelegate.extent || child != oldDelegate.child;
  }
}
