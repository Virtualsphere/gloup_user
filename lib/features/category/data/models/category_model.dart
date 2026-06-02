import 'package:tressy/core/utils/image_url_resolver.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.label,
    required super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json,
      {String? imageBaseUrl}) {
    final fullImageUrl = ImageUrlResolver.resolveCdnAsset(
      path: json['image']?.toString() ?? json['imageUrl']?.toString(),
      imageBaseUrl: imageBaseUrl,
    );

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

// Removed unused CategorySalonModel, PaginationModel, and CategorySalonsResponseModel
// Now using shared models from lib/shared/data/models/salon_model.dart
