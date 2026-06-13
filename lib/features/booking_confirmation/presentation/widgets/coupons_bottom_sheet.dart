import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/coupon_card.dart';

class CouponData {
  final int discountAmount;
  final int id;
  final String couponCode;
  final String discountType; // 'flat' | 'percentage'

  CouponData({
    required this.discountAmount,
    required this.id,
    required this.couponCode,
    this.discountType = 'flat',
  });
}

Future<String?> showCouponsBottomSheet(
  BuildContext context, {
  required List<CouponData> coupons,
  String? selectedCouponCode,
  required double serviceAmount, // This should be the discounted amount
}) async {
  return await showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CouponsBottomSheet(
      coupons: coupons,
      selectedCouponCode: selectedCouponCode,
      serviceAmount: serviceAmount,
    ),
  );
}

class _CouponsBottomSheet extends StatefulWidget {
  final List<CouponData> coupons;
  final String? selectedCouponCode;
  final double serviceAmount;

  const _CouponsBottomSheet({
    required this.coupons,
    this.selectedCouponCode,
    required this.serviceAmount,
  });

  @override
  State<_CouponsBottomSheet> createState() => _CouponsBottomSheetState();
}

class _CouponsBottomSheetState extends State<_CouponsBottomSheet> {
  String? _selectedCoupon;

  @override
  void initState() {
    super.initState();
    _selectedCoupon = widget.selectedCouponCode;
  }

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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top handle
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    'Available Coupons',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Coupons list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingS,
                ),
                itemCount: widget.coupons.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: AppSizes.spaceM),
                itemBuilder: (context, index) {
                  final coupon = widget.coupons[index];
                  final isSelected = _selectedCoupon == coupon.couponCode;

                  // Check if coupon can be applied
                  final minAmountRequired = coupon.discountAmount.toDouble();
                  final isCouponValid =
                      widget.serviceAmount >= (minAmountRequired + 30);
                  final amountNeeded =
                      (minAmountRequired + 30 - widget.serviceAmount)
                          .clamp(0, double.infinity);

                  String? disabledReason;
                  if (!isCouponValid) {
                    disabledReason =
                        'Add services worth ₹${amountNeeded.toStringAsFixed(0)} more to avail this coupon';
                  }

                  return CouponCard(
                    discountAmount: coupon.discountAmount,
                    couponCode: coupon.couponCode,
                    discountType: coupon.discountType,
                    isSelected: isSelected,
                    isEnabled: isCouponValid,
                    disabledReason: disabledReason,
                    onTap: () {
                      if (!isCouponValid) {
                        // Don't close bottom sheet, just show it's disabled
                        return;
                      }
                      setState(() {
                        // Toggle: if already selected, unselect; otherwise select
                        _selectedCoupon = isSelected ? null : coupon.couponCode;
                      });
                      // Close bottom sheet and return selected coupon
                      Navigator.of(context).pop(_selectedCoupon);
                    },
                  );
                },
              ),
            ),

            SizedBox(height: AppSizes.paddingL),
          ],
        ),
      ),
    );
  }
}
