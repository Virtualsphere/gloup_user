import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/coupons/data/models/coupon_model.dart';

abstract class CouponRemoteDataSource {
  Future<List<CouponModel>> getActiveCoupons();
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final DioClient dioClient;

  CouponRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<CouponModel>> getActiveCoupons() async {
    try {
      final response = await dioClient.get(
        ApiRoutes.getActiveCoupons,
        options: Options(
          headers: {'userauth': LocalStorageService.accessToken},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> couponsJson = data['data'] as List<dynamic>;
          return couponsJson
              .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Invalid response format',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch coupons',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
