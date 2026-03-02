import 'package:tressy/features/favorites/domain/entities/favorite_entity.dart';

/// Model for favorite toggle response
class FavoriteModel {
  final int status;
  final bool success;
  final String message;

  FavoriteModel({
    required this.status,
    required this.success,
    required this.message,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      status: json['status'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'success': success,
      'message': message,
    };
  }

  FavoriteEntity toEntity() {
    return FavoriteEntity(
      success: success,
      message: message,
    );
  }
}
