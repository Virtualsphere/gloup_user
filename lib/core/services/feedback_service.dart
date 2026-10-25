import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// Service to submit user reasons and feedback to `POST /user/app/v2/feedback`.
class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  /// Sends reason prompt feedback (checkout_exit, cancel_booking, other).
  /// Runs asynchronously without blocking the caller or showing UI errors.
  static Future<void> sendFeedback({
    required String type,
    required String reason,
    String? note,
    int? storeId,
    int? appointmentId,
  }) async {
    if (!LocalStorageService.isLoggedIn) return;

    try {
      final body = <String, dynamic>{
        'type': type,
        'reason': reason.trim().toLowerCase(),
      };
      if (note != null && note.trim().isNotEmpty) {
        body['note'] = note.trim();
      }
      if (storeId != null) body['store_id'] = storeId;
      if (appointmentId != null) body['appointment_id'] = appointmentId;

      await sl<DioClient>().post(
        ApiRoutes.feedback,
        data: body,
      );
    } catch (e) {
      debugPrint('[FeedbackService] Failed to send feedback (ignoring): $e');
    }
  }
}

