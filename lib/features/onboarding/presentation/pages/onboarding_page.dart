import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<String> _onboardingBackgrounds = [
    'assets/splash/splash_bg_01.png',
    'assets/splash/splash_bg_02.png',
    'assets/splash/splash_bg_03.png',
  ];

  final List<Map<String, String>> _onboardingContent = [
    {
      'title': 'Salon. Spa. Style. All in One App',
      'content': 'No more waiting – find salons near you instantly!\nExclusive Offers & Discounts available\nSmart Beauty Starts Here!',
    },
    {
      'title': 'Save Time, Look Gorgeous!',
      'content': 'No more waiting – find salons near you instantly!\nExclusive Offers & Discounts available\nSmart Beauty Starts Here!',
    },
    {
      'title': 'One App. Endless Beauty Choices.',
      'content': '800+ Verified Salons\n3000+ Services at your fingertips\nBeauty, Spa & Self-Care – Made Simple!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingBackgrounds.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    // Navigate to login or auth screen
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background PageView with Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _onboardingBackgrounds.length,
            physics: const PageScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                color: AppColors.background,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    Image.asset(
                      _onboardingBackgrounds[index],
                      fit: BoxFit.cover,
                    ),
                    // Content Overlay - positioned above bottom controls
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 160,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              _onboardingContent[index]['title']!,
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            AppSizes.heightXL,
                            // Content
                            Text(
                              _onboardingContent[index]['content']!,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Bottom Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSizes.paddingXL,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingBackgrounds.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  AppSizes.heightL,
                  
                  // Skip and Next Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingL,
                            vertical: AppSizes.paddingM,
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // Next Button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingXL,
                            vertical: AppSizes.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          ),
                        ),
                        child: Text(
                          _currentPage == _onboardingBackgrounds.length - 1 
                            ? 'Get Started' 
                            : 'Next',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive 
          ? AppColors.primary 
          : AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
