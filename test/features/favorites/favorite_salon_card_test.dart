import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/favorites/presentation/widgets/favorite_salon_card.dart';
import 'package:tressy/shared/domain/entities/offer_badge.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

SalonEntity _salon({
  OfferBadge? badge,
  int reviews = 40,
  double distance = 1.26,
  String area = 'Adyar',
  List<Map<String, dynamic>>? services,
}) =>
    SalonEntity(
      id: '5',
      salonName: 'Velvet Cuts',
      salonImage: '',
      images: const [],
      rating: 4.7,
      reviewCount: reviews,
      distance: distance,
      address: area,
      displayAddress: area,
      isPremium: false,
      isFavorite: true,
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
  test('detailLine joins services and distance, dropping unknowns', () {
    expect(
      FavoriteSalonCard.detailLine(_salon(services: [
        {'name': 'Haircut'},
        {'name': 'Facial'},
      ])),
      'Haircut · Facial · 1.3 km',
    );
    expect(FavoriteSalonCard.detailLine(_salon(distance: 0)), '');
    expect(FavoriteSalonCard.detailLine(_salon()), '1.3 km');
  });

  testWidgets('shows rating, detail, area and offer text', (tester) async {
    await tester.pumpWidget(_wrap(FavoriteSalonCard(
      salon: _salon(
        badge: const OfferBadge(percent: 50, flat: 0, label: '50% OFF'),
        services: [
          {'name': 'Haircut'}
        ],
      ),
      onTap: () {},
      onRemove: () {},
    )));
    expect(find.text('Velvet Cuts'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('(40)'), findsOneWidget);
    expect(find.text('Haircut · 1.3 km'), findsOneWidget);
    expect(find.text('Adyar'), findsOneWidget);
    expect(find.text('50% OFF'), findsOneWidget);
  });

  testWidgets('hides optional parts when data is missing', (tester) async {
    await tester.pumpWidget(_wrap(FavoriteSalonCard(
      salon: _salon(reviews: 0, distance: 0, area: ''),
      onTap: () {},
      onRemove: () {},
    )));
    expect(find.byKey(const Key('fav_rating_pill')), findsNothing);
    expect(find.byKey(const Key('fav_detail')), findsNothing);
    expect(find.byKey(const Key('fav_offer')), findsNothing);
  });

  testWidgets('heart and card taps are separate', (tester) async {
    var removed = 0;
    var opened = 0;
    await tester.pumpWidget(_wrap(FavoriteSalonCard(
      salon: _salon(),
      onTap: () => opened++,
      onRemove: () => removed++,
    )));
    await tester.tap(find.byKey(const Key('fav_heart')));
    expect(removed, 1);
    expect(opened, 0);
    await tester.tap(find.text('Velvet Cuts'));
    expect(opened, 1);
  });

  testWidgets('collapses when removed', (tester) async {
    Widget build(bool removed) => _wrap(FavoriteSalonCard(
          salon: _salon(),
          removed: removed,
          onTap: () {},
          onRemove: () {},
        ));
    await tester.pumpWidget(build(false));
    final before = tester.getSize(find.byType(FavoriteSalonCard)).height;
    expect(before, greaterThan(50));

    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(FavoriteSalonCard)).height, 0);
    expect(find.text('Velvet Cuts'), findsNothing);
  });
}
