import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_bloc.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_event.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_state.dart';
import 'package:tressy/features/slot_booking/presentation/widgets/scrollable_calendar.dart';
import 'package:tressy/features/slot_booking/presentation/widgets/slot_shimmers.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/offer_banner.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:tressy/shared/widgets/salon_info_card.dart';

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
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() {
    final salonIdValue = widget.bookingData?['salonId'];
    int? salonId;

    if (salonIdValue is int) {
      salonId = salonIdValue;
    } else if (salonIdValue is String) {
      salonId = int.tryParse(salonIdValue);
    }

    if (salonId != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      context.read<SlotBloc>().add(
            LoadSlotsEvent(salonId: salonId, date: dateStr),
          );
    }
  }

  // Format time from 24-hour to 12-hour format
  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  // Format time range (start time + service duration)
  String _formatTimeRange(String time24) {
    try {
      // Calculate total duration from selected services
      int totalMinutes = 0;
      final selectedServices = widget.bookingData?['selectedServices'] as List?;

      if (selectedServices != null && selectedServices.isNotEmpty) {
        for (var service in selectedServices) {
          final duration = service['duration'] as String?;
          if (duration != null) {
            // Parse duration format "HH:MM:SS" or "HH:MM"
            final durationParts = duration.split(':');
            final hours = int.tryParse(durationParts[0]) ?? 0;
            final minutes = int.tryParse(durationParts[1]) ?? 0;
            totalMinutes += (hours * 60) + minutes;
          }
        }
      }

      // If no duration, default to 30 minutes
      if (totalMinutes == 0) {
        totalMinutes = 30;
      }

      // Parse start time
      final parts = time24.split(':');
      final startHour = int.parse(parts[0]);
      final startMinute = int.parse(parts[1]);

      // Calculate end time
      final startDateTime = DateTime(2000, 1, 1, startHour, startMinute);
      final endDateTime = startDateTime.add(Duration(minutes: totalMinutes));

      // Format start time
      final startPeriod = startHour >= 12 ? 'PM' : 'AM';
      final startHour12 =
          startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
      final startFormatted =
          '${startHour12.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')} $startPeriod';

      // Format end time
      final endHour = endDateTime.hour;
      final endMinute = endDateTime.minute;
      final endPeriod = endHour >= 12 ? 'PM' : 'AM';
      final endHour12 =
          endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
      final endFormatted =
          '${endHour12.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')} $endPeriod';

      return '$startFormatted - $endFormatted';
    } catch (e) {
      return _formatTime(time24);
    }
  }

  // Check if a time slot is in the past
  bool _isSlotPast(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      final selectedDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final today = DateTime(now.year, now.month, now.day);

      // If selected date is in the future, no slots are past
      if (selectedDay.isAfter(today)) return false;

      // If selected date is today, check the time
      if (selectedDay.isAtSameMomentAs(today)) {
        final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
        return slotTime.isBefore(now);
      }

      return false;
    } catch (e) {
      return false;
    }
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
        title: Text('Book Slot',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            )),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Offer banner
          OfferBanner(discountPercentage: _highestOfferPercentage),

          // Main content
          Expanded(
            child: BlocBuilder<SlotBloc, SlotState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Salon info card
                      if (widget.bookingData != null)
                        SalonInfoCard(
                          salonName:
                              widget.bookingData!['salonName'] as String? ??
                                  'N/A',
                          salonImage:
                              widget.bookingData!['salonImage'] as String?,
                          rating:
                              widget.bookingData!['rating'] as double? ?? 0.0,
                          reviewCount:
                              widget.bookingData!['reviewCount'] as int? ?? 0,
                          gender:
                              widget.bookingData!['gender'] as String? ?? 'N/A',
                          address: widget.bookingData!['address'] as String? ??
                              'N/A',
                          isPremium:
                              widget.bookingData!['isPremium'] as bool? ??
                                  false,
                        ),

                      // Calendar widget
                      ScrollableCalendar(
                        onDateSelected: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                          context
                              .read<SlotBloc>()
                              .add(const ClearSelectedSlotEvent());
                          _loadSlots();
                        },
                      ),

                      const SizedBox(height: AppSizes.spaceM),

                      // Section title
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

                      // Slots grid or loading/error states
                      if (state.isLoading)
                        SlotShimmers.slotGridShimmer(context)
                      else if (state.errorMessage != null)
                        _buildErrorState(isDarkMode, state.errorMessage!)
                      else if (state.slots.isEmpty)
                        _buildEmptyState(isDarkMode)
                      else
                        _buildSlotsGrid(context, state, isDarkMode),

                      const SizedBox(height: AppSizes.spaceXXL),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<SlotBloc, SlotState>(
        builder: (context, state) {
          return state.hasSelectedSlot
              ? _buildBottomBar(context, isDarkMode, state.selectedSlotTime!,
                  state.selectedSlotId)
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSlotsGrid(
      BuildContext context, SlotState state, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingM,
        right: AppSizes.paddingM,
        bottom: AppSizes.paddingXL,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSizes.spaceM,
          mainAxisSpacing: AppSizes.spaceM,
          childAspectRatio: 3,
        ),
        itemCount: state.slots.length,
        itemBuilder: (context, index) {
          final slot = state.slots[index];
          final isSelected = state.selectedSlotTime == slot.time;
          final isBooked = slot.isBooked;
          final isPast = _isSlotPast(slot.time);

          return GestureDetector(
            onTap: (isBooked || isPast)
                ? null
                : () {
                    if (isSelected) {
                      context
                          .read<SlotBloc>()
                          .add(const ClearSelectedSlotEvent());
                    } else {
                      context
                          .read<SlotBloc>()
                          .add(SelectSlotEvent(slot.time, slot.salonId));
                    }
                  },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode ? AppColors.primaryDark : AppColors.primary)
                    : (isBooked || isPast)
                        ? (isDarkMode
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                            : AppColors.textSecondary.withValues(alpha: 0.2))
                        : (isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.surface),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: (isSelected || isBooked || isPast)
                      ? Colors.transparent
                      : (isDarkMode ? AppColors.borderDark : AppColors.border),
                  width: AppSizes.borderWidth,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _formatTimeRange(slot.time),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: AppSizes.fontS,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? (isDarkMode ? AppColors.black : AppColors.white)
                      : (isBooked || isPast)
                          ? (isDarkMode
                              ? AppColors.textPrimaryDark.withValues(alpha: 0.5)
                              : AppColors.textPrimary.withValues(alpha: 0.5))
                          : (isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: isDarkMode
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                  : AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              'No slots available',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              'Please select another date',
              textAlign: TextAlign.center,
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

  Widget _buildErrorState(bool isDarkMode, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              'Error loading slots',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            ElevatedButton(
              onPressed: _loadSlots,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDarkMode,
      String selectedTime, int? selectedSlotId) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingM,
        right: AppSizes.paddingM,
        top: AppSizes.paddingM,
        bottom: AppSizes.paddingM + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Slot',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(selectedDate),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimeRange(selectedTime),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          PrimaryButton(
            text: 'Continue',
            onPressed: () {
              // Navigate to booking confirmation
              final updatedBookingData = {
                ...?widget.bookingData,
                'selectedDate': DateFormat('yyyy-MM-dd').format(selectedDate),
                'selectedTime': selectedTime,
                'selectedTimeFormatted': _formatTimeRange(selectedTime),
                'slotId': selectedSlotId,
              };

              GoRouter.of(context).push(
                RouteNames.reviewConfirm,
                extra: updatedBookingData,
              );
            },
            textColor: isDarkMode ? AppColors.primary : AppColors.primaryDark,
            width: 120,
          ),
        ],
      ),
    );
  }
}
