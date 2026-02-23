/// Carousel Banner Model
class CarouselBannerModel {
  final String id;
  final String imageUrl;

  CarouselBannerModel({
    required this.id,
    required this.imageUrl,
  });

  factory CarouselBannerModel.fromJson(Map<String, dynamic> json,
      {String? imageBaseUrl}) {
    final imagePath = json['imageUrl'] ?? '';
    final fullImageUrl = imageBaseUrl != null && imagePath.isNotEmpty
        ? '$imageBaseUrl/$imagePath'
        : imagePath;

    return CarouselBannerModel(
      id: json['id']?.toString() ?? '',
      imageUrl: fullImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
  final String address;
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
    required this.address,
    this.isPremium = false,
    this.isFavorite = false,
    this.serviceName,
    this.servicePrice,
    required this.categories,
    required this.languageCodes,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json,
      {String? imageBaseUrl}) {
    // Transform salonImage with imageBaseUrl
    final salonImagePath = json['salonImage'] ?? '';
    final fullSalonImageUrl = imageBaseUrl != null && salonImagePath.isNotEmpty
        ? '$imageBaseUrl/$salonImagePath'
        : salonImagePath;

    // Transform images array with imageBaseUrl
    final imagesList = (json['images'] as List<dynamic>?)?.map((image) {
          final imagePath = image?.toString() ?? '';
          return imageBaseUrl != null && imagePath.isNotEmpty
              ? '$imageBaseUrl/$imagePath'
              : imagePath;
        }).toList() ??
        [];

    return SalonModel(
      id: json['id']?.toString() ?? '',
      salonName: json['salonName'] ?? '',
      salonImage: fullSalonImageUrl,
      images: imagesList,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      isPremium: json['isPremium'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      serviceName: json['serviceName'],
      servicePrice: json['servicePrice']?.toDouble(),
      address: json['address'] ?? 'Not available',
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
      'address': address,
      'categories': categories,
      'languageCodes': languageCodes,
    };
  }
}
