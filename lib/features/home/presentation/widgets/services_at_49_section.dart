import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/home/presentation/pages/services_at_49_page.dart';
import 'dart:math' as math;

class ServicesAt49Section extends StatefulWidget {
  const ServicesAt49Section({super.key});

  @override
  State<ServicesAt49Section> createState() => _ServicesAt49SectionState();
}

class _ServicesAt49SectionState extends State<ServicesAt49Section> {
  bool _isMenSelected = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    // Men colors
    final menBgColor = isDarkMode ? const Color(0xFF0F1A24) : const Color(0xFFE4F3F8);
    final menTextColor = isDarkMode ? const Color(0xFF42A5F5) : const Color(0xFF0277BD);
    final menBrushColor = isDarkMode ? const Color(0xFF1976D2) : const Color(0xFFB3E5FC);

    // Women colors
    final womenBgColor = isDarkMode ? const Color(0xFF1E1324) : const Color(0xFFF3E5F5);
    final womenTextColor = isDarkMode ? const Color(0xFFAB47BC) : const Color(0xFF4A148C);
    final womenBrushColor = isDarkMode ? const Color(0xFF8E24AA) : const Color(0xFFE1BEE7);

    final currentBgColor = _isMenSelected ? menBgColor : womenBgColor;
    final currentTextColor = _isMenSelected ? menTextColor : womenTextColor;
    final currentBrushColor = _isMenSelected ? menBrushColor : womenBrushColor;
    final title = _isMenSelected ? 'Basics for Men' : 'Basics for Women';
    final priceTag = _isMenSelected ? '@₹49' : '@₹9';

    final menItems = [
      {'title': 'Haircut', 'price': '₹49', 'img': 'https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=500&q=80'},
      {'title': 'Shave', 'price': '₹19', 'img': 'https://images.unsplash.com/photo-1621607512214-68297480165e?w=500&q=80'},
      {'title': 'Trim', 'price': '₹19', 'img': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&q=80'},
      {'title': 'De-Tan', 'price': '₹19', 'img': 'https://images.unsplash.com/photo-1519014816548-bf5fe059e98b?w=500&q=80'},
    ];

    final womenItems = [
      {'title': 'Eyebrow', 'price': '₹49', 'img': 'https://images.unsplash.com/photo-1516975080661-460d3fc3a3b2?w=500&q=80'},
      {'title': 'Nails', 'price': '₹49', 'img': 'https://images.unsplash.com/photo-1519014816548-bf5fe059e98b?w=500&q=80'},
      {'title': 'Facial', 'price': '₹49', 'img': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=500&q=80'},
      {'title': 'Bleach', 'price': '₹49', 'img': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=500&q=80'},
    ];

    final currentItems = _isMenSelected ? menItems : womenItems;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMenSelected = true),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isMenSelected ? menBgColor : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusL - 1),
                        topRight: Radius.circular(AppSizes.radiusL - 1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'MEN',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: _isMenSelected ? menTextColor : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMenSelected = false),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: !_isMenSelected ? womenBgColor : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusL - 1),
                        topRight: Radius.circular(AppSizes.radiusL - 1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'WOMEN',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: !_isMenSelected ? womenTextColor : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content Card
          Container(
            decoration: BoxDecoration(
              color: currentBgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_isMenSelected ? 0 : AppSizes.radiusL),
                topRight: Radius.circular(_isMenSelected ? AppSizes.radiusL : 0),
                bottomLeft: const Radius.circular(AppSizes.radiusL - 1),
                bottomRight: const Radius.circular(AppSizes.radiusL - 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSizes.paddingM,
                    right: AppSizes.paddingM,
                    top: AppSizes.paddingM,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: currentTextColor,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: context.textTheme.headlineMedium?.fontFamily,
                                    ),
                                    children: const [
                                      TextSpan(text: 'S', style: TextStyle(fontSize: 28, height: 1.0)),
                                      TextSpan(text: 'ERVICES', style: TextStyle(fontSize: 22, height: 1.0, letterSpacing: 0.5)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Brush stroke styled tag
                                Transform.rotate(
                                  angle: -0.05,
                                  child: Transform(
                                    transform: Matrix4.skewX(-0.1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: currentBrushColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(12),
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                      child: Text(
                                        priceTag,
                                        style: context.textTheme.titleMedium?.copyWith(
                                          color: currentTextColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? Colors.grey[400] : const Color(0xFF757575),
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ServicesAt49Page(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'See All',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 125,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                    itemCount: currentItems.length,
                    itemBuilder: (context, index) {
                      final item = currentItems[index];
                      return _buildServiceCard(
                        context,
                        title: item['title']!,
                        price: item['price']!,
                        imageUrl: item['img']!,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String price,
    required String imageUrl,
  }) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesAt49Page(initialCategory: title == 'Haircut' || title == 'Nails' || title == 'Massage' || title == 'Facial' ? title : 'All'),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(text: '$title '),
                  TextSpan(
                    text: price,
                    style: const TextStyle(
                      color: Color(0xFF1B8A44),
                      fontWeight: FontWeight.w800,
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
