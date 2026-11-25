import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/home/presentation/widgets/home_salon_card.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/shared/widgets/salon_network_image.dart';

/// Favorites list card (Figma 67-2): image, name, rating pill and count,
/// "services · distance", offer text and a filled heart to remove.
///
/// Collapses with an animation once [removed] flips to true, so removing a
/// favourite does not make the list jump.
class FavoriteSalonCard extends StatelessWidget {
  final SalonEntity salon;
  final bool removed;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteSalonCard({
    super.key,
    required this.salon,
    required this.onTap,
    required this.onRemove,
    this.removed = false,
  });

  /// "Haircut · Facial · 1.2 km", dropping parts that are unknown.
  static String detailLine(SalonEntity salon) {
    final services = HomeSalonCard.servicesLine(salon);
    final km =
        salon.distance > 0 ? '${salon.distance.toStringAsFixed(1)} km' : '';
    return [services, km].where((p) => p.isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final image =
        salon.images.isNotEmpty ? salon.images.first : salon.salonImage;
    final detail = detailLine(salon);
    final area = salon.displayAddress.trim();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: removed ? 0 : 1,
        child: removed
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: HomeDesignTokens.surface,
                      borderRadius:
                          BorderRadius.circular(HomeDesignTokens.cardRadius.r),
                      border: Border.all(color: HomeDesignTokens.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: SizedBox(
                            width: 92.w,
                            height: 104.h,
                            child: SalonNetworkImage(
                              imageUrl: image,
                              width: 92.w,
                              height: 104.h,
                              logTag: 'FavoriteSalonCard',
                            ),
                          ),
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
                                  GestureDetector(
                                    key: const Key('fav_heart'),
                                    onTap: onRemove,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 6.w),
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        size: 22.w,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (salon.reviewCount > 0) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Container(
                                      key: const Key('fav_rating_pill'),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: HomeDesignTokens.ratingPillBg,
                                        borderRadius:
                                            BorderRadius.circular(6.r),
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
                                              color: HomeDesignTokens
                                                  .ratingPillText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '(${salon.reviewCount})',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: HomeDesignTokens.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (detail.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Text(
                                  detail,
                                  key: const Key('fav_detail'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: HomeDesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                              if (area.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  area,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: HomeDesignTokens.textHint,
                                  ),
                                ),
                              ],
                              if (salon.offerBadge != null) ...[
                                SizedBox(height: 6.h),
                                Text(
                                  salon.offerBadge!.label,
                                  key: const Key('fav_offer'),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: HomeDesignTokens.offerGreen,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
