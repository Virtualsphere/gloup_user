import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/salon_details/data/models/salon_detail_model.dart';

abstract class SalonDetailRemoteDataSource {
  /// Get detailed information about a specific salon
  Future<SalonDetailModel> getSalonDetails({
    required String salonId,
    String sex = 'unisex',
  });
}

class SalonDetailRemoteDataSourceImpl implements SalonDetailRemoteDataSource {
  final DioClient dioClient;

  SalonDetailRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SalonDetailModel> getSalonDetails({
    required String salonId,
    String sex = 'unisex',
  }) async {
    try {
      // Prepare request data
      final requestData = {
        'store_id': int.tryParse(salonId) ?? salonId,
        'sex': sex,
      };

      final response = await dioClient.post(
        ApiRoutes.getStoreDetails,
        data: requestData,
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
