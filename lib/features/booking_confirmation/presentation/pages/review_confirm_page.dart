import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/widgets/offer_banner.dart';
import 'package:tressy/shared/widgets/salon_info_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/selected_services_card.dart';

class ReviewConfirmPage extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const ReviewConfirmPage({
    super.key,
    this.bookingData,
  });

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  String selectedBookingFor = 'myself'; // 'myself' or 'someone_else'

  // Calculate highest offer percentage from selected services
  int get _highestOfferPercentage {
    if (widget.bookingData == null) return 0;

    final selectedServices = widget.bookingData!['selectedServices'] as List?;
    if (selectedServices == null || selectedServices.isEmpty) return 0;

    return selectedServices
        .where((service) => service['discountPercentage'] != null)
        .map((service) {
      final discountStr = service['discountPercentage'] as String;
      final discountInt =
          int.tryParse(discountStr.replaceAll('%', '').trim()) ?? 0;
      return discountInt;
    }).fold<int>(0, (max, discount) => discount > max ? discount : max);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review & Confirm',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Offer banner below app bar
          OfferBanner(discountPercentage: _highestOfferPercentage),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.bookingData != null) ...[
                    // Salon info card with date and time
                    SalonInfoCard(
                      salonName: widget.bookingData!['salonName'] as String? ?? 'N/A',
                      salonImage: widget.bookingData!['salonImage'] as String?,
                      rating: widget.bookingData!['rating'] as double? ?? 0.0,
                      reviewCount: widget.bookingData!['reviewCount'] as int? ?? 0,
                      gender: widget.bookingData!['gender'] as String? ?? 'N/A',
                      address: widget.bookingData!['address'] as String? ?? 'N/A',
                      isPremium: widget.bookingData!['isPremium'] as bool? ?? false,
                      selectedDate: widget.bookingData!['selectedDate'] as String?,
                      selectedTimeSlot:
                          widget.bookingData!['selectedTimeSlot'] as String?,
                    ),
                    // Selected services card
                    SelectedServicesCard(
                      services: (widget.bookingData!['selectedServices'] as List?)
                              ?.cast<Map<String, dynamic>>() ??
                          [],
                    ),
                    const SizedBox(height: AppSizes.spaceM),
                    // Who is this booking for section
                    _buildSectionTitle(context, 'Who is this booking for?', isDarkMode),
                    const SizedBox(height: AppSizes.spaceS),
                    // Booking for selector (Myself / Someone else)
                    _buildBookingForSelector(context, isDarkMode),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable title widget
  Widget _buildSectionTitle(BuildContext context, String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
        ),
      ),
    );
  }

  // Booking for selector (Myself / Someone else)
  Widget _buildBookingForSelector(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        children: [
          // Myself button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBookingFor = 'myself';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                  horizontal: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: selectedBookingFor == 'myself'
                      ? (isDarkMode ? AppColors.primaryDark : AppColors.primary)
                      : (isDarkMode ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: selectedBookingFor != 'myself'
                      ? Border.all(
                          color: isDarkMode ? AppColors.borderDark : AppColors.border,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: selectedBookingFor == 'myself'
                          ? AppColors.white
                          : (isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    ),
                    const SizedBox(width: AppSizes.spaceXS),
                    Text(
                      'Myself',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: selectedBookingFor == 'myself'
                                ? AppColors.white
                                : (isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          // Someone else button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBookingFor = 'someone_else';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                  horizontal: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: selectedBookingFor == 'someone_else'
                      ? (isDarkMode ? AppColors.primaryDark : AppColors.primary)
                      : (isDarkMode ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: selectedBookingFor != 'someone_else'
                      ? Border.all(
                          color: isDarkMode ? AppColors.borderDark : AppColors.border,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: selectedBookingFor == 'someone_else'
                          ? AppColors.white
                          : (isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    ),
                    const SizedBox(width: AppSizes.spaceXS),
                    Text(
                      'Someone else',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: selectedBookingFor == 'someone_else'
                                ? AppColors.white
                                : (isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
