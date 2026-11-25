import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/shared/widgets/salon_network_image.dart';

/// Price of the category's service at a salon: "Haircut from ₹99 ~~₹149~~".
class CategoryServicePrice {
  final String name;
  final num price;

  /// List price, only when higher than [price].
  final num? mrp;

  const CategoryServicePrice(this.name, this.price, this.mrp);

  /// Finds the salon's service matching [categoryName]; falls back to the
  /// headline service when none matches. Null when the salon lists no price.
  static CategoryServicePrice? forSalon(
    SalonEntity salon,
    String categoryName,
  ) {
    final wanted = categoryName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    num? asNum(dynamic v) => v is num ? v : num.tryParse('${v ?? ''}');

    CategoryServicePrice? best;
    for (final s in salon.dynamicServices ?? const <Map<String, dynamic>>[]) {
      final name = s['name']?.toString() ?? '';
      final key = name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
      if (wanted.isEmpty || !key.contains(wanted)) continue;
      final list = asNum(s['price']);
      final offer = asNum(s['discountedPrice']) ?? list;
      if (offer == null) continue;
      if (best == null || offer < best.price) {
        best = CategoryServicePrice(
          name,
          offer,
          list != null && list > offer ? list : null,
        );
      }
    }
    if (best != null) return best;

    if (salon.servicePrice != null && (salon.serviceName ?? '').isNotEmpty) {
      return CategoryServicePrice(salon.serviceName!, salon.servicePrice!, null);
    }
    return null;
  }
}

/// Category page row (Figma 5-2): image with offer badge, name, rating pill,
/// distance, "service from ₹X ~~₹Y~~" and a Book button.
class CategorySalonRow extends StatelessWidget {
  final SalonEntity salon;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onBook;

  const CategorySalonRow({
    super.key,
    required this.salon,
    required this.categoryName,
    required this.onTap,
    required this.onBook,
  });

  static String _rupees(num v) =>
      '₹${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final image = salon.images.isNotEmpty ? salon.images.first : salon.salonImage;
    final price = CategoryServicePrice.forSalon(salon, categoryName);
    final meta = <String>[
      if (salon.reviewCount > 0) '${salon.reviewCount} reviews',
      if (salon.distance > 0) '${salon.distance.toStringAsFixed(1)} km',
    ].join(' · ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: HomeDesignTokens.surface,
          borderRadius: BorderRadius.circular(HomeDesignTokens.cardRadius.r),
          border: Border.all(color: HomeDesignTokens.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 96.w,
                    height: 112.h,
                    child: SalonNetworkImage(
                      imageUrl: image,
                      width: 96.w,
                      height: 112.h,
                      logTag: 'CategorySalonRow',
                    ),
                  ),
                ),
                if (salon.offerBadge != null)
                  Positioned(
                    left: 6.w,
                    top: 6.h,
                    child: Container(
                      key: const Key('row_offer_badge'),
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: HomeDesignTokens.offerBadgeBg,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        salon.offerBadge!.label,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: HomeDesignTokens.offerBadgeText,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          salon.salonName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: HomeDesignTokens.textPrimary,
                          ),
                        ),
                      ),
                      if (salon.reviewCount > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          key: const Key('row_rating_pill'),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: HomeDesignTokens.ratingPillBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 12.w, color: Colors.white),
                              SizedBox(width: 2.w),
                              Text(
                                salon.rating.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: HomeDesignTokens.ratingPillText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (meta.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      meta,
                      key: const Key('row_meta'),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: HomeDesignTokens.textSecondary,
                      ),
                    ),
                  ],
                  if (salon.displayAddress.trim().isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      salon.displayAddress.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: HomeDesignTokens.textHint,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: price == null
                            ? const SizedBox.shrink()
                            : Text.rich(
                                key: const Key('row_price'),
                                TextSpan(children: [
                                  TextSpan(
                                    text: '${price.name} from '
                                        '${_rupees(price.price)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: HomeDesignTokens.textPrimary,
                                    ),
                                  ),
                                  if (price.mrp != null)
                                    TextSpan(
                                      text: '  ${_rupees(price.mrp!)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        color: HomeDesignTokens.textHint,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        height: 34.h,
                        child: ElevatedButton(
                          key: const Key('row_book'),
                          onPressed: onBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HomeDesignTokens.textPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Book',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
