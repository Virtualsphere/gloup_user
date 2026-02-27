import 'package:tressy/features/category/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.label,
    required super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, {String? imageBaseUrl}) {
    final imagePath = json['imageUrl'] ?? '';
    final fullImageUrl = imageBaseUrl != null && imagePath.isNotEmpty
        ? '$imageBaseUrl/$imagePath'
        : imagePath;
    
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      label: (json['label'] as String?)?.trim() ?? '',
      imageUrl: fullImageUrl,
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

/// Pagination Model for Category Salons
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
}

/// Salon Model for Category Listings
class CategorySalonModel {
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

  CategorySalonModel({
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

  factory CategorySalonModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final salonImagePath = json['salonImage'] ?? '';
    final fullSalonImageUrl = imageBaseUrl != null && salonImagePath.isNotEmpty
        ? '$imageBaseUrl/$salonImagePath'
        : salonImagePath;

    final imagesList = (json['images'] as List<dynamic>?)?.map((image) {
          final imagePath = image?.toString() ?? '';
          return imageBaseUrl != null && imagePath.isNotEmpty
              ? '$imageBaseUrl/$imagePath'
              : imagePath;
        }).toList() ??
        [];

    return CategorySalonModel(
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
}

/// Category Salons Response Model
class CategorySalonsResponseModel {
  final PaginationModel pagination;
  final List<CategorySalonModel> salons;

  CategorySalonsResponseModel({
    required this.pagination,
    required this.salons,
  });

  factory CategorySalonsResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};
    final salonsJson = json['data'] as List<dynamic>? ?? [];

    return CategorySalonsResponseModel(
      pagination: PaginationModel.fromJson(paginationJson),
      salons: salonsJson
          .map((salonJson) => CategorySalonModel.fromJson(
                salonJson,
                imageBaseUrl: imageBaseUrl,
              ))
          .toList(),
    );
  }
}
