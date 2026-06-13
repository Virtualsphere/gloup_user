import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/interceptor.dart';
class DioClient {
  late final Dio _dio;
  DioClient()
      : _dio = Dio(
          BaseOptions(
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              responseType: ResponseType.json,
              sendTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60)),
        )..interceptors.addAll([
            LoggerInterceptor(),
          ]) {
    ApiRoutes.logRegisteredEndpoints();
  }

  //! GET METHOD
  Future<Response> get(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // ! POST METHOD
  Future<Response> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // ! PUT METHOD
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // ! PATCH METHOD
  Future<Response> patch(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  // ! DELETE METHOD
  Future<dynamic> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException();
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = 'An error occurred';
          String? errorType;
          
          if (responseData != null && responseData is Map) {
            if (responseData.containsKey('error') && responseData['error'] is Map) {
              message = responseData['error']['message'] ?? message;
              errorType = responseData['error']['type'];
            } else if (responseData['message'] != null) {
              message = responseData['message'].toString();
            }
          } else if (error.error != null && error.error is String) {
              message = error.error as String;
          } else if (statusCode == 400) {
            message = 'Bad request. Please check your input.';
          }
          
          if (statusCode == 401 || errorType == 'UnauthorizedException') {
            return UnauthorizedException();
          } else if (statusCode == 404 || errorType == 'NotFoundException') {
            return NotFoundException();
          } else if (statusCode == 500) {
            return ServerException();
          }
          return ApiException(message: message, statusCode: statusCode);
        case DioExceptionType.connectionError:
          return NetworkException(message: 'No internet connection');
        default:
          if (error.error != null && error.error is String) {
              return ApiException(message: error.error as String);
          }
          return ApiException(message: 'Something went wrong');
      }
    }
    return ApiException(message: error.toString());
  }
}
