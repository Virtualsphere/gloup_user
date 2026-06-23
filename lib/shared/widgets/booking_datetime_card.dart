import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class BookingDateTimeCard extends StatelessWidget {
  final String selectedDate;
  final String selectedTimeSlot;

  const BookingDateTimeCard({
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
      padding: EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          // Left column - Date
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: context.onSurfaceEmphasis,
                ),
                SizedBox(width: AppSizes.spaceS),
                Expanded(
                  child: Text(
                    selectedDate,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.spaceM),
          // Right column - Time slot
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: context.onSurfaceEmphasis,
                ),
                SizedBox(width: AppSizes.spaceS),
                Expanded(
                  child: Text(
                    selectedTimeSlot,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
