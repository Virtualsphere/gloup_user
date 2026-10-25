import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  AppVersionService._();

  static String _version = '2.8.14';
  static bool _initialized = false;

  static String get appVersion => _version;
  static String get platform => Platform.isIOS ? 'ios' : 'android';

  /// Initialize package info at startup. Safe fallback if fails.
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final clean = cleanVersion(info.version);
      if (clean != null && clean.isNotEmpty) {
        _version = clean;
      }
      _initialized = true;
    } catch (e) {
      debugPrint('[AppVersionService] Could not read package info: $e');
    }
  }

  /// Cleans version according to spec: max 20 chars, letters, digits, . + _
  static String? cleanVersion(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    final sanitized = trimmed.replaceAll(RegExp(r'[^0-9A-Za-z.+_-]'), '');
    if (sanitized.isEmpty) return null;
    return sanitized.length > 20 ? sanitized.substring(0, 20) : sanitized;
  }
}

