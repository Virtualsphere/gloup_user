import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/widgets/ambient_card.dart';
import 'package:tressy/features/salon_details/presentation/widgets/location_widget.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_details_shimmers.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SalonDetailsSections extends StatelessWidget {
  final String title;
  final bool isDarkMode;
  final SalonDetailEntity salonDetail;
  final GlobalKey? sectionKey;
  final Widget servicesSection;
  final Widget teamSection;
  final Widget reviewsSection;
  final VoidCallback? onReviewsSeeAll;

  const SalonDetailsSections({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.salonDetail,
    required this.sectionKey,
    required this.servicesSection,
    required this.teamSection,
    required this.reviewsSection,
    this.onReviewsSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSection(context, title, isDarkMode, salonDetail);
  }

  Widget _buildSection(BuildContext context, String title, bool isDarkMode,
      SalonDetailEntity salonDetail) {
    final isServices = title == 'Services';

    return Container(
      key: sectionKey,
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingM,
        isServices ? 12 : AppSizes.paddingM,
        AppSizes.paddingM,
        AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isServices) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : SalonDetailDesignTokens.textPrimary,
                  ),
                ),
                if (title == 'Reviews' && onReviewsSeeAll != null)
                  GestureDetector(
                    onTap: onReviewsSeeAll,
                    child: Text(
                      'See all',
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : SalonDetailDesignTokens.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (title == 'Services')
            servicesSection
          else if (title == 'About')
            _buildAboutSection(context, isDarkMode, salonDetail)
          else if (title == 'Amenities')
            _buildAmbientsSection(context, isDarkMode, salonDetail)
          else if (title == 'Team')
            teamSection
          else if (title == 'Reviews')
            reviewsSection
          else if (title == 'Opening Hours')
            _buildOpeningHoursSection(context, isDarkMode, salonDetail)
          else if (title == 'Location')
            _buildLocationSection(isDarkMode, salonDetail)
          else
            Container(
              height: 500,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.surfaceDark.withValues(alpha: 0.5)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(
                  color: isDarkMode
                      ? AppColors.textSecondary.withValues(alpha: 0.2)
                      : AppColors.textSecondary.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Text(
                  '$title content goes here...\n\n(Add your real content here)',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.about.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
              Text(
                'About information not available',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Text(
      salonDetail.about,
      textAlign: TextAlign.left,
      style: context.textTheme.bodyMedium?.copyWith(
        color:
            isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  Widget _buildAmbientsSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.ambients.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
              Text(
                'No amenities available',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    IconData getIconData(String iconName) {
      switch (iconName) {
        case 'wifi':
          return Icons.wifi;
        case 'ac_unit':
          return Icons.ac_unit;
        case 'local_parking':
          return Icons.local_parking;
        case 'credit_card':
          return Icons.credit_card;
        case 'wheelchair_pickup':
          return Icons.wheelchair_pickup;
        case 'coffee':
          return Icons.coffee;
        default:
          return Icons.check_circle;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - (AppSizes.paddingM * 2)) / 3;

        return Wrap(
          spacing: AppSizes.paddingM,
          runSpacing: AppSizes.paddingM,
          children: salonDetail.ambients.map((ambient) {
            return SizedBox(
              width: cardWidth,
              child: AmbientCard(
                icon: getIconData(ambient.icon),
                label: ambient.label,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLocationSection(bool isDarkMode, SalonDetailEntity salonDetail) {
    return LocationWidget(
      latitude: salonDetail.location.latitude,
      longitude: salonDetail.location.longitude,
      address: salonDetail.location.address,
      salonName: salonDetail.name,
    );
  }

  Widget _buildOpeningHoursSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    final today = DateTime.now().weekday;

    final List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      children: daysOfWeek.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final dayNumber = index + 1;
        final isToday = dayNumber == today;
        final hours = salonDetail.openingHours[day] ?? 'Closed';

        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.paddingS),
          padding: EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.info.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: isToday
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$day ',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Today',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.fontXS,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        day,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
              ),
              Text(
                hours,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildSectionShimmer(
    BuildContext context,
    String title,
    bool isDarkMode,
    GlobalKey? sectionKey,
  ) {
    return Container(
      key: sectionKey,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          AppSizes.heightM,
          if (title == 'Services')
            SalonDetailsShimmers.buildServicesShimmer(context, isDarkMode)
          else if (title == 'About')
            SalonDetailsShimmers.buildAboutShimmer(context, isDarkMode)
          else if (title == 'Amenities')
            SalonDetailsShimmers.buildAmbientsShimmer(context, isDarkMode)
          else if (title == 'Team')
            SalonDetailsShimmers.buildTeamShimmer(context, isDarkMode)
          else if (title == 'Reviews')
            SalonDetailsShimmers.buildReviewsShimmer(context, isDarkMode)
          else if (title == 'Opening Hours')
            SalonDetailsShimmers.buildOpeningHoursShimmer(context, isDarkMode)
          else if (title == 'Location')
            SalonDetailsShimmers.buildLocationShimmer(context, isDarkMode)
          else
            const SizedBox(height: 200),
        ],
      ),
    );
  }

  static List<Widget> buildSectionShimmers({
    required BuildContext context,
    required List<String> tabs,
    required bool isDarkMode,
    required Map<String, GlobalKey> sectionKeys,
  }) {
    return tabs
        .map((tab) => _buildSectionShimmer(
              context,
              tab,
              isDarkMode,
              sectionKeys[tab],
            ))
        .toList();
  }
}
