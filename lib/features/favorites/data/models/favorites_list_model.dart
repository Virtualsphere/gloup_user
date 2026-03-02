import 'package:tressy/shared/data/models/salon_model.dart';

/// Model for favorites list response
class FavoritesListModel {
  final int status;
  final bool success;
  final String message;
  final List<SalonModel> favorites;

  FavoritesListModel({
    required this.status,
    required this.success,
    required this.message,
    required this.favorites,
  });

  factory FavoritesListModel.fromJson(
    Map<String, dynamic> json, {
    String? imageBaseUrl,
  }) {
    final favoritesJson = json['data'] as List<dynamic>? ?? [];

    return FavoritesListModel(
      status: json['status'] ?? 200,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      favorites: favoritesJson
          .map((salonJson) => SalonModel.fromJson(
                salonJson,
                imageBaseUrl: imageBaseUrl,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'success': success,
      'message': message,
      'data': favorites.map((s) => s.toJson()).toList(),
    };
  }
}
