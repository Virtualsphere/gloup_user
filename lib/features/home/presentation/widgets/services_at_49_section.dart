import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/home/presentation/pages/services_at_49_page.dart';
import 'package:tressy/core/utils/category_image_resolver.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/category_image.dart';

/// Figma Gloup-Onboarding-screens node 2548:2797 / Frame 4844
const _serviceSubtitleGrey = Color(0xFF727272);
const _tabInactiveText = Color(0xFF6B7280);
const _seeAllBlack = Color(0xFF000000);

/// Figma Frame 1912054785 — MEN/WOMEN tab bar
const _genderTabHeight = 44.0;
const _genderTabDesignWidth = 189.0;
const _genderTabRadiusSmall = 8.0;
const _genderTabRadiusLarge = 20.0;
const _menTabBorderColor = Color.fromRGBO(12, 140, 233, 0.09);
const _womenTabBorderColor = Color.fromRGBO(104, 93, 220, 0.09);
const _genderTabGlowBlurSigma = 46.825;
const _genderTabGlowWidth = 96.45;
const _genderTabGlowHeight = 46.45;
const _genderTabGlowLeft = -8.02;
const _genderTabGlowTop = -5.79;

/// Vector brush (ic_vector_47) — Figma fill #0C8CE9 @ 21% (men)
const _menBrushFill = Color.fromRGBO(12, 140, 233, 0.21);

/// Vector brush — Figma women tint #685DDC @ 19%
const _womenBrushFill = Color.fromRGBO(104, 93, 220, 0.19);

/// Figma Frame 1912054784 — header bar
const _headerBarHeight = 67.0;
const _headerLeftBlockPadding = EdgeInsets.all(10);
const _headerLeftBlockGap = 6.0;
const _titleColumnGap = 4.0;
const _servicesTitleRowHeight = 28.0;
const _brushFrameWidth = 92.0;
const _brushFrameHeight = 40.0;
const _brushHeight = 43.79;
const _seeAllRowGap = 4.0;
const _seeAllRowHeight = 17.0;

const _titleTextHeight = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);

/// Men SERVICES / @₹49 — Figma linear-gradient 180deg
const _menTitleGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0C8CE9), Color(0xFF04487A)],
  stops: [0.2343, 1.0],
);

/// Men panel fill — Rectangle 53: rgba(0, 187, 255, 0.07)
const _menPanelFill = Color.fromRGBO(0, 187, 255, 0.07);

/// Frame 4844 outer wash (both genders)
const _panelOuterWash = Color.fromRGBO(255, 255, 255, 0.08);

/// Figma Frame 4844 — women SERVICES / @₹9 gradient
const _womenTitleGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF685DDC), Color(0xFF10086F)],
  stops: [0.2343, 1.0],
);

/// Women panel fill — Rectangle 53: rgba(120, 62, 255, 0.07)
const _womenPanelFill = Color.fromRGBO(120, 62, 255, 0.07);

/// Figma layout (Frame 4844 / 1912054782)
const _contentHeaderPadding = EdgeInsets.fromLTRB(4, 13, 4, 0);
const _cardsRowHeight = 121.0;
const _cardsRowPadding = EdgeInsets.only(left: 13.57, right: 12);
const _cardGap = 16.0;
const _cardLabelGap = 12.0;

class _GenderSectionTheme {
  const _GenderSectionTheme({
    required this.tabColor,
    required this.contentColor,
    required this.tabAccentColor,
    required this.seeAllColor,
    required this.titleGradient,
    required this.brushFill,
    required this.servicePriceColor,
    required this.servicePriceFontSize,
    required this.servicePriceFontWeight,
    required this.priceBadgeFontWeight,
    required this.priceBadgeFontSize,
  });

  final Color tabColor;
  final Color contentColor;
  final Color tabAccentColor;
  final Color seeAllColor;
  final LinearGradient titleGradient;
  final Color brushFill;
  final Color servicePriceColor;
  final double servicePriceFontSize;
  final FontWeight servicePriceFontWeight;
  final FontWeight priceBadgeFontWeight;
  final double priceBadgeFontSize;
}

const _menTheme = _GenderSectionTheme(
  tabColor: Color(0xFFF2F9FD),
  contentColor: _menPanelFill,
  tabAccentColor: Color(0xFF0C8CE9),
  seeAllColor: _seeAllBlack,
  titleGradient: _menTitleGradient,
  brushFill: _menBrushFill,
  servicePriceColor: _seeAllBlack,
  servicePriceFontSize: 12,
  servicePriceFontWeight: FontWeight.w500,
  priceBadgeFontWeight: FontWeight.w700,
  priceBadgeFontSize: 20,
);

/// Women — Figma Frame 4844 (2573:5921)
const _womenTheme = _GenderSectionTheme(
  tabColor: Color(0xFFF6F1FE),
  contentColor: _womenPanelFill,
  tabAccentColor: Color(0xFF685DDC),
  seeAllColor: _seeAllBlack,
  titleGradient: _womenTitleGradient,
  brushFill: _womenBrushFill,
  servicePriceColor: _seeAllBlack,
  servicePriceFontSize: 12,
  servicePriceFontWeight: FontWeight.w500,
  priceBadgeFontWeight: FontWeight.w700,
  priceBadgeFontSize: 20,
);

class ServicesAt49Section extends StatefulWidget {
  const ServicesAt49Section({super.key});

  @override
  State<ServicesAt49Section> createState() => _ServicesAt49SectionState();
}

class _ServicesAt49SectionState extends State<ServicesAt49Section> {
  bool _isMenSelected = true;

  bool _isLoading = true;
  List<Map<String, String>> _menItems = [];
  List<Map<String, String>> _womenItems = [];

  String _categoryImagePath(String categoryName, {String? apiImage}) {
    return CategoryImageResolver.resolveImagePath(
      categoryName: categoryName,
      imageUrl: apiImage,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final dio = sl<DioClient>();

      final menRes =
          await dio.post(ApiRoutes.getTopCategories, data: {'sex': 'male'});
      if (menRes.statusCode == 200 && menRes.data['success'] == true) {
        final List data = menRes.data['data'];
        _menItems = data
            .map((e) {
              final name = e['category_name'].toString();
              return <String, String>{
                'id': e['category_id'].toString(),
                'title': name,
                'price': '₹${e['discounted_amount']}',
                'img': _categoryImagePath(
                  name,
                  apiImage: CategoryImageResolver.apiImageFromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                ),
              };
            })
            .toList();
      }

      final womenRes =
          await dio.post(ApiRoutes.getTopCategories, data: {'sex': 'female'});
      if (womenRes.statusCode == 200 && womenRes.data['success'] == true) {
        final List data = womenRes.data['data'];
        _womenItems = data
            .map((e) {
              final name = e['category_name'].toString();
              return <String, String>{
                'id': e['category_id'].toString(),
                'title': name,
                'price': '₹${e['discounted_amount']}',
                'img': _categoryImagePath(
                  name,
                  apiImage: CategoryImageResolver.apiImageFromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                ),
              };
            })
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching top categories: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final theme = _isMenSelected ? _menTheme : _womenTheme;
    final title = _isMenSelected ? 'Basics for Men' : 'Basics for Women';
    final priceTag = _isMenSelected ? '@₹49' : '@₹9';
    final currentItems = _isMenSelected ? _menItems : _womenItems;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, AppSizes.paddingM, 12, AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGenderTabs(isDarkMode),
          Container(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : _panelOuterWash,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_isMenSelected ? 0 : 8),
                topRight: Radius.circular(_isMenSelected ? 8 : 0),
                bottomLeft: const Radius.circular(8),
                bottomRight: const Radius.circular(8),
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : theme.contentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_isMenSelected ? 0 : 8),
                  topRight: Radius.circular(_isMenSelected ? 8 : 0),
                  bottomLeft: const Radius.circular(8),
                  bottomRight: const Radius.circular(8),
                ),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServicesHeaderBar(
                  context,
                  isDarkMode: isDarkMode,
                  theme: theme,
                  priceTag: priceTag,
                  subtitle: title,
                ),
                SizedBox(
                  height: _cardsRowHeight,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : currentItems.isEmpty
                          ? Center(
                              child: Text(
                                'No services found',
                                style: GoogleFonts.inter(
                                  color: _serviceSubtitleGrey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              padding: _cardsRowPadding,
                              itemCount: currentItems.length,
                              itemBuilder: (context, index) {
                                final item = currentItems[index];
                                return _buildServiceCard(
                                  context,
                                  theme: theme,
                                  title: item['title']!,
                                  price: item['price']!,
                                  imageUrl: item['img']!,
                                  id: item['id'] ?? '',
                                );
                              },
                            ),
                ),
                const SizedBox(height: 12),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderTabs(bool isDarkMode) {
    return SizedBox(
      height: _genderTabHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _genderTab(
              label: 'MEN',
              isSelected: _isMenSelected,
              isLeft: true,
              isDarkMode: isDarkMode,
              theme: _menTheme,
              borderColor: _menTabBorderColor,
              onTap: () => setState(() => _isMenSelected = true),
            ),
          ),
          Expanded(
            child: _genderTab(
              label: 'WOMEN',
              isSelected: !_isMenSelected,
              isLeft: false,
              isDarkMode: isDarkMode,
              theme: _womenTheme,
              borderColor: _womenTabBorderColor,
              onTap: () => setState(() => _isMenSelected = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderTab({
    required String label,
    required bool isSelected,
    required bool isLeft,
    required bool isDarkMode,
    required _GenderSectionTheme theme,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final borderRadius = isSelected
        ? BorderRadius.only(
            topLeft: Radius.circular(isLeft ? _genderTabRadiusSmall : _genderTabRadiusLarge),
            topRight: Radius.circular(isLeft ? _genderTabRadiusLarge : _genderTabRadiusSmall),
          )
        : BorderRadius.zero;

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthScale = constraints.maxWidth / _genderTabDesignWidth;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              if (isSelected && !isDarkMode)
                Positioned(
                  left: _genderTabGlowLeft * widthScale,
                  top: _genderTabGlowTop,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _genderTabGlowBlurSigma,
                      sigmaY: _genderTabGlowBlurSigma,
                    ),
                    child: Container(
                      width: _genderTabGlowWidth * widthScale,
                      height: _genderTabGlowHeight,
                      decoration: BoxDecoration(
                        color: theme.tabAccentColor,
                        borderRadius: BorderRadius.circular(_genderTabGlowHeight / 2),
                      ),
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: borderRadius,
                  border: isSelected
                      ? Border(
                          top: BorderSide(color: borderColor, width: 1),
                          left: BorderSide(color: borderColor, width: 1),
                          right: BorderSide(color: borderColor, width: 1),
                        )
                      : null,
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    height: 15 / 12,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : theme.tabAccentColor)
                        : (isDarkMode ? Colors.white54 : _tabInactiveText),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Figma Frame 1912054784 — 370×67, space-between + left block 4783.
  Widget _buildServicesHeaderBar(
    BuildContext context, {
    required bool isDarkMode,
    required _GenderSectionTheme theme,
    required String priceTag,
    required String subtitle,
  }) {
    return Padding(
      padding: _contentHeaderPadding,
      child: SizedBox(
        height: _headerBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: _headerLeftBlockPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: _servicesTitleRowHeight,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildServicesTitle(theme),
                        ),
                      ),
                      SizedBox(height: _titleColumnGap),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: isDarkMode
                              ? Colors.white70
                              : _serviceSubtitleGrey,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          height: 15 / 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: _headerLeftBlockGap),
                  _buildPriceBadge(priceTag, theme),
                ],
              ),
            ),
            _buildSeeAllLink(
              context,
              isDarkMode: isDarkMode,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTitle(_GenderSectionTheme theme) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => theme.titleGradient.createShader(bounds),
      child: RichText(
        textHeightBehavior: _titleTextHeight,
        text: TextSpan(
          style: GoogleFonts.rowdies(
            fontWeight: FontWeight.w400,
            height: 1,
          ),
          children: const [
            TextSpan(text: 'S', style: TextStyle(fontSize: 32, height: 1)),
            TextSpan(
              text: 'ERVICES',
              style: TextStyle(fontSize: 20, letterSpacing: 0.5, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  /// Figma Frame 1912054778 — 92×40, vector @ -2.05px.
  Widget _buildPriceBadge(String priceTag, _GenderSectionTheme theme) {
    return SizedBox(
      width: _brushFrameWidth,
      height: _brushFrameHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0.13, -2.05),
            child: SvgPicture.asset(
              AppIcons.icVector47Brush,
              width: _brushFrameWidth,
              height: _brushHeight,
              fit: BoxFit.fill,
              theme: const SvgTheme(
                currentColor: Colors.black,
              ),
              colorFilter: ColorFilter.mode(
                theme.brushFill,
                BlendMode.srcIn,
              ),
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) =>
                theme.titleGradient.createShader(bounds),
            child: Text(
              priceTag,
              textHeightBehavior: _titleTextHeight,
              style: GoogleFonts.rowdies(
                fontWeight: theme.priceBadgeFontWeight,
                fontSize: theme.priceBadgeFontSize,
                height: 25 / 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllLink(
    BuildContext context, {
    required bool isDarkMode,
    required _GenderSectionTheme theme,
  }) {
    final color = isDarkMode ? AppColors.textPrimaryDark : theme.seeAllColor;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesAt49Page(
              sex: _isMenSelected ? 'male' : 'female',
            ),
          ),
        );
      },
      child: SizedBox(
        height: _seeAllRowHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'See All',
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 17 / 14,
              ),
            ),
            SizedBox(width: _seeAllRowGap),
            Icon(
              Icons.chevron_right,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Figma 2548:2797 — 90×90 image, 8px radius, label + green price
  Widget _buildServiceCard(
    BuildContext context, {
    required _GenderSectionTheme theme,
    required String title,
    required String price,
    required String imageUrl,
    required String id,
  }) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesAt49Page(
              initialCategory: title,
              categoryId: id,
              sex: _isMenSelected ? 'male' : 'female',
            ),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: _cardGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CategoryImage(
                    categoryName: title,
                    imageUrl: imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ),
            SizedBox(height: _cardLabelGap),
            RichText(
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 12,
                    height: 15 / 12,
                  ),
                  children: [
                    TextSpan(text: '$title '),
                    TextSpan(
                      text: price,
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? Colors.white
                            : theme.servicePriceColor,
                        fontWeight: theme.servicePriceFontWeight,
                        fontSize: theme.servicePriceFontSize,
                        height: theme.servicePriceFontSize == 12
                            ? 15 / 12
                            : 1,
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
}
