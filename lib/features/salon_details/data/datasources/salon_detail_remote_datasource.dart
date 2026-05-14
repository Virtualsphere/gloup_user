import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/salon_details/data/models/salon_detail_model.dart';

abstract class SalonDetailRemoteDataSource {
  /// Get detailed information about a specific salon
  Future<SalonDetailModel> getSalonDetails({
    required String salonId,
  });
}

class SalonDetailRemoteDataSourceImpl implements SalonDetailRemoteDataSource {
  final DioClient dioClient;

  SalonDetailRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SalonDetailModel> getSalonDetails({
    required String salonId,
  }) async {
    try {
      // Prepare request data
      final requestData = {
        'store_id': int.tryParse(salonId) ?? salonId,
      };

      // Get auth token if available
      final token = LocalStorageService.accessToken;

      final response = await dioClient.post(
        ApiRoutes.getStoreDetails,
        data: requestData,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
      );

      // Check if response is successful
      if (response.data['success'] == true) {
        return SalonDetailModel.fromJson(
          response.data,
          imageBaseUrl: ApiRoutes.imageBaseUrl,
        );
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to load salon details',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message:
              e.response?.data['message'] ?? 'Failed to load salon details',
          statusCode: e.response?.statusCode,
          error: e,
        );
      } else {
        throw ApiException(
          message: e.message ?? 'Network error occurred',
          error: e,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'An unexpected error occurred: ${e.toString()}',
        error: e,
      );
    }
  }
}
