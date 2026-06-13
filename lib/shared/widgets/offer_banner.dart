import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class OfferBanner extends StatelessWidget {
  final int discountPercentage;

  const OfferBanner({
    super.key,
    required this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    if (discountPercentage <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        border: Border(
          bottom: BorderSide(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_offer,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            'Flat $discountPercentage% offer is waiting for you!',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.success,
              fontSize: AppSizes.fontS,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
