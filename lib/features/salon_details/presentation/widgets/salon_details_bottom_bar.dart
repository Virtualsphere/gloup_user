import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_bloc.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/offer_banner.dart';
import 'package:tressy/shared/widgets/primary_button.dart';

class SalonDetailsBottomBar extends StatelessWidget {
  final bool isDarkMode;
  final Animation<Offset> bottomNavAnimation;
  final Map<int, ServiceEntity> selectedServices;
  final double totalPrice;
  final int serviceCount;
  final int highestOfferPercentage;
  final String? salonId;

  const SalonDetailsBottomBar({
    super.key,
    required this.isDarkMode,
    required this.bottomNavAnimation,
    required this.selectedServices,
    required this.totalPrice,
    required this.serviceCount,
    required this.highestOfferPercentage,
    required this.salonId,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBottomNavBar(context, isDarkMode);
  }

  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    if (serviceCount == 0) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<SalonDetailBloc, SalonDetailState>(
      builder: (context, state) {
        return SlideTransition(
          position: bottomNavAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OfferBanner(discountPercentage: highestOfferPercentage),
              Container(
                padding: EdgeInsets.only(
                  left: AppSizes.paddingM,
                  right: AppSizes.paddingM,
                  top: AppSizes.paddingM,
                  bottom:
                      AppSizes.paddingM + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surface : AppColors.surfaceDark,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$serviceCount ${serviceCount == 1 ? 'service' : 'services'} added',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryDark,
                              fontSize: AppSizes.fontS,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${totalPrice.toStringAsFixed(0)}',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: isDarkMode
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryDark,
                              fontSize: AppSizes.fontL,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSizes.widthM,
                    SizedBox(
                      width: 150,
                      child: PrimaryButton(
                        text: 'Book Now',
                        onPressed: () {
                          final salonData = {
                            'salonId': salonId,
                            'salonName': state.salonDetail?.name,
                            'salonImage':
                                state.salonDetail?.images.isNotEmpty == true
                                    ? state.salonDetail!.images.first
                                    : null,
                            'rating': state.salonDetail?.rating,
                            'reviewCount': state.salonDetail?.reviewCount,
                            'isPremium': state.salonDetail?.isPremium,
                            'gender': state.salonDetail?.gender,
                            'address': state.salonDetail?.address,
                            'openingTime': state.salonDetail?.openingTime,
                            'closingTime': state.salonDetail?.closingTime,
                            'selectedServices': selectedServices.values
                                .map((service) => {
                                      'id': service.id,
                                      'name': service.name,
                                      'price': service.price,
                                      'originalPrice': service.originalPrice,
                                      'duration': service.duration,
                                      'discountPercentage':
                                          service.discountPercentage,
                                      'isPopular': service.isPopular,
                                    })
                                .toList(),
                            'allServices': state.salonDetail?.services
                                .map((service) => {
                                      'id': service.id,
                                      'name': service.name,
                                      'price': service.price,
                                      'originalPrice': service.originalPrice,
                                      'duration': service.duration,
                                      'discountPercentage':
                                          service.discountPercentage,
                                      'isPopular': service.isPopular,
                                    })
                                .toList()
                          };

                          context.pushNamed(
                            RouteNames.slotBooking,
                            extra: salonData,
                          );
                        },
                        backgroundColor: isDarkMode
                            ? AppColors.primary
                            : AppColors.onPrimary,
                        textColor: isDarkMode
                            ? AppColors.onPrimary
                            : AppColors.primary,
                        height: 56,
                        fontSize: AppSizes.fontL,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
