import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/booking_confirmation/data/models/order_model.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_bloc.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_event.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_state.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_bloc.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_event.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_state.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/guest_shimmers.dart';
import 'package:tressy/features/coupons/presentation/bloc/coupon_bloc.dart';
import 'package:tressy/features/coupons/presentation/bloc/coupon_event.dart';
import 'package:tressy/features/coupons/presentation/bloc/coupon_state.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/shared/widgets/offer_banner.dart';
import 'package:tressy/shared/widgets/salon_info_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/selected_services_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/profile_card.dart';
import 'package:tressy/shared/widgets/add_person_bottom_sheet.dart';
import 'package:tressy/shared/widgets/edit_person_bottom_sheet.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/coupon_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/coupons_bottom_sheet.dart';
import 'package:tressy/shared/widgets/coupon_applied_dialog.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/billing_summary_card.dart';
import 'package:tressy/features/booking_confirmation/presentation/widgets/recommended_service_card.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:tressy/shared/widgets/login_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/shared/widgets/payment_success_dialog.dart';
import 'package:tressy/shared/widgets/payment_failed_dialog.dart';

class ReviewConfirmPage extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const ReviewConfirmPage({
    super.key,
    this.bookingData,
  });

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> with WidgetsBindingObserver {
  String selectedBookingFor = 'myself'; // 'myself' or 'someone_else'
  int? selectedSomeoneElseIndex; // selected index for someone else profiles
  String? selectedCouponCode;
  bool useGloupCash = false; // Gloup Cash checkbox state
  List<Map<String, dynamic>> addedServices = []; // Track added recommended services
  List<CouponData> availableCoupons = []; // Coupons from API
  String? _lastPaymentId;
  late Razorpay _razorpay;
  late OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _orderBloc = sl<OrderBloc>();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _razorpay.clear();
    _orderBloc.close();
    super.dispose();
  }

  void _openRazorpay(String razorpayOrderId, double amount, String salonName) {
    final options = {
      'key': ApiRoutes.razorpayKey,
      'amount': (amount * 100).toInt(), // Razorpay expects paise
      'order_id': razorpayOrderId,
      'name': salonName,
      'description': 'Salon Booking Payment',
      'send_sms_hash': true,
      'prefill': {
        'contact': '',
      },
      'theme': {'color': '#000000'},
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _lastPaymentId = response.paymentId;
    _orderBloc.add(
      VerifyPaymentEvent(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _orderBloc.add(const ResetOrderEvent());
    if (mounted) {
      PaymentFailedDialog.show(
        context,
        message: response.message ?? 'Something went wrong. Please try again.',
        onRetry: () {
          // User can re-tap the Pay button to try again
        },
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    CustomToast.showInfo(
      context,
      'External wallet selected: ${response.walletName}',
    );
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      setState(() {
        // This will trigger rebuild and check login state again
      });
    }
  }

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

    // Combine original selected services and added services
    final allServices = [...selectedServices, ...addedServices];

    return allServices.fold<double>(0.0, (total, service) {
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

    // Combine original selected services and added services
    final allServices = [...selectedServices, ...addedServices];

    return allServices.fold<double>(0.0, (total, service) {
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
    final isLoggedIn = LocalStorageService.isLoggedIn && 
                       LocalStorageService.accessToken != null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ProfileBloc>()..add(const GetProfileEvent()),
        ),
        BlocProvider(
          create: (context) => sl<CouponBloc>()..add(const GetActiveCouponsEvent()),
        ),
        BlocProvider<OrderBloc>.value(value: _orderBloc),
      ],
      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, orderState) {
          if (orderState.isSuccess && orderState.order != null) {
            final order = orderState.order!;
            final salonName = widget.bookingData?['salonName'] as String? ?? 'Salon';
            _openRazorpay(order.razorpayOrderId, order.amount, salonName);
          } else if (orderState.isPaymentVerified) {
            PaymentSuccessDialog.show(
              context,
              paymentId: _lastPaymentId ?? '',
              onViewBooking: () {
                // Navigate to bookings screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          } else if (orderState.errorMessage != null) {
            // Show failed dialog if verification failed, else toast for order creation errors
            if (orderState.isVerifyingPayment == false && _lastPaymentId != null) {
              PaymentFailedDialog.show(
                context,
                message: orderState.errorMessage!,
                onRetry: () {},
              );
            } else {
              CustomToast.showError(context, orderState.errorMessage!);
            }
          }
        },
        child: Scaffold(
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
                    // Selected services card (including added services)
                    SelectedServicesCard(
                      services: [
                        ...((widget.bookingData!['selectedServices'] as List?)
                                ?.cast<Map<String, dynamic>>() ??
                            []),
                        ...addedServices,
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceM),
                    // Who is this booking for section - Only show if logged in
                    if (isLoggedIn) ...[
                      _buildSectionTitle(context, 'Who is this booking for?', isDarkMode),
                      const SizedBox(height: AppSizes.spaceS),
                      // Booking for selector (Myself / Someone else)
                      _buildBookingForSelector(context, isDarkMode),
                      const SizedBox(height: AppSizes.spaceM),
                    ],
                    // Profile card (shown when "Myself" is selected and logged in)
                    if (isLoggedIn && selectedBookingFor == 'myself')
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, profileState) {
                          // Show loading shimmer
                          if (profileState is ProfileLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // Show error state
                          if (profileState is ProfileFailure) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                              child: Center(
                                child: Text(
                                  profileState.message,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            );
                          }

                          // Get profile data
                          final profile = profileState is ProfileLoaded ? profileState.profile : null;
                          final userName = profile?.fullName ?? 'User';
                          final userGender = profile?.gender ?? 'Not Selected';
                          // Calculate age from date of birth if available
                          int? userAge;
                          if (profile?.dateOfBirth != null && profile!.dateOfBirth.isNotEmpty) {
                            userAge = _calculateAge(profile.dateOfBirth);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                            child: ProfileCard(
                              name: userName,
                              age: userAge ?? 0,
                              gender: userGender,
                              isSelected: true, // Always selected for "Myself"
                            
                            ),
                          );
                        },
                      ),
                    // Someone else cards (loaded from API and logged in)
                    if (isLoggedIn && selectedBookingFor == 'someone_else')
                      BlocConsumer<GuestBloc, GuestState>(
                        listener: (context, guestState) {
                          // Show success message when guest is added
                          if (guestState.addSuccessMessage != null) {
                            CustomToast.showSuccess(
                              context,
                              guestState.addSuccessMessage!,
                            );
                          }
                          // Show success message when guest is updated
                          if (guestState.updateSuccessMessage != null) {
                            CustomToast.showSuccess(
                              context,
                              guestState.updateSuccessMessage!,
                            );
                          }
                        },
                        builder: (context, guestState) {
                          // Show shimmer while loading
                          if (guestState.isLoading) {
                            return GuestShimmers.guestListShimmer(context);
                          }

                          // Show error state
                          if (guestState.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.all(AppSizes.paddingXL),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(height: AppSizes.spaceM),
                                    Text(
                                      guestState.errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: AppSizes.spaceM),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<GuestBloc>().add(const LoadGuestsEvent());
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Show guest list
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                            child: Column(
                              children: [
                                // Display all guests from API
                                ...List.generate(
                                  guestState.guests.length,
                                  (index) {
                                    final guest = guestState.guests[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
                                      child: ProfileCard(
                                        name: guest.name,
                                        age: guest.age,
                                        gender: guest.gender,
                                        isSelected: selectedSomeoneElseIndex == index,
                                        onTap: () {
                                          setState(() {
                                            selectedSomeoneElseIndex = index;
                                          });
                                          context.read<GuestBloc>().add(SelectGuestEvent(index));
                                        },
                                        onEdit: () {
                                          if (guest.guestId == null) return;
                                          
                                          showEditPersonBottomSheet(
                                            context,
                                            initialName: guest.name,
                                            initialAge: guest.age,
                                            initialGender: guest.gender,
                                            initialPhone: guest.phone,
                                            onSave: (result) {
                                              // Update guest via API
                                              context.read<GuestBloc>().add(
                                                    UpdateGuestEvent(
                                                      guestId: guest.guestId!,
                                                      name: result.fullName,
                                                      gender: result.gender,
                                                      age: result.age,
                                                      phone: result.phone,
                                                    ),
                                                  );
                                              
                                              CustomToast.showInfo(
                                                context,
                                                'Updating ${result.fullName}...',
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSizes.spaceM),
                                // Add a New Person card-styled button
                                GestureDetector(
                                  onTap: () {
                                    showAddPersonBottomSheet(context);
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
                          );
                        },
                      ),
                    const SizedBox(height: AppSizes.spaceL),
                    // Coupons & Offers section
                    _buildSectionTitle(context, 'Coupons & Offers', isDarkMode),
                    const SizedBox(height: AppSizes.spaceS),
                    // Show login message if not logged in, otherwise show coupons
                    if (!isLoggedIn)
                      Text(
                        'Sign in to access exclusive discounts and offers',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                    // Fetch coupons from BLoC
                    BlocBuilder<CouponBloc, CouponState>(
                      builder: (context, couponState) {
                        // Show loading state
                        if (couponState is CouponLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Show error state
                        if (couponState is CouponFailure) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                            child: Center(
                              child: Text(
                                couponState.message,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          );
                        }

                        // Get coupons from loaded state and convert to CouponData
                        final coupons = couponState is CouponLoaded ? couponState.coupons : [];
                        
                        // Update state with fetched coupons
                        if (couponState is CouponLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                availableCoupons = coupons.map(_convertToCouponData).toList();
                              });
                            }
                          });
                        }

                        if (availableCoupons.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                            child: Center(
                              child: Text(
                                'No coupons available',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          );
                        }

                        // Find selected coupon or show first one
                        final displayCoupon = selectedCouponCode != null
                            ? availableCoupons.firstWhere(
                                (c) => c.couponCode == selectedCouponCode,
                                orElse: () => availableCoupons.first,
                              )
                            : availableCoupons.first;

                        // Check if coupon can be applied
                        // Use discounted price (after service discount) for validation
                        final originalAmount = _totalServiceAmount;
                        final serviceDiscount = _totalServiceDiscount;
                        final discountedAmount = originalAmount - serviceDiscount;
                        final minAmountRequired = displayCoupon.discountAmount.toDouble();
                        final isCouponValid = (discountedAmount + 30) >= minAmountRequired;
                        final amountNeeded = minAmountRequired - discountedAmount - 30;
                        
                        // Auto-deselect coupon if it becomes invalid
                        if (!isCouponValid && selectedCouponCode == displayCoupon.couponCode) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                selectedCouponCode = null;
                              });
                              CustomToast.showWarning(
                                context,
                                'Coupon removed: Add more services to apply this coupon',
                              );
                            }
                          });
                        }
                        
                        String? disabledReason;
                        if (!isCouponValid) {
                          disabledReason = 'Add services worth ₹${amountNeeded.toStringAsFixed(0)} more to avail this coupon';
                        }

                        return Column(
                          children: [
                            // Show first coupon or selected coupon
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                              child: CouponCard(
                                discountAmount: displayCoupon.discountAmount,
                                couponCode: displayCoupon.couponCode,
                                isSelected: selectedCouponCode == displayCoupon.couponCode,
                                isEnabled: isCouponValid,
                                disabledReason: disabledReason,
                                onTap: () async {
                                  if (!isCouponValid) {
                                    CustomToast.showWarning(
                                      context,
                                      disabledReason ?? 'Cannot apply this coupon',
                                    );
                                    return;
                                  }
                                  
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
                              ),
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
                                      serviceAmount: _totalServiceAmount - _totalServiceDiscount,
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
                          ],
                        );
                      },
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
                      gloupCash: useGloupCash ? 70.0 : 0.0,
                    ),
                    const SizedBox(height: AppSizes.spaceL),
                    // You might also like section
                    _buildSectionTitle(context, 'You might also like', isDarkMode),
                    const SizedBox(height: AppSizes.spaceS),
                    // Recommended services horizontal scroll
                    _buildRecommendedServices(context, isDarkMode),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // _buildGloupCashCheckbox(context, isDarkMode),
          _buildBottomConfirmButton(context, isDarkMode, isLoggedIn),
        ],
      ),
      ),
      ),
    );
  }

  /// Convert CouponEntity to CouponData for UI compatibility
  CouponData _convertToCouponData(dynamic coupon) {
    return CouponData(
      discountAmount: coupon.discountAmount as int,
      couponCode: coupon.code as String,
    );
  }

  /// Calculate age from date of birth string
  /// Handles multiple date formats: YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY
  int? _calculateAge(String dateOfBirth) {
    if (dateOfBirth.isEmpty) return null;
    
    try {
      DateTime? birthDate;
      
      // Try YYYY-MM-DD format (2000-03-15)
      if (dateOfBirth.contains('-') && dateOfBirth.indexOf('-') == 4) {
        birthDate = DateTime.tryParse(dateOfBirth);
      }
      // Try DD/MM/YYYY format (15/03/2000)
      else if (dateOfBirth.contains('/')) {
        final parts = dateOfBirth.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            birthDate = DateTime(year, month, day);
          }
        }
      }
      // Try DD-MM-YYYY format (15-03-2000)
      else if (dateOfBirth.contains('-')) {
        final parts = dateOfBirth.split('-');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            birthDate = DateTime(year, month, day);
          }
        }
      }
      
      if (birthDate != null) {
        final today = DateTime.now();
        int age = today.year - birthDate.year;
        
        // Adjust age if birthday hasn't occurred yet this year
        if (today.month < birthDate.month || 
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        
        return age >= 0 ? age : null;
      }
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
    
    return null;
  }

  Widget _buildGloupCashCheckbox(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusM),
          topRight: Radius.circular(AppSizes.radiusM),
        ),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.divider,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: useGloupCash,
            onChanged: (value) {
              setState(() {
                useGloupCash = value ?? false;
              });
            },
            activeColor: isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSizes.spaceS),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Use Gloup Cash ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                children: [
                  TextSpan(
                    text: '₹70',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomConfirmButton(BuildContext context, bool isDarkMode, bool isLoggedIn) {
    // If not logged in, show "Login to Continue" button
    if (!isLoggedIn) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Login to Continue',
            onPressed: () async {
              // Show login bottom sheet
              await LoginBottomSheet.show(context);
              
              // Refresh the page after login sheet closes
              if (mounted) {
                setState(() {
                  // This will trigger rebuild and check login state again
                });
              }
            },
            backgroundColor: isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary,
            textColor: AppColors.white,
            height: 52,
          ),
        ),
      );
    }

    // Calculate final total from billing summary
    final serviceAmount = _totalServiceAmount;
    final couponDiscount = selectedCouponCode != null
        ? availableCoupons
            .firstWhere((c) => c.couponCode == selectedCouponCode)
            .discountAmount
            .toDouble()
        : 0.0;
    final serviceDiscount = _totalServiceDiscount;
    
    // Calculate subtotal (after service discount and coupon)
    double subtotal = serviceAmount - serviceDiscount;
    if (couponDiscount > 0) {
      subtotal -= couponDiscount;
    }
    
    // Calculate GST
    final gst = (subtotal * 5.0) / 100;
    
    // Platform fee (waived)
    final platformFee = 0.0;
    
    // Total before Gloup Cash
    final totalBeforeGloupCash = subtotal + gst + platformFee;
    
    // Gloup Cash (only if checkbox is checked)
    final gloupCash = useGloupCash ? 70.0 : 0.0;
    
    // Final total
    final finalTotal = totalBeforeGloupCash - gloupCash;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Left side - Razorpay logo and text
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_razorpay.svg',
                  height: 32,
                  width: 32,
                ),
                const SizedBox(width: AppSizes.spaceS),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay via',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                    Text(
                      'Razorpay',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: AppSizes.spaceXL),
            // Right side - Pay button with amount
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, orderState) => PrimaryButton(
                text: orderState.isLoading
                    ? 'Processing...'
                    : 'Pay ₹${finalTotal.toStringAsFixed(0)}',
                onPressed: orderState.isLoading ? null : () {
                  final allSelectedServices = [
                    ...((widget.bookingData!['selectedServices'] as List?)
                            ?.cast<Map<String, dynamic>>() ??
                        []),
                    ...addedServices,
                  ];

                  final servicesPayload = allSelectedServices
                      .map((s) => {'service_id': s['id']})
                      .toList();

                  final guestState = context.read<GuestBloc>().state;
                  final selectedGuest = selectedBookingFor == 'someone_else' &&
                          selectedSomeoneElseIndex != null &&
                          selectedSomeoneElseIndex! < guestState.guests.length
                      ? guestState.guests[selectedSomeoneElseIndex!]
                      : null;

                  final request = CreateOrderRequest(
                    bookingDate: widget.bookingData!['selectedDate'] ?? '',
                    slotId: widget.bookingData!['slotId'] as int? ?? 0,
                    services: servicesPayload,
                    isCombo: false,
                    bookingFor: selectedBookingFor,
                    guestId: selectedGuest?.guestId,
                    professionalId: widget.bookingData!['professionalId'] as int?,
                    storeId: widget.bookingData!['salonId'],
                    gst: gst,
                    platformFee: platformFee,
                    serviceAmount: serviceAmount,
                    serviceDiscount: serviceDiscount,
                    couponDiscount: couponDiscount > 0 ? couponDiscount : null,
                    couponCode: selectedCouponCode,
                    walletAmountUsed: gloupCash,
                    finalAmount: finalTotal,
                  );

                  context.read<OrderBloc>().add(CreateOrderEvent(request));
                },
                backgroundColor: AppColors.success,
                textColor: AppColors.white,
                height: 52,
              ),
              ),
            ),
          ],
        ),
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
                  // Load guests when switching to "Someone Else" tab
                  context.read<GuestBloc>().add(const LoadGuestsEvent());
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

          final serviceId = service['id'] as int? ?? name;
          final isAdded = addedServices.any((s) => (s['id'] ?? s['name']) == serviceId);

          return RecommendedServiceCard(
            name: name,
            duration: duration,
            price: price,
            discountPercentage: discountPercentage,
            isAdded: isAdded,
            onAdd: () {
              setState(() {
                if (isAdded) {
                  // Remove service
                  addedServices.removeWhere((s) => (s['id'] ?? s['name']) == serviceId);
                } else {
                  // Add service
                  addedServices.add({
                    'id': serviceId,
                    'name': name,
                    'price': price,
                    'duration': duration,
                    'discountPercentage': discountPercentage,
                    'isPopular': service['isPopular'] ?? false,
                  });
                }
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAdded ? 'Removed "$name"' : 'Added "$name" to booking'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
