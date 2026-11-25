import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/shared/data/models/salon_model.dart';
import 'package:tressy/shared/domain/entities/offer_badge.dart';

Map<String, dynamic> _salon({Object? offerBadge}) => {
      'id': 7,
      'salonName': "The Barber's Room",
      'rating': 4.7,
      'reviewCount': 2100,
      'distance': 0.8,
      'dynamicServices': [
        {'name': 'Haircut', 'price': 149, 'discountedPrice': 99},
      ],
      if (offerBadge != null) 'offerBadge': offerBadge,
    };

void main() {
  group('OfferBadge.tryParse', () {
    test('parses the backend payload', () {
      final badge = OfferBadge.tryParse({
        'type': 'percentage',
        'percent': 34,
        'flat': 50,
        'label': '34% OFF',
        'serviceName': 'Haircut',
      });
      expect(badge, isNotNull);
      expect(badge!.percent, 34);
      expect(badge.flat, 50);
      expect(badge.label, '34% OFF');
      expect(badge.serviceName, 'Haircut');
    });

    test('builds a label when missing', () {
      expect(OfferBadge.tryParse({'percent': 20, 'flat': 30})!.label, '20% OFF');
    });

    test('returns null for null, wrong type or empty discount', () {
      expect(OfferBadge.tryParse(null), isNull);
      expect(OfferBadge.tryParse('x'), isNull);
      expect(OfferBadge.tryParse({'percent': 0, 'flat': 0}), isNull);
    });
  });

  group('SalonModel offerBadge', () {
    test('is parsed and carried to the entity', () {
      final model = SalonModel.fromJson(
        _salon(offerBadge: {'percent': 34, 'flat': 50, 'label': '34% OFF'}),
      );
      expect(model.offerBadge?.percent, 34);
      expect(model.toEntity().offerBadge, model.offerBadge);
      expect(model.toJson()['offerBadge'], isA<Map>());
    });

    test('is null when the backend sends none', () {
      final model = SalonModel.fromJson(_salon());
      expect(model.offerBadge, isNull);
      expect(model.toJson()['offerBadge'], isNull);
      expect(model.dynamicServices, isNotNull);
    });
  });
}
