import 'package:tressy/core/utils/category_image_resolver.dart';

class ServiceCategoryModel {
  final String id;
  final String name;
  final String searchCategory;
  final int discountedAmount;
  final String? imageUrl;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.searchCategory,
    required this.discountedAmount,
    this.imageUrl,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['category_id'].toString(),
      name: json['category_name']?.toString() ?? '',
      searchCategory: json['search_category']?.toString() ?? '',
      discountedAmount: (json['discounted_amount'] as num?)?.toInt() ?? 0,
      imageUrl: CategoryImageResolver.apiImageFromJson(json),
    );
  }

  static const ServiceCategoryModel all = ServiceCategoryModel(
    id: 'all',
    name: 'All',
    searchCategory: '',
    discountedAmount: 0,
  );
}
