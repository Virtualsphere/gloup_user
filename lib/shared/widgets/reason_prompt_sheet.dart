import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ReasonOption {
  final String code;
  final String label;

  const ReasonOption({required this.code, required this.label});
}

/// A non-blocking reason prompt bottom sheet with a 1-tap option and "Skip" choice.
class ReasonPromptSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<ReasonOption> reasons;
  final String skipButtonText;
  final String confirmButtonText;

  const ReasonPromptSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.reasons,
    this.skipButtonText = 'Skip',
    this.confirmButtonText = 'Submit',
  });

  /// Shows the bottom sheet and returns the selected reason code, or null if skipped/dismissed.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<ReasonOption> reasons,
    String skipButtonText = 'Skip',
    String confirmButtonText = 'Submit',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReasonPromptSheet(
        title: title,
        subtitle: subtitle,
        reasons: reasons,
        skipButtonText: skipButtonText,
        confirmButtonText: confirmButtonText,
      ),
    );
  }

  @override
  State<ReasonPromptSheet> createState() => _ReasonPromptSheetState();
}

class _ReasonPromptSheetState extends State<ReasonPromptSheet> {
  String? _selectedCode;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSizes.paddingL,
        right: AppSizes.paddingL,
        top: AppSizes.paddingM,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingL,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.borderDark
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  child: Text(
                    widget.skipButtonText,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Options list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.reasons.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final reason = widget.reasons[index];
                  final isSelected = _selectedCode == reason.code;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCode = reason.code;
                      });
                      // Immediate 1-tap select and dismiss
                      Navigator.of(context).pop(reason.code);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDarkMode
                                ? AppColors.primaryDark.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.08))
                            : (isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isDarkMode
                                  ? AppColors.primaryDark
                                  : AppColors.primary)
                              : (isDarkMode
                                  ? AppColors.borderDark.withValues(alpha: 0.5)
                                  : AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reason.label,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? (isDarkMode
                                        ? AppColors.primaryDark
                                        : AppColors.primary)
                                    : (isDarkMode
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary),
                              ),
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSelected
                                ? (isDarkMode
                                    ? AppColors.primaryDark
                                    : AppColors.primary)
                                : (isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

