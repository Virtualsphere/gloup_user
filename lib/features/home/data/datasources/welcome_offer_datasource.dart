import 'package:flutter/foundation.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/home/domain/entities/welcome_offer.dart';

abstract class WelcomeOfferDataSource {
  /// The signed-in user's welcome offer, or null when there is none.
  /// Failures also return null: the pop-up is optional and must never
  /// block Home.
  Future<WelcomeOffer?> fetch();
}

class WelcomeOfferDataSourceImpl implements WelcomeOfferDataSource {
  final DioClient dioClient;

  WelcomeOfferDataSourceImpl(this.dioClient);

  @override
  Future<WelcomeOffer?> fetch() async {
    try {
      final response = await dioClient.get(ApiRoutes.getWelcomeOffer);
      final body = response.data;
      if (response.statusCode == 200 &&
          body is Map &&
          body['success'] == true) {
        return WelcomeOffer.tryParse(body['data']);
      }
    } catch (e) {
      debugPrint('Welcome offer unavailable: $e');
    }
    return null;
  }
}
