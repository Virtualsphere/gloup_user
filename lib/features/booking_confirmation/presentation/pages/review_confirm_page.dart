import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/widgets/offer_banner.dart';
import 'package:tressy/shared/widgets/salon_info_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/selected_services_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/profile_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/add_person_bottom_sheet.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/edit_person_bottom_sheet.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/coupon_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/coupons_bottom_sheet.dart';
import 'package:tressy/shared/widgets/coupon_applied_dialog.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/billing_summary_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/recommended_service_card.dart';
import 'package:tressy/shared/widgets/primary_button.dart';

class ReviewConfirmPage extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const ReviewConfirmPage({
    super.key,
    this.bookingData,
  });

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  String selectedBookingFor = 'myself'; // 'myself' or 'someone_else'
  int? selectedSomeoneElseIndex; // selected index for someone else profiles
  String? selectedCouponCode;

  // TODO: Replace with actual coupon data from API/state
  final List<CouponData> availableCoupons = [
    CouponData(discountAmount: 50, couponCode: 'GLOUP2026'),
    CouponData(discountAmount: 100, couponCode: 'SAVE100'),
    CouponData(discountAmount: 75, couponCode: 'WELCOME75'),
    CouponData(discountAmount: 150, couponCode: 'MEGA150'),
  ];

  // Calculate highest offer percentage from selected services
  int get _highestOfferPercentage {
    if (widget.bookingData == null) return 0;

    final selectedServices = widget.bookingData!['selectedServices'] as List?;
    if (selectedServices == null || selectedServices.isEmpty) return 0;

    return selectedServices
        .where((service) => service['discountPercentage'] != null)
        .map((service) {
      final discountStr = service['discountPercentage'] as String;
      final discountInt =
          int.tryParse(discountStr.replaceAll('%', '').trim()) ?? 0;
      return discountInt;
    }).fold<int>(0, (max, discount) => discount > max ? discount : max);
  }

  // Calculate total service amount from selected services (original prices)
  double get _totalServiceAmount {
    if (widget.bookingData == null) return 0.0;

    final selectedServices = widget.bookingData!['selectedServices'] as List?;
    if (selectedServices == null || selectedServices.isEmpty) return 0.0;

    return selectedServices.fold<double>(0.0, (total, service) {
      final price = service['price'];
      if (price == null) return total;
      
      // 'price' field contains the ORIGINAL price (before discount)
      // Handle both String and numeric types
      if (price is num) {
        return total + price.toDouble();
      } else if (price is String) {
        // Remove ₹ symbol and parse
        final parsedPrice = double.tryParse(price.replaceAll('₹', '').trim()) ?? 0.0;
        return total + parsedPrice;
      }
      return total;
    });
  }

  // Calculate total service discount from selected services
  double get _totalServiceDiscount {
    if (widget.bookingData == null) return 0.0;

    final selectedServices = widget.bookingData!['selectedServices'] as List?;
    if (selectedServices == null || selectedServices.isEmpty) return 0.0;

    return selectedServices.fold<double>(0.0, (total, service) {
      final priceValue = service['price'];
      final discountPercentageStr = service['discountPercentage'] as String?;
      
      if (priceValue == null || discountPercentageStr == null || discountPercentageStr.isEmpty) {
        return total;
      }
      
      // Parse original price
      double originalPrice = 0.0;
      if (priceValue is num) {
        originalPrice = priceValue.toDouble();
      } else if (priceValue is String) {
        originalPrice = double.tryParse(priceValue.replaceAll('₹', '').trim()) ?? 0.0;
      }
      
      // Parse discount percentage
      final discountPercent = int.tryParse(
        discountPercentageStr.replaceAll('%', '').trim(),
      ) ?? 0;
      
      if (discountPercent <= 0) return total;
      
      // Calculate discount amount: originalPrice * (discountPercent / 100)
      final discountAmount = originalPrice * (discountPercent / 100);
      return total + discountAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review & Confirm',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Offer banner below app bar
          OfferBanner(discountPercentage: _highestOfferPercentage),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Padding for bottom button
              child: Column(
                children: [
                  if (widget.bookingData != null) ...[
                    // Salon info card with date and time
                    SalonInfoCard(
                      salonName: widget.bookingData!['salonName'] as String? ?? 'N/A',
                      salonImage: widget.bookingData!['salonImage'] as String?,
                      rating: widget.bookingData!['rating'] as double? ?? 0.0,
                      reviewCount: widget.bookingData!['reviewCount'] as int? ?? 0,
                      gender: widget.bookingData!['gender'] as String? ?? 'N/A',
                      address: widget.bookingData!['address'] as String? ?? 'N/A',
                      isPremium: widget.bookingData!['isPremium'] as bool? ?? false,
                      selectedDate: widget.bookingData!['selectedDate'] as String?,
                      selectedTimeSlot:
                          widget.bookingData!['selectedTimeSlot'] as String?,
                    ),
                    // Selected services card
                    SelectedServicesCard(
                      services: (widget.bookingData!['selectedServices'] as List?)
                              ?.cast<Map<String, dynamic>>() ??
                          [],
                    ),
                    const SizedBox(height: AppSizes.spaceM),
                    // Who is this booking for section
                    _buildSectionTitle(context, 'Who is this booking for?', isDarkMode),
                    const SizedBox(height: AppSizes.spaceS),
                    // Booking for selector (Myself / Someone else)
                    _buildBookingForSelector(context, isDarkMode),
                    const SizedBox(height: AppSizes.spaceM),
                    // Profile card (shown when "Myself" is selected)
                    if (selectedBookingFor == 'myself')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                        child: ProfileCard(
                          name: 'John Doe', // TODO: Replace with actual user data
                          age: 28, // TODO: Replace with actual user data
                          gender: 'Male', // TODO: Replace with actual user data
                          isSelected: true, // Always selected for "Myself"
                          onEdit: () {
                            showEditPersonBottomSheet(
                              context,
                              initialName: 'John Doe',
                              initialAge: 28,
                              initialGender: 'Male',
                              initialPhone: null, // TODO: Get from user profile
                              onSave: (result) {
                                // TODO: Save updated profile to backend/local storage
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Profile updated: ${result.fullName}'),
                                  ),
                                );
                                setState(() {
                                  // Update local state if needed
                                });
                              },
                            );
                          },
                        ),
                      ),
                    // Someone else cards (two selectable profiles)
                    if (selectedBookingFor == 'someone_else')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                        child: Column(
                          children: [
                            ProfileCard(
                              name: 'Priya Sharma', // TODO: Replace with actual data
                              age: 26,
                              gender: 'Female',
                              isSelected: selectedSomeoneElseIndex == 0,
                              onTap: () {
                                setState(() {
                                  selectedSomeoneElseIndex = 0;
                                });
                              },
                              onEdit: () {
                                showEditPersonBottomSheet(
                                  context,
                                  initialName: 'Priya Sharma',
                                  initialAge: 26,
                                  initialGender: 'Female',
                                  initialPhone: null,
                                  onSave: (result) {
                                    // TODO: Update profile in list
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Profile updated: ${result.fullName}'),
                                      ),
                                    );
                                    setState(() {
                                      // Update profile data
                                    });
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceM),
                            ProfileCard(
                              name: 'Rahul Verma', // TODO: Replace with actual data
                              age: 30,
                              gender: 'Male',
                              isSelected: selectedSomeoneElseIndex == 1,
                              onTap: () {
                                setState(() {
                                  selectedSomeoneElseIndex = 1;
                                });
                              },
                              onEdit: () {
                                showEditPersonBottomSheet(
                                  context,
                                  initialName: 'Rahul Verma',
                                  initialAge: 30,
                                  initialGender: 'Male',
                                  initialPhone: null,
                                  onSave: (result) {
                                    // TODO: Update profile in list
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Profile updated: ${result.fullName}'),
                                      ),
                                    );
                                    setState(() {
                                      // Update profile data
                                    });
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: AppSizes.spaceM),
                            // Add a New Person card-styled button
                            GestureDetector(
                              onTap: () {
                                showAddPersonBottomSheet(
                                  context,
                                  onAdd: (result) {
                                    // Example: append to list or set selection
                                    setState(() {
                                      selectedSomeoneElseIndex = 0; // adjust per your data model
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added "+${result.fullName}"'),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 72.0),
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                  border: Border.all(
                                    color: isDarkMode ? AppColors.borderDark : AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: (AppColors.primary).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          size: 22,
                                          color: isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.spaceM),
                                    Expanded(
                                      child: Text(
                                        'Add a New Person',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSizes.spaceL),
                    // Coupons & Offers section
                    _buildSectionTitle(context, 'Coupons & Offers', isDarkMode),
                    const SizedBox(height: AppSizes.spaceS),
                    // Show first coupon or selected coupon
                    if (availableCoupons.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                        child: () {
                          // Find selected coupon or show first one
                          final displayCoupon = selectedCouponCode != null
                              ? availableCoupons.firstWhere(
                                  (c) => c.couponCode == selectedCouponCode,
                                  orElse: () => availableCoupons.first,
                                )
                              : availableCoupons.first;

                          return CouponCard(
                            discountAmount: displayCoupon.discountAmount,
                            couponCode: displayCoupon.couponCode,
                            isSelected: selectedCouponCode == displayCoupon.couponCode,
                            onTap: () async {
                              final newSelection = selectedCouponCode == displayCoupon.couponCode
                                  ? null
                                  : displayCoupon.couponCode;
                              
                              setState(() {
                                selectedCouponCode = newSelection;
                              });

                              // Show success dialog when applying a coupon
                              if (newSelection != null) {
                                await CouponAppliedDialog.show(
                                  context,
                                  couponCode: displayCoupon.couponCode,
                                  discountAmount: displayCoupon.discountAmount,
                                );
                              }
                            },
                          );
                        }(),
                      ),
                    const SizedBox(height: AppSizes.spaceM),
                    // View all coupons link
                    if (availableCoupons.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await showCouponsBottomSheet(
                              context,
                              coupons: availableCoupons,
                              selectedCouponCode: selectedCouponCode,
                            );
                            if (result != null && result != selectedCouponCode) {
                              setState(() {
                                selectedCouponCode = result;
                              });
                              
                              // Show success dialog when applying from bottom sheet
                              final selectedCoupon = availableCoupons.firstWhere(
                                (c) => c.couponCode == result,
                              );
                              await CouponAppliedDialog.show(
                                context,
                                couponCode: selectedCoupon.couponCode,
                                discountAmount: selectedCoupon.discountAmount,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'View all coupons',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDarkMode
                                          ? AppColors.primaryDarkTheme
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: isDarkMode
                                    ? AppColors.primaryDarkTheme
                                    : AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSizes.spaceL),
                    // Billing Summary section
                    _buildSectionTitle(context, 'Billing Summary', isDarkMode),
                    const SizedBox(height: AppSizes.spaceS),
                    BillingSummaryCard(
                      serviceAmount: _totalServiceAmount,
                      couponDiscount: selectedCouponCode != null
                          ? availableCoupons
                              .firstWhere((c) => c.couponCode == selectedCouponCode)
                              .discountAmount
                              .toDouble()
                          : null,
                      appliedCouponCode: selectedCouponCode,
                      serviceDiscount: _totalServiceDiscount,
                      gstPercentage: 5.0,
                      platformFee: 7.0,
                      isPlatformFeeWaived: true,
                      gloupCash: 70.0,
                    ),
                    const SizedBox(height: AppSizes.spaceL),
                    // You might also like section
                    _buildSectionTitle(context, 'You might also like', isDarkMode),
                    const SizedBox(height: AppSizes.spaceS),
                    // Recommended services horizontal scroll
                    _buildRecommendedServices(context, isDarkMode),
                    const SizedBox(height: AppSizes.spaceXXXL),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable title widget
  Widget _buildSectionTitle(BuildContext context, String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
        ),
      ),
    );
  }

  // Booking for selector (Myself / Someone else)
  Widget _buildBookingForSelector(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        children: [
          // Myself button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBookingFor = 'myself';
                  selectedSomeoneElseIndex = null; // clear someone else selection
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                  horizontal: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: selectedBookingFor == 'myself'
                      ? (isDarkMode ? AppColors.primaryDark : AppColors.primary)
                      : (isDarkMode ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: selectedBookingFor != 'myself'
                      ? Border.all(
                          color: isDarkMode ? AppColors.borderDark : AppColors.border,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: selectedBookingFor == 'myself'
                          ? AppColors.white
                          : (isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    ),
                    const SizedBox(width: AppSizes.spaceXS),
                    Text(
                      'Myself',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: selectedBookingFor == 'myself'
                                ? AppColors.white
                                : (isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          // Someone else button
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBookingFor = 'someone_else';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                  horizontal: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  color: selectedBookingFor == 'someone_else'
                      ? (isDarkMode ? AppColors.primaryDark : AppColors.primary)
                      : (isDarkMode ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: selectedBookingFor != 'someone_else'
                      ? Border.all(
                          color: isDarkMode ? AppColors.borderDark : AppColors.border,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: selectedBookingFor == 'someone_else'
                          ? AppColors.white
                          : (isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    ),
                    const SizedBox(width: AppSizes.spaceXS),
                    Text(
                      'Someone else',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: selectedBookingFor == 'someone_else'
                                ? AppColors.white
                                : (isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedServices(BuildContext context, bool isDarkMode) {
    if (widget.bookingData == null) return const SizedBox.shrink();

    final allServices = widget.bookingData!['allServices'] as List?;
    final selectedServices = widget.bookingData!['selectedServices'] as List?;

    if (allServices == null || allServices.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get selected service names to filter them out
    final selectedServiceNames = selectedServices
        ?.map((s) => s['name'] as String?)
        .where((name) => name != null)
        .toSet() ?? {};

    // Filter out already selected services
    final recommendedServices = allServices.where((service) {
      final serviceName = service['name'] as String?;
      return serviceName != null && !selectedServiceNames.contains(serviceName);
    }).toList();

    if (recommendedServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: recommendedServices.length,
        itemBuilder: (context, index) {
          final service = recommendedServices[index];
          final name = service['name'] as String? ?? 'N/A';
          final duration = service['duration'] as String? ?? 'N/A';
          final priceValue = service['price'];
          final discountPercentage = service['discountPercentage'] as String?;

          // Parse price
          double price = 0.0;
          if (priceValue is num) {
            price = priceValue.toDouble();
          } else if (priceValue is String) {
            price = double.tryParse(priceValue.replaceAll('₹', '').trim()) ?? 0.0;
          }

          return RecommendedServiceCard(
            name: name,
            duration: duration,
            price: price,
            discountPercentage: discountPercentage,
            onAdd: () {
              // TODO: Add service to selection
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "$name" to booking'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
