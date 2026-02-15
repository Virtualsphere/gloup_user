/// Carousel Banner Model
class CarouselBannerModel {
  final String id;
  final String imageUrl;

  CarouselBannerModel({
    required this.id,
    required this.imageUrl,
  });

  factory CarouselBannerModel.fromJson(Map<String, dynamic> json) {
    return CarouselBannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
    };
  }
}

/// Category Model
class CategoryModel {
  final String id;
  final String label;
  final String? imageUrl;

  CategoryModel({
    required this.id,
    required this.label,
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'imageUrl': imageUrl,
    };
  }
}

/// Salon Model - Used for all salon listings (top salons, recommended, nearby)
class SalonModel {
  final String id;
  final String salonName;
  final String salonImage;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double distance; // in km
  final bool isPremium;
  final bool isFavorite;
  final String? serviceName;
  final double? servicePrice;
  final List<String> categories;
  final List<String> languageCodes;

  SalonModel({
    required this.id,
    required this.salonName,
    required this.salonImage,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.isPremium = false,
    this.isFavorite = false,
    this.serviceName,
    this.servicePrice,
    required this.categories,
    required this.languageCodes,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id'] ?? '',
      salonName: json['salonName'] ?? '',
      salonImage: json['salonImage'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      isPremium: json['isPremium'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      serviceName: json['serviceName'],
      servicePrice: json['servicePrice']?.toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      languageCodes: List<String>.from(json['languageCodes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonName': salonName,
      'salonImage': salonImage,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'distance': distance,
      'isPremium': isPremium,
      'isFavorite': isFavorite,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'categories': categories,
      'languageCodes': languageCodes,
    };
  }
}

