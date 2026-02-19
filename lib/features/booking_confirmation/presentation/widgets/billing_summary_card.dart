import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class BillingSummaryCard extends StatelessWidget {
  final double serviceAmount;
  final double? couponDiscount; // null if no coupon applied
  final String? appliedCouponCode; // null if no coupon applied
  final double serviceDiscount; // Service-level discount (e.g., promotional)
  final double gstPercentage;
  final double platformFee;
  final bool isPlatformFeeWaived;
  final double gloupCash; // Gloup wallet credit

  const BillingSummaryCard({
    super.key,
    required this.serviceAmount,
    this.couponDiscount,
    this.appliedCouponCode,
    this.serviceDiscount = 0,
    this.gstPercentage = 5.0,
    this.platformFee = 7.0,
    this.isPlatformFeeWaived = true,
    this.gloupCash = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surface = isDarkMode ? AppColors.surfaceDark : AppColors.surface;

    // Calculate subtotal (after service discount and coupon)
    double subtotal = serviceAmount - serviceDiscount;
    if (couponDiscount != null) {
      subtotal -= couponDiscount!;
    }

    // Calculate GST
    final gst = (subtotal * gstPercentage) / 100;

    // Platform fee (waived = FREE)
    final actualPlatformFee = isPlatformFeeWaived ? 0.0 : platformFee;

    // Total before Gloup Cash
    final totalBeforeGloupCash = subtotal + gst + actualPlatformFee;

    // Final total after Gloup Cash
    final finalTotal = totalBeforeGloupCash - gloupCash;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          // Amount (Service total)
          _buildRow(
            context,
            label: 'Amount',
            value: '₹${serviceAmount.toStringAsFixed(0)}',
            isBold: true,
            valueBold: true,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: AppSizes.spaceM),

          // Coupon discount (conditional)
          if (couponDiscount != null && appliedCouponCode != null) ...[
            _buildRow(
              context,
              label: 'Coupon ($appliedCouponCode)',
              value: '-₹${couponDiscount!.toStringAsFixed(0)}',
              isBold: true,
              valueBold: true,
              valueColor: AppColors.success,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: AppSizes.spaceM),
            const Divider(height: AppSizes.spaceM),
            const SizedBox(height: AppSizes.spaceM),
          ],

          // Service Discount (if any)
          if (serviceDiscount > 0) ...[
            _buildRow(
              context,
              label: 'Discount',
              value: '-₹${serviceDiscount.toStringAsFixed(0)}',
              isBold: false,
              valueBold: true,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: AppSizes.spaceM),
          ],

          // Subtotal
          _buildRow(
            context,
            label: 'Subtotal',
            value: '₹${subtotal.toStringAsFixed(0)}',
            isBold: false,
            valueBold: true,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: AppSizes.spaceM),

          // GST
          _buildRow(
            context,
            label: 'GST ($gstPercentage%)',
            value: '₹${gst.toStringAsFixed(0)}',
            isBold: false,
            valueBold: true,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: AppSizes.spaceM),

          // Platform Fee (strikethrough if waived)
          _buildRow(
            context,
            label: 'Platform fee',
            value: isPlatformFeeWaived ? 'FREE' : '₹${platformFee.toStringAsFixed(0)}',
            isBold: isPlatformFeeWaived,
            valueBold: true,
            valueColor: isPlatformFeeWaived ? AppColors.success : null,
            strikethrough: isPlatformFeeWaived ? platformFee : null,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: AppSizes.spaceM),

          // Gloup Cash
          _buildRow(
            context,
            label: 'Gloup Cash',
            value: '-₹${gloupCash.toStringAsFixed(0)}',
            isBold: false,
            valueBold: true,
            valueColor: AppColors.success,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: AppSizes.spaceM),

          const Divider(height: AppSizes.spaceM),
          const SizedBox(height: AppSizes.spaceM),

          // Total (with strikethrough original total if different)
          _buildRow(
            context,
            label: 'Total',
            value: '₹${finalTotal.toStringAsFixed(0)}',
            isBold: true,
            valueBold: true,
            strikethrough: totalBeforeGloupCash != finalTotal ? totalBeforeGloupCash : null,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    bool valueBold = false,
    Color? valueColor,
    double? strikethrough,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? textColor,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              ),
        ),
        Row(
          children: [
            if (strikethrough != null) ...[
              Text(
                '₹${strikethrough.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryColor,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: secondaryColor,
                    ),
              ),
              const SizedBox(width: AppSizes.spaceS),
            ],
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? textColor,
                    fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
