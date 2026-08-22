import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/profile/presentation/model/review_data.dart';

class PendingReview {
  final int storeId;
  final int appointmentId;
  final String storeName;
  final String? bookingDate;
  final List<dynamic>? storeImages;

  PendingReview({
    required this.storeId,
    required this.appointmentId,
    required this.storeName,
    this.bookingDate,
    this.storeImages,
  });

  factory PendingReview.fromJson(Map<String, dynamic> json) {
    return PendingReview(
      storeId: (json['store_id'] as num).toInt(),
      appointmentId: (json['appointment_id'] as num).toInt(),
      storeName: (json['store_name'] ?? '') as String,
      bookingDate: json['booking_date']?.toString(),
      storeImages: json['store_images'] as List<dynamic>?,
    );
  }
}

class UserReview {
  final int id;
  final double rating;
  final String description;
  final int storeId;
  final String storeName;
  final List<String>? storeImages;
  final String? addressLine1;
  final String? city;
  final String? zipcode;

  UserReview({
    required this.id,
    required this.rating,
    required this.description,
    required this.storeId,
    required this.storeName,
    this.storeImages,
    this.addressLine1,
    this.city,
    this.zipcode,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>? ?? {};
    final address = store['address'] as Map<String, dynamic>? ?? {};

    List<String>? images;
    final rawImages = store['images'];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    }

    return UserReview(
      id: (json['id'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      description: (json['description'] ?? '') as String,
      storeId: (store['id'] as num?)?.toInt() ?? 0,
      storeName: (store['name'] ?? '') as String,
      storeImages: images,
      addressLine1: address['addressLine1']?.toString(),
      city: address['city']?.toString(),
      zipcode: address['zipcode']?.toString(),
    );
  }

  ReviewData toReviewData() {
    return ReviewData(
      reviewId: id,
      rating: rating,
      reviewDescription: description,
      storeName: storeName,
      storeId: storeId,
      storeImages: storeImages,
      city: city,
      district: addressLine1,
    );
  }
}

class MyReviewsResult {
  final List<UserReview> reviews;
  final int totalRecords;

  MyReviewsResult({
    required this.reviews,
    required this.totalRecords,
  });
}

class ReviewService {
  ReviewService._();

  static bool _isSuccessResponse(Response<dynamic> response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      return false;
    }
    final body = response.data;
    if (body is! Map) return true;
    if (body['success'] == false) return false;
    return body['success'] == true || body['status'] != null || body['data'] != null;
  }

  static Future<List<PendingReview>> fetchPendingReviews() async {
    try {
      final response = await sl<DioClient>().get(ApiRoutes.pendingReviews);
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(PendingReview.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ReviewService] fetchPendingReviews error: $e');
      return [];
    }
  }

  static Future<MyReviewsResult?> fetchMyReviews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await sl<DioClient>().get(
        ApiRoutes.withPagination(
          ApiRoutes.getReviewsV2,
          page: page,
          limit: limit,
        ),
      );

      if (response.data['success'] != true) return null;

      final payload = response.data['data'] as Map<String, dynamic>?;
      if (payload == null) return null;

      final list = (payload['data'] as List<dynamic>?) ?? [];
      final pagination = payload['pagination'] as Map<String, dynamic>?;
      final total =
          (pagination?['totalRecords'] as num?)?.toInt() ?? list.length;

      return MyReviewsResult(
        reviews: list
            .whereType<Map<String, dynamic>>()
            .map(UserReview.fromJson)
            .toList(),
        totalRecords: total,
      );
    } catch (e) {
      debugPrint('[ReviewService] fetchMyReviews error: $e');
      return null;
    }
  }

  static Future<bool> submitReview({
    required int storeId,
    required double rating,
    required String description,
  }) async {
    try {
      final response = await sl<DioClient>().post(
        ApiRoutes.addReview,
        data: {
          'store_id': storeId,
          'rating': rating,
          'description': description,
        },
      );
      return _isSuccessResponse(response);
    } catch (e) {
      debugPrint('[ReviewService] submitReview error: $e');
      return false;
    }
  }

  static Future<bool> updateReview({
    required int reviewId,
    required double rating,
    required String description,
  }) async {
    try {
      final response = await sl<DioClient>().patch(
        ApiRoutes.reviewV2ById(reviewId),
        data: {
          'rating': rating,
          'description': description,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[ReviewService] updateReview error: $e');
      return false;
    }
  }

  static Future<bool> deleteReview({required int reviewId}) async {
    try {
      final response = await sl<DioClient>().delete(
        ApiRoutes.reviewV2ById(reviewId),
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[ReviewService] deleteReview error: $e');
      return false;
    }
  }
}
