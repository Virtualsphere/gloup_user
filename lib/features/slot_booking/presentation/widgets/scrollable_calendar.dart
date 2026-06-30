import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ScrollableCalendar extends StatefulWidget {
  const ScrollableCalendar({
    super.key,
    this.onDateSelected,
  });

  final Function(DateTime)? onDateSelected;

  @override
  State<ScrollableCalendar> createState() => _ScrollableCalendarState();
}

class _ScrollableCalendarState extends State<ScrollableCalendar> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  late ScrollController scrollController;
  late List<DateTime> dates;

  @override
  void initState() {
    super.initState();
    _generateDates();
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  void _generateDates() {
    dates = [];
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    for (int i = 0; i < lastDay.day; i++) {
      dates.add(firstDay.add(Duration(days: i)));
    }
  }

  void _scrollToCurrentDate() {
    final currentDayIndex = dates.indexWhere((date) =>
        date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year);

    if (currentDayIndex != -1) {
      final offset = (currentDayIndex * 70.0) -
          (MediaQuery.of(context).size.width / 2) +
          35;
      scrollController.animateTo(
        offset.clamp(0.0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousMonth() {
    // Don't allow going to previous months from current month
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final previousMonthStart =
        DateTime(currentMonth.year, currentMonth.month - 1, 1);

    // Only allow going back if we're not at the current month
    if (previousMonthStart.isBefore(currentMonthStart)) {
      return; // Don't go to previous months
    }

    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      _generateDates();
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      _generateDates();
    });
  }

  void _selectDate(DateTime date) {
    // Don't allow selecting past dates
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDateOnly = DateTime(date.year, date.month, date.day);

    if (selectedDateOnly.isBefore(todayDate)) {
      return; // Don't select past dates
    }

    setState(() {
      selectedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left arrow - disabled if current month
                GestureDetector(
                  onTap: () {
                    final now = DateTime.now();
                    final currentMonthStart = DateTime(now.year, now.month, 1);
                    final displayedMonthStart =
                        DateTime(currentMonth.year, currentMonth.month, 1);

                    // Only allow if not displaying current month
                    if (!displayedMonthStart
                        .isAtSameMomentAs(currentMonthStart)) {
                      _previousMonth();
                    }
                  },
                  child: Container(
                    height: 35,
                    width: 35,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: AppSizes.iconS,
                      color: () {
                        final now = DateTime.now();
                        final currentMonthStart =
                            DateTime(now.year, now.month, 1);
                        final displayedMonthStart =
                            DateTime(currentMonth.year, currentMonth.month, 1);
                        final isCurrentMonth = displayedMonthStart
                            .isAtSameMomentAs(currentMonthStart);

                        if (isCurrentMonth) {
                          return isDarkMode
                              ? AppColors.textDisabledDark
                              : AppColors.textDisabled;
                        }
                        return context.onSurfaceEmphasis;
                      }(),
                    ),
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(currentMonth),
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSizes.fontL,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceS),
                    SvgPicture.asset(
                      'assets/icons/ic_calendar.svg',
                      width: AppSizes.iconS,
                      height: AppSizes.iconS,
                      colorFilter: ColorFilter.mode(
                        context.onSurfaceEmphasis,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),

                // Right arrow
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    height: 35,
                    width: 35,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: AppSizes.iconS,
                      color: context.onSurfaceEmphasis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.spaceS),
          SizedBox(
            height: 70,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = date.day == selectedDate.day &&
                    date.month == selectedDate.month &&
                    date.year == selectedDate.year;

                // Check if date is in the past
                final today = DateTime.now();
                final todayDate = DateTime(today.year, today.month, today.day);
                final currentDate = DateTime(date.year, date.month, date.day);
                final isPastDate = currentDate.isBefore(todayDate);

                return GestureDetector(
                  onTap: isPastDate ? null : () => _selectDate(date),
                  child: Container(
                    width: 55,
                    margin: EdgeInsets.only(right: AppSizes.spaceS),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primaryFill
                          : isPastDate
                              ? isDarkMode
                                  ? AppColors.textSecondaryDark
                                      .withValues(alpha: 0.3)
                                  : AppColors.textSecondary
                                      .withValues(alpha: 0.3)
                              : (isDarkMode
                                  ? AppColors.backgroundDark
                                      .withValues(alpha: 0.5)
                                  : AppColors.background),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: !isSelected || isPastDate
                          ? Border.all(
                              color: isDarkMode
                                  ? AppColors.borderDark
                                  : AppColors.border,
                              width: AppSizes.borderWidth,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day name (Mon, Tue, etc.)
                        Text(
                          DateFormat('EEE').format(date),
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: AppSizes.fontS,
                            fontWeight: FontWeight.w400,
                            color: isSelected
                                ? context.onPrimaryFill
                                : isPastDate
                                    ? (isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary)
                                    : (isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                          ),
                        ),
                        SizedBox(height: AppSizes.spaceS),
                        // Date number
                        Text(
                          date.day.toString(),
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontSize: AppSizes.fontL,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? context.onPrimaryFill
                                : isPastDate
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSizes.paddingM),
        ],
      ),
    );
  }
}
