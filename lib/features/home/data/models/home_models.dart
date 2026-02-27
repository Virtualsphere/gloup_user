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

/// Pagination Model
class PaginationModel {
  final int page;
  final int limit;
  final int totalRecords;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.totalRecords,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
    };
  }
}

/// Nearby Stores Response Model
class NearbyStoresResponseModel {
  final PaginationModel pagination;
  final List<SalonModel> salons;

  NearbyStoresResponseModel({
    required this.pagination,
    required this.salons,
  });

  factory NearbyStoresResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    final salonsJson = json['data'] as List<dynamic>? ?? [];

    return NearbyStoresResponseModel(
      pagination: PaginationModel.fromJson(paginationJson),
      salons: salonsJson
          .map((salonJson) => SalonModel.fromJson(
                salonJson,
                imageBaseUrl: imageBaseUrl,
              ))
          .toList(),
    );
  }
}

/// All Stores Response Model (for Recommended section)
class AllStoresResponseModel {
  final PaginationModel pagination;
  final List<SalonModel> salons;

  AllStoresResponseModel({
    required this.pagination,
    required this.salons,
  });

  factory AllStoresResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    final salonsJson = json['data'] as List<dynamic>? ?? [];

    return AllStoresResponseModel(
      pagination: PaginationModel.fromJson(paginationJson),
      salons: salonsJson
          .map((salonJson) => SalonModel.fromJson(
                salonJson,
                imageBaseUrl: imageBaseUrl,
              ))
          .toList(),
    );
  }
}

/// Top Salons Response Model
class TopSalonsResponseModel {
  final PaginationModel pagination;
  final List<SalonModel> salons;

  TopSalonsResponseModel({
    required this.pagination,
    required this.salons,
  });

  factory TopSalonsResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    final salonsJson = json['data'] as List<dynamic>? ?? [];

    return TopSalonsResponseModel(
      pagination: PaginationModel.fromJson(paginationJson),
      salons: salonsJson
          .map((salonJson) => SalonModel.fromJson(
                salonJson,
                imageBaseUrl: imageBaseUrl,
              ))
          .toList(),
    );
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
