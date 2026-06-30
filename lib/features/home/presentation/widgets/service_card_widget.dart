import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/features/home/presentation/widgets/service_item_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Visual tokens for men / women service card variants.
class ServiceCardTheme {
  const ServiceCardTheme({
    required this.cardBase,
    this.cardGradient,
    required this.cardOverlay,
    required this.titleGradient,
    required this.brushFill,
  });

  final Color cardBase;
  final Gradient? cardGradient;
  final Color cardOverlay;
  final LinearGradient titleGradient;
  final Color brushFill;

  static const men = ServiceCardTheme(
    cardBase: Color(0xFFF8F9FA),
    cardGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    ),
    cardOverlay: AppColors.servicesAt49CardOverlay,
    titleGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0C8CE9), Color(0xFF04487A)],
      stops: [0.2343, 1.0],
    ),
    brushFill: AppColors.servicesAt49MenBrushFill,
  );

  static const women = ServiceCardTheme(
    cardBase: Color(0xFFFAFAFA),
    cardGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFCFCFC), Color(0xFFF7F7F7)],
    ),
    cardOverlay: AppColors.servicesAt49WomenCardOverlay,
    titleGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5A4FD8), Color(0xFF5A4FD8)],
    ),
    brushFill: AppColors.servicesAt49WomenBrushFill,
  );
}

/// Data for a single service row item.
class ServiceItemData {
  const ServiceItemData({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String price;
  final String imageUrl;
}

/// Figma Frame 4844 — 378×227 service card.
class ServiceCardWidget extends StatelessWidget {
  const ServiceCardWidget({
    super.key,
    required this.isMenSelected,
    required this.theme,
    required this.subtitle,
    required this.priceTag,
    required this.items,
    required this.isLoading,
    required this.onSeeAll,
    required this.onItemTap,
    this.isDarkMode = false,
  });

  static double get cardHeight => 230.0.h;
  static EdgeInsets get headerPadding =>
      EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h);
  static double get contentHorizontalPadding => 20.0.w;
  static double get headerListGap => 16.0.h;
  static double get itemGap => 12.0.w;

  final bool isMenSelected;
  final ServiceCardTheme theme;
  final String subtitle;
  final String priceTag;
  final List<ServiceItemData> items;
  final bool isLoading;
  final VoidCallback onSeeAll;
  final void Function(ServiceItemData item) onItemTap;
  final bool isDarkMode;

  static const _titleTextHeight = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  BorderRadius get _cardRadius => BorderRadius.only(
        topLeft: Radius.circular(isMenSelected ? 0 : 16),
        topRight: Radius.circular(isMenSelected ? 16 : 0),
        bottomLeft: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _cardRadius,
      child: Container(
        width: double.infinity,
        height: cardHeight,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : theme.cardBase,
          gradient: isDarkMode ? null : theme.cardGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!isDarkMode) ColoredBox(color: theme.cardOverlay),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: headerPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row 1: SERVICES + @₹49 + See All — all on same line
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ServicesTitle(
                            gradient: theme.titleGradient,
                          ),
                          SizedBox(width: 12.w),
                          SizedBox(
                            width: 92.w,
                            height: 40.h,
                            child: _PriceSticker(
                              priceTag: priceTag,
                              gradient: theme.titleGradient,
                              brushFill: theme.brushFill,
                            ),
                          ),
                          const Spacer(),
                          _SeeAllButton(
                            onTap: onSeeAll,
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                      // Row 2: Subtitle
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          height: 15 / 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode
                              ? Colors.white70
                              : (isMenSelected
                                  ? const Color(0xFF727272)
                                  : const Color(0xFF7A7A7A)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: headerListGap),
                Expanded(child: _buildServiceList()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No services found',
          style: GoogleFonts.inter(
            color: AppColors.servicesAt49Subtitle,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: contentHorizontalPadding),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: contentHorizontalPadding),
        clipBehavior: Clip.hardEdge,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: itemGap),
        itemBuilder: (context, index) {
          final item = items[index];
          return ServiceItemWidget(
            title: item.title,
            price: item.price,
            imageUrl: item.imageUrl,
            isDarkMode: isDarkMode,
            onTap: () => onItemTap(item),
          );
        },
      ),
    );
  }
}

class _ServicesTitle extends StatelessWidget {
  const _ServicesTitle({required this.gradient});

  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: RichText(
        textHeightBehavior: ServiceCardWidget._titleTextHeight,
        text: TextSpan(
          style: GoogleFonts.rowdies(
            fontWeight: FontWeight.w400,
            fontSize: 32.sp,
            height: 28 / 32,
          ),
          children: [
            const TextSpan(text: 'S'),
            TextSpan(
              text: 'ERVICES',
              style: TextStyle(fontSize: 20.sp, letterSpacing: 0.5, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma Frame 1912054778 — 92×40 brush sticker.
class _PriceSticker extends StatelessWidget {
  const _PriceSticker({
    required this.priceTag,
    required this.gradient,
    required this.brushFill,
  });

  final String priceTag;
  final LinearGradient gradient;
  final Color brushFill;

  static double get frameWidth => 92.0.w;
  static double get frameHeight => 40.0.h;
  static double get brushHeight => 43.79.h;
  static const stickerRotation = -0.05; // ~-3° counter-clockwise per Figma

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: stickerRotation,
      child: SizedBox(
        width: frameWidth,
        height: frameHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0.13, -2.05),
              child: SvgPicture.asset(
                AppIcons.icVector47Brush,
                width: frameWidth,
                height: brushHeight,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(brushFill, BlendMode.srcIn),
              ),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => gradient.createShader(bounds),
              child: Text(
                priceTag,
                textHeightBehavior: ServiceCardWidget._titleTextHeight,
                style: GoogleFonts.rowdies(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 25 / 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({
    required this.onTap,
    required this.isDarkMode,
  });

  final VoidCallback onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? AppColors.textPrimaryDark : AppColors.black;

    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'See All',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 17 / 14,
              color: color,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right, size: 16.w, color: color),
        ],
      ),
    );
  }
}
