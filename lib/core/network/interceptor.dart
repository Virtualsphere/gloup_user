import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/utils/app_logger.dart';

/// Dio interceptor that logs every HTTP call in debug builds.
class LoggerInterceptor extends Interceptor {
  static const String _tag = 'API';
  static const int _maxBodyChars = 2500;

  static const Set<String> _sensitiveKeys = {
    'otp',
    'token',
    'idtoken',
    'id_token',
    'identitytoken',
    'identity_token',
    'authorizationcode',
    'authorization_code',
    'password',
    'userauth',
    'authorization',
    'access_token',
    'refreshtoken',
    'refresh_token',
    'key',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      options.extra['_requestStartMs'] = DateTime.now().millisecondsSinceEpoch;

      final endpointName = ApiRoutes.nameForUrl(options.uri.toString());
      final label = endpointName != null ? ' [$endpointName]' : '';

      AppLogger.info(
        '→ ${options.method} ${options.uri}$label',
        tag: _tag,
      );

      if (options.queryParameters.isNotEmpty) {
        AppLogger.debug(
          '  query: ${_truncate(_formatPayload(options.queryParameters))}',
          tag: _tag,
        );
      }

      if (options.data != null) {
        AppLogger.debug(
          '  body: ${_truncate(_formatPayload(options.data))}',
          tag: _tag,
        );
      }

      final headers =
          _sanitizeHeaders(Map<String, dynamic>.from(options.headers));
      if (headers.isNotEmpty) {
        AppLogger.debug(
          '  headers: $headers',
          tag: _tag,
        );
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final durationMs = _elapsedMs(response.requestOptions);
      final endpointName =
          ApiRoutes.nameForUrl(response.requestOptions.uri.toString());
      final label = endpointName != null ? ' [$endpointName]' : '';

      AppLogger.info(
        '← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}$label (${durationMs}ms)',
        tag: _tag,
      );

      AppLogger.debug(
        '  response: ${_truncate(_formatPayload(response.data))}',
        tag: _tag,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final durationMs = _elapsedMs(err.requestOptions);
      final endpointName =
          ApiRoutes.nameForUrl(err.requestOptions.uri.toString());
      final label = endpointName != null ? ' [$endpointName]' : '';

      AppLogger.error(
        '✗ ${err.requestOptions.method} ${err.requestOptions.uri}$label '
        '(${durationMs}ms) type=${err.type.name}',
        error: err.message,
        tag: _tag,
      );

      if (err.response != null) {
        AppLogger.error(
          '  status: ${err.response?.statusCode} '
          'body: ${_truncate(_formatPayload(err.response?.data))}',
          tag: _tag,
        );
      }
    }
    handler.next(err);
  }

  static int _elapsedMs(RequestOptions options) {
    final start = options.extra['_requestStartMs'] as int?;
    if (start == null) return 0;
    return DateTime.now().millisecondsSinceEpoch - start;
  }

  static String _truncate(String value) {
    if (value.length <= _maxBodyChars) return value;
    return '${value.substring(0, _maxBodyChars)}… (${value.length} chars total)';
  }

  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      final keyStr = key.toString().toLowerCase();
      if (_sensitiveKeys.contains(keyStr)) {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }

  static String _formatPayload(dynamic data) {
    try {
      final sanitized = _sanitizeValue(data);
      if (sanitized is String) return sanitized;
      return const JsonEncoder.withIndent('  ').convert(sanitized);
    } catch (_) {
      return data.toString();
    }
  }

  static dynamic _sanitizeValue(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final keyStr = key.toString().toLowerCase();
        if (_sensitiveKeys.contains(keyStr)) {
          return MapEntry(key, '***');
        }
        return MapEntry(key, _sanitizeValue(value));
      });
    }
    if (data is List) {
      return data.map(_sanitizeValue).toList();
    }
    if (data is FormData) {
      return {
        'fields': data.fields
            .map((e) => {
                  e.key: _sensitiveKeys.contains(e.key.toLowerCase())
                      ? '***'
                      : e.value,
                })
            .toList(),
        'files': data.files.map((f) => f.key).toList(),
      };
    }
    return data;
  }
}
