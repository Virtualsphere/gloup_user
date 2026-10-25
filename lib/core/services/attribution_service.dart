import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// Reads install referrer once (Play Install Referrer on Android, UTM link on iOS)
/// and reports to `POST /user/app/v2/attribution` once after the first login.
class AttributionService {
  AttributionService._();

  static final AttributionService instance = AttributionService._();

  static const String _prefKeyAttributionData = 'app_attribution_data';
  static const String _prefKeyAttributionSent = 'app_attribution_sent';

  /// Call in main() to capture referrer/UTM on first launch.
  static Future<void> initialize() async {
    await instance._captureAttributionIfNeeded();
    if (LocalStorageService.isLoggedIn) {
      unawaited(instance.reportIfPending());
    }
  }

  /// Call right after successful user login.
  static Future<void> onUserLogin() => instance.reportIfPending();

  Future<void> _captureAttributionIfNeeded() async {
    // If already saved locally or already sent to backend, skip re-capture
    if (LocalStorageService.getBool(_prefKeyAttributionSent) == true) return;
    final existing = LocalStorageService.getString(_prefKeyAttributionData);
    if (existing != null && existing.isNotEmpty) return;

    Map<String, dynamic>? attribution;

    // 1. Android: Play Install Referrer API
    if (Platform.isAndroid) {
      try {
        final referrerDetails = await PlayInstallReferrer.installReferrer;
        final rawReferrer = referrerDetails.installReferrer;
        if (rawReferrer != null && rawReferrer.isNotEmpty) {
          attribution = _parseReferrerString(rawReferrer);
        }
      } catch (e) {
        debugPrint('[Attribution] PlayInstallReferrer error: $e');
      }
    }

    // 2. iOS or Fallback: Initial deep link via AppLinks
    if (attribution == null) {
      try {
        final initialUri = await AppLinks().getInitialLink();
        if (initialUri != null) {
          attribution = _parseUri(initialUri);
        }
      } catch (e) {
        debugPrint('[Attribution] AppLinks initial link error: $e');
      }
    }

    // Default to organic/direct if no marketing campaign detected
    attribution ??= {
      'source': 'organic',
      'medium': 'direct',
      'referrer': 'direct',
    };

    await LocalStorageService.setString(
      _prefKeyAttributionData,
      jsonEncode(attribution),
    );
  }

  /// Parse raw referrer string into { source, medium, campaign, referrer }
  static Map<String, dynamic> _parseReferrerString(String raw) {
    String? source;
    String? medium;
    String? campaign;

    try {
      final decoded = Uri.decodeComponent(raw);
      final uri = Uri.tryParse('http://dummy/?$decoded');
      if (uri != null) {
        source = uri.queryParameters['utm_source'];
        medium = uri.queryParameters['utm_medium'];
        campaign = uri.queryParameters['utm_campaign'];
      }
    } catch (_) {}

    // Map common known source badges
    final lowerRaw = raw.toLowerCase();
    if (source == null || source.isEmpty) {
      if (lowerRaw.contains('instagram')) {
        source = 'instagram';
      } else if (lowerRaw.contains('facebook') || lowerRaw.contains('fb')) {
        source = 'facebook';
      } else if (lowerRaw.contains('google')) {
        source = 'google';
      } else {
        source = 'organic';
      }
    }

    return {
      'source': _truncate(source.toLowerCase(), 40),
      'medium': _truncate(medium?.toLowerCase(), 40),
      'campaign': _truncate(campaign, 80),
      'referrer': _truncate(raw, 2000),
    };
  }

  /// Parse Uri query parameters into { source, medium, campaign, referrer }
  static Map<String, dynamic>? _parseUri(Uri uri) {
    final params = uri.queryParameters;
    final utmSource = params['utm_source'];
    final utmMedium = params['utm_medium'];
    final utmCampaign = params['utm_campaign'];

    if (utmSource == null && utmMedium == null && utmCampaign == null) {
      return null;
    }

    return {
      'source': _truncate(utmSource?.toLowerCase() ?? 'referral', 40),
      'medium': _truncate(utmMedium?.toLowerCase(), 40),
      'campaign': _truncate(utmCampaign, 80),
      'referrer': _truncate(uri.toString(), 2000),
    };
  }

  /// Reports attribution once to POST /user/app/v2/attribution
  Future<void> reportIfPending() async {
    if (!LocalStorageService.isLoggedIn) return;
    if (LocalStorageService.getBool(_prefKeyAttributionSent) == true) return;

    try {
      final dataStr = LocalStorageService.getString(_prefKeyAttributionData);
      Map<String, dynamic> body;
      if (dataStr != null && dataStr.isNotEmpty) {
        body = Map<String, dynamic>.from(jsonDecode(dataStr) as Map);
      } else {
        body = {'source': 'organic', 'referrer': 'direct'};
      }

      final response = await sl<DioClient>().post(
        ApiRoutes.attribution,
        data: body,
      );

      if (response.statusCode == 200) {
        await LocalStorageService.setBool(_prefKeyAttributionSent, true);
      }
    } catch (e) {
      debugPrint('[Attribution] report failed (silently ignoring): $e');
    }
  }

  static String? _truncate(String? val, int maxLen) {
    if (val == null) return null;
    final trimmed = val.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length > maxLen ? trimmed.substring(0, maxLen) : trimmed;
  }
}

