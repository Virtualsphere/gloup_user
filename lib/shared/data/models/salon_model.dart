import 'package:flutter/foundation.dart';
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

  factory SalonModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final salonImagePath = json['salonImage'] ?? '';
    final salonID = json['id']?.toString() ?? '';
    final fullSalonImageUrl = (imageBaseUrl != null && salonImagePath.isNotEmpty)
        ? '$imageBaseUrl/$salonID/images/$salonImagePath'
        : salonImagePath;

    final imagesList = (json['images'] as List<dynamic>?)?.map((image) {
          final imagePath = image?.toString() ?? '';
          return (imageBaseUrl != null && imagePath.isNotEmpty)
              ? '$imageBaseUrl/$salonID/images/$imagePath'
              : imagePath;
        }).toList() ??
        [];

    debugPrint('[SalonModel] salonID: $salonID');
    debugPrint('[SalonModel] salonImagePath: $salonImagePath');
    debugPrint('[SalonModel] fullSalonImageUrl: $fullSalonImageUrl');
    debugPrint('[SalonModel] imagesList: $imagesList');

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
