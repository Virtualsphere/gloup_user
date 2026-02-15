import 'package:equatable/equatable.dart';

/// Salon Detail Entity
class SalonDetailEntity extends Equatable {
  final String id;
  final String name;
  final bool isNew;
  final bool isPremium;
  final double rating;
  final int reviewCount;
  final String gender; // 'Unisex', 'Men', 'Women'
  final String address;
  final bool isOpen;
  final String openingTime;
  final String closingTime;
  final List<String> languages;
  final List<String> images;
  final String about;
  final List<ServiceEntity> services;
  final List<AmbientEntity> ambients;
  final List<TeamMemberEntity> teamMembers;
  final List<ReviewEntity> reviews;
  final Map<String, String> openingHours; // day: hours
  final LocationEntity location;

  const SalonDetailEntity({
    required this.id,
    required this.name,
    required this.isNew,
    required this.isPremium,
    required this.rating,
    required this.reviewCount,
    required this.gender,
    required this.address,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.languages,
    required this.images,
    required this.about,
    required this.services,
    required this.ambients,
    required this.teamMembers,
    required this.reviews,
    required this.openingHours,
    required this.location,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        isNew,
        isPremium,
        rating,
        reviewCount,
        gender,
        address,
        isOpen,
        openingTime,
        closingTime,
        languages,
        images,
        about,
        services,
        ambients,
        teamMembers,
        reviews,
        openingHours,
        location,
      ];
}

/// Service Entity
class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String duration;
  final double price;
  final double? originalPrice;
  final String? discountPercentage;
  final bool isPopular;
  final String category;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.isPopular,
    required this.category,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        duration,
        price,
        originalPrice,
        discountPercentage,
        isPopular,
        category,
      ];
}

/// Ambient Entity
class AmbientEntity extends Equatable {
  final String id;
  final String icon;
  final String label;

  const AmbientEntity({
    required this.id,
    required this.icon,
    required this.label,
  });

  @override
  List<Object?> get props => [id, icon, label];
}

/// Team Member Entity
class TeamMemberEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String imageUrl;

  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, role, imageUrl];
}

/// Review Entity
class ReviewEntity extends Equatable {
  final String id;
  final String userName;
  final String? userImage;
  final String timeAgo;
  final double rating;
  final String reviewText;

  const ReviewEntity({
    required this.id,
    required this.userName,
    this.userImage,
    required this.timeAgo,
    required this.rating,
    required this.reviewText,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        userImage,
        timeAgo,
        rating,
        reviewText,
      ];
}

/// Location Entity
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String address;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}
