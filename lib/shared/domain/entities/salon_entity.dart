import 'package:equatable/equatable.dart';

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
  final bool isPremium;
  final bool isFavorite;
  final String? serviceName;
  final double? servicePrice;
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
    required this.isPremium,
    required this.isFavorite,
    this.serviceName,
    this.servicePrice,
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
        isPremium,
        isFavorite,
        serviceName,
        servicePrice,
        categories,
        languageCodes,
      ];
}
