import 'package:tressy/core/utils/image_url_resolver.dart';
import 'package:tressy/core/utils/salon_address_formatter.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

/// Shared Pagination Model
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

/// Shared Salon Model
class SalonModel {
  final String id;
  final String salonName;
  final String salonImage;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double distance;
  final String address;
  final String displayAddress;
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
    required this.displayAddress,
    this.isPremium = false,
    this.isFavorite = false,
    this.serviceName,
    this.servicePrice,
    required this.categories,
    required this.languageCodes,
  });

  factory SalonModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final salonId = json['id']?.toString() ?? '';

    final gallery = ImageUrlResolver.resolveStoreGallery(
      images: json['images'] as List<dynamic>?,
      primaryImage: json['salonImage']?.toString(),
      logo: json['logo']?.toString(),
      storeId: salonId,
      imageBaseUrl: imageBaseUrl,
    );

    final salonImage = gallery.isNotEmpty
        ? gallery.first
        : ImageUrlResolver.resolveStoreImage(
            path: json['salonImage']?.toString(),
            storeId: salonId,
            imageBaseUrl: imageBaseUrl,
          );

    final rawAddress = json['address']?.toString() ?? '';
    final area = json['area']?.toString();
    final city = json['city']?.toString();
    final displayAddress = _resolveDisplayAddress(
      rawAddress: rawAddress,
      area: area,
      city: city,
    );

    return SalonModel(
      id: salonId,
      salonName: json['salonName'] ?? '',
      salonImage: salonImage,
      images: gallery.isNotEmpty
          ? gallery
          : (salonImage.isNotEmpty ? [salonImage] : []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      isPremium: json['isPremium'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      serviceName: json['serviceName'],
      servicePrice: (json['servicePrice'] as num?)?.toDouble(),
      address: rawAddress.isNotEmpty ? rawAddress : 'Not available',
      displayAddress: displayAddress,
      categories: List<String>.from(json['categories'] ?? []),
      languageCodes: List<String>.from(json['languageCodes'] ?? []),
    );
  }

  static String _resolveDisplayAddress({
    required String rawAddress,
    String? area,
    String? city,
  }) {
    final trimmedArea = area?.trim() ?? '';
    final trimmedCity = city?.trim() ?? '';

    if (trimmedArea.isNotEmpty && trimmedCity.isNotEmpty) {
      if (trimmedArea.toLowerCase() == trimmedCity.toLowerCase()) {
        return trimmedCity;
      }
      return '$trimmedArea, $trimmedCity';
    }
    if (trimmedCity.isNotEmpty) return trimmedCity;
    if (trimmedArea.isNotEmpty) return trimmedArea;
    return SalonAddressFormatter.areaAndCity(rawAddress);
  }

  /// Convert model to entity
  SalonEntity toEntity() {
    return SalonEntity(
      id: id,
      salonName: salonName,
      salonImage: salonImage,
      images: images,
      rating: rating,
      reviewCount: reviewCount,
      distance: distance,
      address: address,
      displayAddress: displayAddress,
      isPremium: isPremium,
      isFavorite: isFavorite,
      serviceName: serviceName,
      servicePrice: servicePrice,
      categories: categories,
      languageCodes: languageCodes,
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
      'displayAddress': displayAddress,
      'categories': categories,
      'languageCodes': languageCodes,
    };
  }
}

/// Shared Salons Response Model
class SalonsResponseModel {
  final PaginationModel pagination;
  final List<SalonModel> salons;

  SalonsResponseModel({
    required this.pagination,
    required this.salons,
  });

  factory SalonsResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    final salonsJson = json['data'] as List<dynamic>? ?? [];

    return SalonsResponseModel(
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
