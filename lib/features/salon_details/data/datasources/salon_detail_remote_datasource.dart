import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/salon_details/data/models/salon_detail_model.dart';
import 'package:tressy/features/salon_details/data/models/salon_mock_data.dart';

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
    // TODO: Replace with actual API call
    // Example:
    // final response = await dioClient.get('/api/v1/salons/$salonId');
    // return SalonDetailModel.fromJson(response.data);

    // For now, return mock data with simulated API delay
    return await _simulateApiCall(
      SalonMockData.getSalonDetails(),
      delaySeconds: 2,
    );
  }

  /// Simulates an API call with a delay
  Future<T> _simulateApiCall<T>(T data, {int delaySeconds = 2}) async {
    await Future.delayed(Duration(seconds: delaySeconds));
    return data;
  }
}
