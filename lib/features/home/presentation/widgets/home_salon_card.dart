import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/shared/widgets/login_bottom_sheet.dart';
import 'package:tressy/shared/widgets/salon_network_image.dart';

/// Salon card for the Home list (Figma 3-2): image with promoted tag, offer
/// badge and heart, then name, rating pill, services line and distance.
class HomeSalonCard extends StatelessWidget {
  final SalonEntity salon;
  final VoidCallback onTap;

  const HomeSalonCard({super.key, required this.salon, required this.onTap});

  static const int maxServicesShown = 3;

  /// 950 -> "950", 2100 -> "2.1k", 12000 -> "12k".
  static String compactCount(int n) {
    if (n < 1000) return '$n';
    final k = n / 1000;
    return k >= 10 || k == k.roundToDouble()
        ? '${k.round()}k'
        : '${k.toStringAsFixed(1)}k';
  }

  /// "Haircut · Facial · Spa" from `dynamicServices`, falling back to the
  /// single headline service. Empty when the salon lists nothing.
  static String servicesLine(SalonEntity salon) {
    final names = <String>[];
    for (final s in salon.dynamicServices ?? const <Map<String, dynamic>>[]) {
      final name = s['name']?.toString().trim() ?? '';
      if (name.isNotEmpty && !names.contains(name)) names.add(name);
      if (names.length == maxServicesShown) break;
    }
    if (names.isEmpty && (salon.serviceName?.trim().isNotEmpty ?? false)) {
      names.add(salon.serviceName!.trim());
    }
    return names.join(' · ');
  }

  /// "1.2 km · Anna Nagar"; parts are dropped when unknown.
  static String distanceLine(SalonEntity salon) {
    final parts = <String>[
      if (salon.distance > 0) '${salon.distance.toStringAsFixed(1)} km',
      if (salon.displayAddress.trim().isNotEmpty) salon.displayAddress.trim(),
    ];
    return parts.join(' · ');
  }

  void _toggleFavorite(BuildContext context, bool isFavorite) {
    if (!LocalStorageService.isLoggedIn) {
      LoginBottomSheet.show(context);
      return;
    }
    context.read<FavoritesBloc>().add(
          ToggleFavoriteEvent(int.tryParse(salon.id) ?? 0, isFavorite),
        );
  }

  @override
  Widget build(BuildContext context) {
    final storeId = int.tryParse(salon.id) ?? 0;
    final image =
        salon.images.isNotEmpty ? salon.images.first : salon.salonImage;
    final services = servicesLine(salon);
    final distance = distanceLine(salon);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: HomeDesignTokens.surface,
          borderRadius: BorderRadius.circular(HomeDesignTokens.cardRadius.r),
          border: Border.all(color: HomeDesignTokens.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 168.h,
                  width: double.infinity,
                  child: SalonNetworkImage(
                    imageUrl: image,
                    height: 168.h,
                    showErrorLabel: false,
                    logTag: 'HomeSalonCard',
                  ),
                ),
                if (salon.isPremium)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: _Tag(
                      key: const Key('promoted_tag'),
                      label: 'Promoted',
                      background: HomeDesignTokens.surface,
                      foreground: HomeDesignTokens.textPrimary,
                    ),
                  ),
                if (salon.offerBadge != null)
                  Positioned(
                    left: 10.w,
                    bottom: 10.h,
                    child: _Tag(
                      key: const Key('offer_badge'),
                      label: salon.offerBadge!.label,
                      background: HomeDesignTokens.offerBadgeBg,
                      foreground: HomeDesignTokens.offerBadgeText,
                    ),
                  ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, favorites) {
                      final isFavorite =
                          favorites.isFavorite(storeId, salon.isFavorite);
                      return GestureDetector(
                        key: const Key('favorite_button'),
                        onTap: () => _toggleFavorite(context, isFavorite),
                        child: Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: const BoxDecoration(
                            color: HomeDesignTokens.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20.w,
                            color: isFavorite
                                ? Colors.red
                                : HomeDesignTokens.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _RatingPill(rating: salon.rating),
                            SizedBox(height: 2.h),
                            Text(
                              '${compactCount(salon.reviewCount)} ratings',
                              key: const Key('rating_count'),
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: HomeDesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (services.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      services,
                      key: const Key('services_line'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: HomeDesignTokens.textSecondary,
                      ),
                    ),
                  ],
                  if (distance.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14.w, color: HomeDesignTokens.textHint),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            distance,
                            key: const Key('distance_line'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: HomeDesignTokens.textHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Tag({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;

  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('rating_pill'),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: HomeDesignTokens.ratingPillBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13.w, color: Colors.white),
          SizedBox(width: 2.w),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: HomeDesignTokens.ratingPillText,
            ),
          ),
        ],
      ),
    );
  }
}
