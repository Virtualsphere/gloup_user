import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/offer_banner.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:tressy/shared/widgets/salon_info_card.dart';
import 'package:tressy/features/slot_booking/presentation/widgets/scrollable_calendar.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SlotBookingPage extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const SlotBookingPage({
    super.key,
    this.bookingData,
  });

  @override
  State<SlotBookingPage> createState() => _SlotBookingPageState();
}

class _SlotBookingPageState extends State<SlotBookingPage> {
  DateTime? selectedDate = DateTime.now(); // Initialize with today's date
  String? selectedTimeSlot;

  // Static time slots (will be replaced with server data in future)
  final List<Map<String, dynamic>> timeSlots = [
    {'time': '10:00 AM - 10:30 AM', 'startHour': 10, 'startMinute': 0},
    {'time': '10:30 AM - 11:00 AM', 'startHour': 10, 'startMinute': 30},
    {'time': '11:00 AM - 11:30 AM', 'startHour': 11, 'startMinute': 0},
    {'time': '11:30 AM - 12:00 PM', 'startHour': 11, 'startMinute': 30},
    {'time': '12:00 PM - 12:30 PM', 'startHour': 12, 'startMinute': 0},
    {'time': '12:30 PM - 01:00 PM', 'startHour': 12, 'startMinute': 30},
    {'time': '01:00 PM - 01:30 PM', 'startHour': 13, 'startMinute': 0},
    {'time': '01:30 PM - 02:00 PM', 'startHour': 13, 'startMinute': 30},
    {'time': '02:00 PM - 02:30 PM', 'startHour': 14, 'startMinute': 0},
    {'time': '02:30 PM - 03:00 PM', 'startHour': 14, 'startMinute': 30},
    {'time': '03:00 PM - 03:30 PM', 'startHour': 15, 'startMinute': 0},
    {'time': '03:30 PM - 04:00 PM', 'startHour': 15, 'startMinute': 30},
    {'time': '04:00 PM - 04:30 PM', 'startHour': 16, 'startMinute': 0},
    {'time': '04:30 PM - 05:00 PM', 'startHour': 16, 'startMinute': 30},
    {'time': '05:00 PM - 05:30 PM', 'startHour': 17, 'startMinute': 0},
    {'time': '05:30 PM - 06:00 PM', 'startHour': 17, 'startMinute': 30},
    {'time': '06:00 PM - 06:30 PM', 'startHour': 18, 'startMinute': 0},
    {'time': '06:30 PM - 07:00 PM', 'startHour': 18, 'startMinute': 30},
  ];

  // Check if a time slot is in the past
  bool _isSlotPast(int startHour, int startMinute) {
    if (selectedDate == null) return false;

    final now = DateTime.now();
    final selectedDay =
        DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    final today = DateTime(now.year, now.month, now.day);

    // If selected date is in the future, no slots are past
    if (selectedDay.isAfter(today)) return false;

    // If selected date is today, check the time
    if (selectedDay.isAtSameMomentAs(today)) {
      final slotTime =
          DateTime(now.year, now.month, now.day, startHour, startMinute);
      return slotTime.isBefore(now);
    }

    return false;
  }

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
          'Book Slot',
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
                  if (widget.bookingData != null)
                    SalonInfoCard(
                      salonName:
                          widget.bookingData!['salonName'] as String? ?? 'N/A',
                      salonImage: widget.bookingData!['salonImage'] as String?,
                      rating: widget.bookingData!['rating'] as double? ?? 0.0,
                      reviewCount:
                          widget.bookingData!['reviewCount'] as int? ?? 0,
                      gender: widget.bookingData!['gender'] as String? ?? 'N/A',
                      address:
                          widget.bookingData!['address'] as String? ?? 'N/A',
                      isPremium:
                          widget.bookingData!['isPremium'] as bool? ?? false,
                    ),
                  // Calendar widget
                  ScrollableCalendar(
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date;
                        selectedTimeSlot = null;
                      });
                    },
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  // Time section title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available Slots',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontSize: AppSizes.fontL,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceM),
                  // Time slots grid
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSizes.spaceM,
                        mainAxisSpacing: AppSizes.spaceM,
                        childAspectRatio: 3,
                      ),
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final slotData = timeSlots[index];
                        final slot = slotData['time'] as String;
                        final startHour = slotData['startHour'] as int;
                        final startMinute = slotData['startMinute'] as int;

                        final isSelected = selectedTimeSlot == slot;
                        final isPast = _isSlotPast(startHour, startMinute);

                        return GestureDetector(
                          onTap: isPast
                              ? null
                              : () {
                                  setState(() {
                                    // Toggle: if already selected, unselect it
                                    if (selectedTimeSlot == slot) {
                                      selectedTimeSlot = null;
                                    } else {
                                      selectedTimeSlot = slot;
                                    }
                                  });
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDarkMode
                                      ? AppColors.primaryDark
                                      : AppColors.primary)
                                  : isPast
                                      ? (isDarkMode
                                          ? AppColors.textSecondaryDark
                                              .withValues(alpha: 0.2)
                                          : AppColors.textSecondary
                                              .withValues(alpha: 0.2))
                                      : (isDarkMode
                                          ? AppColors.surfaceDark
                                          : AppColors.surface),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusM),
                              border: Border.all(
                                color: isSelected || isPast
                                    ? Colors.transparent
                                    : (isDarkMode
                                        ? AppColors.borderDark
                                        : AppColors.border),
                                width: AppSizes.borderWidth,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              slot,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontSize: AppSizes.fontM,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? (isDarkMode
                                        ? AppColors.black
                                        : AppColors.white)
                                    : isPast
                                        ? (isDarkMode
                                            ? AppColors.textPrimaryDark
                                                .withValues(alpha: 0.7)
                                            : AppColors.textPrimary
                                                .withValues(alpha: 0.7))
                                        : (isDarkMode
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: selectedTimeSlot != null
          ? _buildBookingBottomNav(context, isDarkMode)
          : _buildBottomIndicators(context, isDarkMode),
    );
  }

  Widget _buildBookingBottomNav(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Left side - Slot info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedTimeSlot!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'slot selected. Ready to Book?',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSizes.fontS,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            // Right side - Continue button
            SizedBox(
              width: 130,
              child: PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  // Navigate to review & confirm page with all booking data
                  final bookingDataWithSlot = {
                    ...widget.bookingData!,
                    'selectedDate':
                        DateFormat('dd MMM yyyy').format(selectedDate!),
                    'selectedTimeSlot': selectedTimeSlot,
                  };
                  context.pushNamed(
                    RouteNames.reviewConfirm,
                    extra: bookingDataWithSlot,
                  );
                },
                backgroundColor:
                    isDarkMode ? AppColors.primaryDark : AppColors.primary,
                textColor: AppColors.white,
                height: 52,
                fontSize: AppSizes.fontL,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIndicators(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 52, // Match the Continue button height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Not Available indicator
              _buildIndicatorItem(
                context,
                isDarkMode,
                'Not Available',
                isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                showBorder: false,
              ),
              // Available indicator
              _buildIndicatorItem(
                context,
                isDarkMode,
                'Available',
                isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                showBorder: true,
              ),
              // Selected indicator
              _buildIndicatorItem(
                context,
                isDarkMode,
                'Selected',
                isDarkMode ? AppColors.primaryDark : AppColors.primary,
                showBorder: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorItem(
      BuildContext context, bool isDarkMode, String label, Color color,
      {required bool showBorder}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: showBorder
                ? Border.all(
                    color: isDarkMode ? AppColors.borderDark : AppColors.border,
                    width: AppSizes.borderWidth,
                  )
                : null,
          ),
        ),
        const SizedBox(width: AppSizes.spaceS),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: AppSizes.fontS,
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
