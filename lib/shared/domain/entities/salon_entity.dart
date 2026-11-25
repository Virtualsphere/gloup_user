import 'package:equatable/equatable.dart';
import 'package:tressy/shared/domain/entities/offer_badge.dart';

/// Shared Salon Entity used across multiple features
/// (Home, Explore, Category, Favorites, etc.)
class SalonEntity extends Equatable {
  final String id;
  final String salonName;
  final String salonImage;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double distance;
  final String address;

  /// Short label for cards: area and city only.
  final String displayAddress;
  final bool isPremium;
  final bool isFavorite;
  final String? serviceName;
  final double? servicePrice;
  final List<Map<String, dynamic>>? dynamicServices;

  /// Best discount across the salon's services, null when there is none.
  final OfferBadge? offerBadge;
  final List<String> categories;
  final List<String> languageCodes;

  const SalonEntity({
    required this.id,
    required this.salonName,
    required this.salonImage,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.address,
    required this.displayAddress,
    required this.isPremium,
    required this.isFavorite,
    this.serviceName,
    this.servicePrice,
    this.dynamicServices,
    this.offerBadge,
    required this.categories,
    required this.languageCodes,
  });

  @override
  List<Object?> get props => [
        id,
        salonName,
        salonImage,
        images,
        rating,
        reviewCount,
        distance,
        address,
        displayAddress,
        isPremium,
        isFavorite,
        serviceName,
        servicePrice,
        dynamicServices,
        offerBadge,
        categories,
        languageCodes,
      ];
}
