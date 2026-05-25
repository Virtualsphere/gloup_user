import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/home/presentation/pages/services_at_49_page.dart';
import 'dart:math' as math;

class ServicesAt49Section extends StatelessWidget {
  const ServicesAt49Section({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A3326) : const Color(0xFFE8F5E9);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingS),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : const Color(0xFFD0E8D7),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
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
                                  color: const Color(0xFF1B8A44),
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
                              angle: -0.05, // Slight rotation
                              child: Transform(
                                transform: Matrix4.skewX(-0.1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFB9E5C9),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    '@₹49',
                                    style: context.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF0F6E33),
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
                          'Basic Haircut for Men',
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
                              color: const Color(0xFF1B8A44),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF1B8A44),
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                children: [
                  _buildServiceCard(
                    context,
                    title: 'Haircut',
                    price: '₹49',
                    imageUrl: 'https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=500&q=80',
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Nails',
                    price: '₹49',
                    imageUrl: 'https://images.unsplash.com/photo-1519014816548-bf5fe059e98b?w=500&q=80',
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Massage',
                    price: '₹49',
                    imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=500&q=80',
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Facial',
                    price: '₹49',
                    imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=500&q=80',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
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
                    color: Colors.black.withValues(alpha: 0.05),
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
