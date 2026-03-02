import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/auth/data/models/auth_model.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRemoteDataSource {
  Future<AuthEntity> sendOtp(String phone);
  Future<AuthEntity> verifyOtp(String phone, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<AuthEntity> sendOtp(String phone) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.sendOtp,
        data: {'phone': phone},
      );

      if (response.statusCode == 200) {
        // Use SendOtpModel.fromJson for send OTP response
        return SendOtpModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to send OTP',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity> verifyOtp(String phone, String otp) async {
    try {
      debugPrint('🔍 AuthDataSource - verifyOtp called with phone: "$phone", otp: "$otp"');
      debugPrint('🔍 Phone type: ${phone.runtimeType}, length: ${phone.length}');
      debugPrint('🔍 OTP type: ${otp.runtimeType}, length: ${otp.length}');
      
      final requestData = {
        'phone': phone,
        'otp': otp,
      };
      debugPrint('🔍 Request data: $requestData');
      
      final response = await dioClient.post(
        ApiRoutes.verifyOtp,
        data: requestData,
      );

      if (response.statusCode == 200) {
        // Use VerifyOtpModel.fromJson for verify OTP response
        return VerifyOtpModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to verify OTP',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? e.message;
        if (statusCode == 401) {
          return UnauthorizedException(message: message);
        } else if (statusCode == 404) {
          return NotFoundException(message: message);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message: message);
        }
        return ApiException(
          message: message ?? 'Request failed',
          statusCode: statusCode,
        );
      default:
        return ApiException(message: e.message ?? 'Unknown error occurred');
    }
  }
}
