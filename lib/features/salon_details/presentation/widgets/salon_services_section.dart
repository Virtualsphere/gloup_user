import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/cubit/salon_details_page_cubit.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SalonServicesSection extends StatelessWidget {
  final bool isDarkMode;
  final SalonDetailEntity salonDetail;
  final Map<int, ServiceEntity> selectedServices;
  final int activeServiceCategoryIndex;
  final ValueChanged<int> onServiceCategoryChanged;
  final ValueChanged<ServiceEntity> onToggleService;

  const SalonServicesSection({
    super.key,
    required this.isDarkMode,
    required this.salonDetail,
    required this.selectedServices,
    required this.activeServiceCategoryIndex,
    required this.onServiceCategoryChanged,
    required this.onToggleService,
  });

  @override
  Widget build(BuildContext context) {
    return _buildServicesSection(context, isDarkMode, salonDetail);
  }

  Widget _buildServicesSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.services.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.content_cut,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
              Text(
                'No services available',
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

    final serviceCategories =
        SalonDetailsPageCubit.getUniqueCategories(salonDetail.services);
    final categoriesWithAll = ['Featured', ...serviceCategories];
    final currentCategory = categoriesWithAll[
        activeServiceCategoryIndex.clamp(0, categoriesWithAll.length - 1)];

    List<ServiceEntity> filteredServices;
    if (currentCategory == 'Featured') {
      final popular = salonDetail.services.where((s) => s.isPopular).toList();
      final others = salonDetail.services.where((s) => !s.isPopular).toList();
      filteredServices = [...popular, ...others];
    } else {
      filteredServices = salonDetail.services
          .where((service) => service.category == currentCategory)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoriesWithAll.length,
            itemBuilder: (context, index) {
              final category = categoriesWithAll[index];
              final isActive = activeServiceCategoryIndex == index;

              return GestureDetector(
                onTap: () => onServiceCategoryChanged(index),
                child: Container(
                  margin: EdgeInsets.only(right: AppSizes.paddingS),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDarkMode
                            ? AppColors.primaryDark
                            : SalonDetailDesignTokens.textPrimary)
                        : (isDarkMode
                            ? AppColors.textSecondary.withValues(alpha: 0.15)
                            : SalonDetailDesignTokens.chipCategoryBg),
                    borderRadius: BorderRadius.circular(99),
                    border: isActive
                        ? null
                        : Border.all(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : SalonDetailDesignTokens.serviceCardBorder,
                            width: 1,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: GoogleFonts.inter(
                        color: isActive
                            ? Colors.white
                            : (isDarkMode
                                ? AppColors.textSecondaryDark
                                : SalonDetailDesignTokens.chipCategoryText),
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: filteredServices
              .map((service) => _buildServiceCardWithCallback(
                    service: service,
                    isDarkMode: isDarkMode,
                    salonGender: salonDetail.gender,
                  ))
              .toList(),
        ),
      ],
    );
  }

  String _resolveServiceGender(ServiceEntity service, String salonGender) {
    final raw = service.serviceFor?.toLowerCase().trim();
    if (raw != null && raw.isNotEmpty) {
      if (raw.contains('female') || raw == 'women' || raw == 'f') {
        return 'female';
      }
      if (raw.contains('male') || raw == 'men' || raw == 'm') {
        return 'male';
      }
    }

    final name = service.name.toLowerCase();
    if (RegExp(r'\bfemale\b').hasMatch(name) || name.contains(' women')) {
      return 'female';
    }
    if (RegExp(r'\bmale\b').hasMatch(name) && !name.contains('female')) {
      return 'male';
    }

    final salon = salonGender.toLowerCase();
    if (salon.contains('women') || salon.contains('female')) {
      return 'female';
    }
    if (salon.contains('men') || salon.contains('male')) {
      return 'male';
    }
    return 'male';
  }

  String _formatDiscountLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return raw.trim();
    return '$cleaned% off';
  }

  Widget _buildServiceGenderIcon(String gender) {
    return SvgPicture.asset(
      gender == 'female' ? AppIcons.icFemale : AppIcons.icMale,
      height: 18,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _buildDiscountSeal() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: SalonDetailDesignTokens.priceGreen,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '%',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildServiceCardWithCallback({
    required ServiceEntity service,
    required bool isDarkMode,
    required String salonGender,
  }) {
    final isSelected = selectedServices.containsKey(service.id);
    final gender = _resolveServiceGender(service, salonGender);
    final hasStrikePrice =
        service.originalPrice != null && service.originalPrice! > service.price;
    final showGreenPrice = hasStrikePrice || service.isPopular;

    final cardBg = isDarkMode
        ? AppColors.surfaceDark.withValues(alpha: 0.5)
        : (service.isPopular
            ? SalonDetailDesignTokens.serviceCardPopularBg
            : SalonDetailDesignTokens.serviceCardDefaultBg);

    final primaryText =
        isDarkMode ? AppColors.textPrimaryDark : const Color(0xFF171717);
    final secondaryText =
        isDarkMode ? AppColors.textSecondaryDark : const Color(0xFF737373);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? SalonDetailDesignTokens.accentBlue.withValues(alpha: 0.4)
              : const Color(0xFFE6E6E6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (salonGender.toLowerCase() == 'unisex') ...[
                      _buildServiceGenderIcon(gender),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        service.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (service.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A0C8CE9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'POPULAR',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0C8CE9),
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            height: 14 / 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.icClock,
                      width: 12,
                      height: 12,
                      colorFilter: ColorFilter.mode(
                        secondaryText,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.duration,
                      style: GoogleFonts.inter(
                        color: secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹${service.price.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 20 / 14,
                        color: showGreenPrice
                            ? SalonDetailDesignTokens.priceGreen
                            : primaryText,
                      ),
                    ),
                    if (hasStrikePrice) ...[
                      const SizedBox(width: 4),
                      Text(
                        '₹${service.originalPrice!.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF727272),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xFF727272),
                          height: 20 / 10,
                        ),
                      ),
                    ],
                    if (service.discountPercentage != null &&
                        service.discountPercentage!.trim().isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: SalonDetailDesignTokens.discountBadgeBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDiscountSeal(),
                            const SizedBox(width: 4),
                            Text(
                              _formatDiscountLabel(service.discountPercentage),
                              style: GoogleFonts.inter(
                                color: SalonDetailDesignTokens.priceGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                height: 20 / 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => onToggleService(service),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode
                        ? AppColors.borderDark.withValues(alpha: 0.6)
                        : SalonDetailDesignTokens.addedButtonBg)
                    : const Color(0xFF171717),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isDarkMode
                          ? AppColors.borderDark
                          : SalonDetailDesignTokens.addedButtonBorder)
                      : const Color(0xFF171717),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSelected) ...[
                    const Icon(Icons.add, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Add',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Added',
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : SalonDetailDesignTokens.addedButtonText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check,
                      size: 14,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : SalonDetailDesignTokens.addedButtonText,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
