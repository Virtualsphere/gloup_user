import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/profile/data/models/profile_model.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileEntity profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl(this.dioClient);

  //get profile:-
  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dioClient.get(
        ApiRoutes.getUserProfile,
        options: Options(
          headers: {'userauth': LocalStorageService.accessToken},
        ),
      );
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(
          response.data['data'],
          imageBaseUrl: ApiRoutes.imageBaseUrl,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  //update profile:-
  @override
  Future<ProfileModel> updateProfile(ProfileEntity profile) async {
    try {
      final model = ProfileModel.fromEntity(profile);
      final formData = await model.toFormData();

      final response = await dioClient.patch(
        ApiRoutes.getUserProfile,
        data: formData,
        options: Options(
          headers: {
            'userauth': LocalStorageService.accessToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        return model;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Update failed',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
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
