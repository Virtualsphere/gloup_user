import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/category/presentation/widgets/category_salon_row.dart';
import 'package:tressy/shared/domain/entities/offer_badge.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

SalonEntity _salon({
  List<Map<String, dynamic>>? services,
  String? serviceName,
  double? servicePrice,
  OfferBadge? badge,
  int reviews = 86,
  double distance = 0.84,
}) =>
    SalonEntity(
      id: '3',
      salonName: 'Trim House',
      salonImage: '',
      images: const [],
      rating: 4.3,
      reviewCount: reviews,
      distance: distance,
      address: 'Anna Nagar',
      displayAddress: 'Anna Nagar',
      isPremium: false,
      isFavorite: false,
      serviceName: serviceName,
      servicePrice: servicePrice,
      dynamicServices: services,
      offerBadge: badge,
      categories: const [],
      languageCodes: const [],
    );

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  group('CategoryServicePrice.forSalon', () {
    test('picks the cheapest matching service and its MRP', () {
      final p = CategoryServicePrice.forSalon(
        _salon(services: [
          {'name': 'Kids Haircut', 'price': 249, 'discountedPrice': 199},
          {'name': 'Hair cut', 'price': 149, 'discountedPrice': 99},
          {'name': 'Facial', 'price': 500, 'discountedPrice': 400},
        ]),
        'Haircut',
      )!;
      expect(p.price, 99);
      expect(p.mrp, 149);
      expect(p.name, 'Hair cut');
    });

    test('no MRP when there is no discount', () {
      final p = CategoryServicePrice.forSalon(
        _salon(services: [
          {'name': 'Haircut', 'price': 120, 'discountedPrice': 120},
        ]),
        'Haircut',
      )!;
      expect(p.mrp, isNull);
    });

    test('falls back to the headline service, then null', () {
      final fallback = CategoryServicePrice.forSalon(
        _salon(serviceName: 'Shave', servicePrice: 60),
        'Haircut',
      )!;
      expect(fallback.name, 'Shave');
      expect(fallback.price, 60);
      expect(CategoryServicePrice.forSalon(_salon(), 'Haircut'), isNull);
    });

    test('handles string prices from the API', () {
      final p = CategoryServicePrice.forSalon(
        _salon(services: [
          {'name': 'Haircut', 'price': '149', 'discountedPrice': '99'},
        ]),
        'Haircut',
      )!;
      expect(p.price, 99);
      expect(p.mrp, 149);
    });
  });

  group('CategorySalonRow', () {
    testWidgets('shows badge, rating, meta, price and Book', (tester) async {
      var booked = 0;
      var tapped = 0;
      await tester.pumpWidget(_wrap(CategorySalonRow(
        salon: _salon(
          badge: const OfferBadge(percent: 0, flat: 50, label: '₹50 OFF'),
          services: [
            {'name': 'Haircut', 'price': 149, 'discountedPrice': 99},
          ],
        ),
        categoryName: 'Haircut',
        onTap: () => tapped++,
        onBook: () => booked++,
      )));
      expect(find.text('₹50 OFF'), findsOneWidget);
      expect(find.text('4.3'), findsOneWidget);
      expect(find.text('86 reviews · 0.8 km'), findsOneWidget);
      expect(find.textContaining('Haircut from ₹99', findRichText: true),
          findsOneWidget);
      expect(find.textContaining('₹149', findRichText: true), findsOneWidget);

      await tester.tap(find.byKey(const Key('row_book')));
      expect(booked, 1);
      await tester.tap(find.text('Trim House'));
      expect(tapped, 1);
    });

    testWidgets('hides optional parts when data is missing', (tester) async {
      await tester.pumpWidget(_wrap(CategorySalonRow(
        salon: _salon(reviews: 0, distance: 0),
        categoryName: 'Haircut',
        onTap: () {},
        onBook: () {},
      )));
      expect(find.byKey(const Key('row_offer_badge')), findsNothing);
      expect(find.byKey(const Key('row_rating_pill')), findsNothing);
      expect(find.byKey(const Key('row_meta')), findsNothing);
      expect(find.byKey(const Key('row_price')), findsNothing);
    });
  });
}
