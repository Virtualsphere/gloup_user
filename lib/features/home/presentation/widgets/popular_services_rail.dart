import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/core/utils/category_image_resolver.dart';
import 'package:tressy/features/home/data/models/service_category_model.dart';
import 'package:tressy/shared/widgets/category_image.dart';

/// "Popular services nearby" rail (Figma 3-2): service image, name and the
/// price with the struck-through MRP when it is higher.
class PopularServicesRail extends StatelessWidget {
  final List<ServiceCategoryModel> services;
  final bool isLoading;
  final ValueChanged<ServiceCategoryModel> onServiceTap;
  final VoidCallback onSeeAll;

  const PopularServicesRail({
    super.key,
    required this.services,
    required this.onServiceTap,
    required this.onSeeAll,
    this.isLoading = false,
  });

  /// MRP to strike through, or null when there is no real discount.
  static int? struckPrice(ServiceCategoryModel s) {
    final mrp = s.amount;
    if (mrp == null || mrp <= s.discountedAmount) return null;
    return mrp;
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            HomeDesignTokens.screenGutter.w,
            12.h,
            HomeDesignTokens.screenGutter.w,
            12.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Popular services nearby',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: HomeDesignTokens.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                key: const Key('services_see_all'),
                behavior: HitTestBehavior.opaque,
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: HomeDesignTokens.accentBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 176.h,
          child: isLoading && services.isEmpty
              ? _skeleton()
              : ListView.separated(
                  key: const Key('services_rail'),
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: HomeDesignTokens.screenGutter.w,
                  ),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, i) => _card(services[i], i),
                ),
        ),
      ],
    );
  }

  Widget _card(ServiceCategoryModel s, int i) {
    final mrp = struckPrice(s);
    final image = CategoryImageResolver.resolveImagePath(
      categoryName: s.name,
      imageUrl: s.imageUrl,
    );

    return GestureDetector(
      key: Key('service_$i'),
      onTap: () => onServiceTap(s),
      child: SizedBox(
        width: 132.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(HomeDesignTokens.cardRadius.r),
                child: SizedBox(
                  width: double.infinity,
                  child: ColoredBox(
                    color: HomeDesignTokens.pageBackground,
                    child: CategoryImage(
                      categoryName: s.name,
                      imageUrl: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              s.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: HomeDesignTokens.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'from ₹${s.discountedAmount}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: HomeDesignTokens.textPrimary,
                    ),
                  ),
                  if (mrp != null)
                    TextSpan(
                      text: '  ₹$mrp',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: HomeDesignTokens.textHint,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeleton() {
    return ListView.separated(
      key: const Key('services_skeleton'),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: HomeDesignTokens.screenGutter.w),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (_, __) => Container(
        width: 132.w,
        decoration: BoxDecoration(
          color: HomeDesignTokens.border,
          borderRadius: BorderRadius.circular(HomeDesignTokens.cardRadius.r),
        ),
      ),
    );
  }
}
