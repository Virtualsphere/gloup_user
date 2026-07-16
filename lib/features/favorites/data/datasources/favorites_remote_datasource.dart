import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/favorites/data/models/favorite_model.dart';
import 'package:tressy/features/favorites/data/models/favorites_list_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<FavoriteModel> toggleFavorite(int storeId);
  Future<FavoritesListModel> getFavorites();
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final DioClient dioClient;

  FavoritesRemoteDataSourceImpl(this.dioClient);

  @override
  Future<FavoriteModel> toggleFavorite(int storeId) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.toggleFavorite,
        data: {
          'store_id': storeId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FavoriteModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to toggle favorite',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<FavoritesListModel> getFavorites() async {
    try {
      final response = await dioClient.get(ApiRoutes.getFavorites);

      if (response.statusCode == 200) {
        return FavoritesListModel.fromJson(
          response.data,
          imageBaseUrl: ApiRoutes.imageBaseUrl,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch favorites',
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
