import 'package:tressy/core/utils/image_url_resolver.dart';
import 'package:tressy/shared/data/models/salon_model.dart';

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
    final fullImageUrl = ImageUrlResolver.resolveCdnAsset(
      path: json['imageUrl']?.toString(),
      imageBaseUrl: imageBaseUrl,
    );

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

// HomeSalonModel has been removed - now using shared SalonModel from lib/shared/data/models/salon_model.dart
