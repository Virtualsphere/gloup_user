import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';
import 'package:tressy/features/home/presentation/widgets/home_salon_card.dart';
import 'package:tressy/features/home/presentation/widgets/home_sort_sheet.dart';
import 'package:tressy/features/home/presentation/widgets/salon_list_header.dart';
import 'package:tressy/shared/domain/entities/offer_badge.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

import '../../helpers/widget_test_helpers.dart';

SalonEntity _salon({
  bool premium = false,
  OfferBadge? badge,
  List<Map<String, dynamic>>? services,
  String? serviceName,
  double distance = 1.234,
  String area = 'Anna Nagar',
  int reviews = 120,
}) =>
    SalonEntity(
      id: '7',
      salonName: 'Glow Studio',
      salonImage: '',
      images: const [],
      rating: 4.46,
      reviewCount: reviews,
      distance: distance,
      address: area,
      displayAddress: area,
      isPremium: premium,
      isFavorite: false,
      serviceName: serviceName,
      dynamicServices: services,
      offerBadge: badge,
      categories: const [],
      languageCodes: const [],
    );

FavoritesBloc _favoritesBloc() {
  final bloc = MockFavoritesBloc();
  stubBlocBase<FavoritesBloc, FavoritesState>(bloc, const FavoritesState());
  when(() => bloc.add(any())).thenReturn(null);
  return bloc;
}

Widget _wrap(Widget child, {FavoritesBloc? favorites}) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => BlocProvider<FavoritesBloc>.value(
        value: favorites ?? _favoritesBloc(),
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );

Future<void> _tapChip(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  setUpAll(() async {
    registerWidgetTestFallbacks();
    await initWidgetTestStorage(preferences: {'is_logged_in': false});
  });

  group('HomeSalonCard helpers', () {
    test('compactCount abbreviates thousands', () {
      expect(HomeSalonCard.compactCount(950), '950');
      expect(HomeSalonCard.compactCount(2100), '2.1k');
      expect(HomeSalonCard.compactCount(2000), '2k');
      expect(HomeSalonCard.compactCount(12000), '12k');
    });

    test('servicesLine joins up to 3 distinct names', () {
      final line = HomeSalonCard.servicesLine(_salon(services: [
        {'name': 'Haircut'},
        {'name': 'Haircut'},
        {'name': 'Facial'},
        {'name': 'Spa'},
        {'name': 'Bleach'},
      ]));
      expect(line, 'Haircut · Facial · Spa');
    });

    test('servicesLine falls back to the headline service', () {
      expect(HomeSalonCard.servicesLine(_salon(serviceName: 'Shave')), 'Shave');
      expect(HomeSalonCard.servicesLine(_salon()), '');
    });

    test('distanceLine drops unknown parts', () {
      expect(HomeSalonCard.distanceLine(_salon()), '1.2 km · Anna Nagar');
      expect(HomeSalonCard.distanceLine(_salon(distance: 0)), 'Anna Nagar');
      expect(HomeSalonCard.distanceLine(_salon(area: '')), '1.2 km');
    });
  });

  group('HomeSalonCard', () {
    testWidgets('shows promoted tag, offer badge, rating and lines',
        (tester) async {
      await tester.pumpWidget(_wrap(HomeSalonCard(
        salon: _salon(
          premium: true,
          badge: const OfferBadge(percent: 50, flat: 0, label: '50% OFF'),
          services: [
            {'name': 'Haircut'}
          ],
        ),
        onTap: () {},
      )));
      expect(find.byKey(const Key('promoted_tag')), findsOneWidget);
      expect(find.text('50% OFF'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('120 ratings'), findsOneWidget);
      expect(find.text('Haircut'), findsOneWidget);
      expect(find.text('1.2 km · Anna Nagar'), findsOneWidget);
    });

    testWidgets('hides optional parts when data is missing', (tester) async {
      await tester.pumpWidget(_wrap(HomeSalonCard(
        salon: _salon(reviews: 0, distance: 0, area: ''),
        onTap: () {},
      )));
      expect(find.byKey(const Key('promoted_tag')), findsNothing);
      expect(find.byKey(const Key('offer_badge')), findsNothing);
      expect(find.byKey(const Key('rating_pill')), findsNothing);
      expect(find.byKey(const Key('services_line')), findsNothing);
      expect(find.byKey(const Key('distance_line')), findsNothing);
    });

    testWidgets('card tap fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(HomeSalonCard(
        salon: _salon(),
        onTap: () => taps++,
      )));
      await tester.tap(find.text('Glow Studio'));
      expect(taps, 1);
    });
  });

  group('SalonListHeader', () {
    test('countLabel pluralises', () {
      expect(SalonListHeader.countLabel(1), '1 salon around you');
      expect(SalonListHeader.countLabel(24), '24 salons around you');
    });

    testWidgets('shows count and quick picks update FilterState',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      FilterState? latest;
      await tester.pumpWidget(_wrap(SalonListHeader(
        totalRecords: 24,
        filters: FilterState.empty,
        onChanged: (f) => latest = f,
        onSortTap: () {},
      )));
      expect(find.text('24 salons around you'), findsOneWidget);

      await _tapChip(tester, 'chip_nearest');
      expect(latest?.sort, SalonSort.distance);

      await _tapChip(tester, 'chip_rating');
      expect(latest?.minRating, 4.0);

      await _tapChip(tester, 'chip_offers');
      expect(latest?.hasOffers, isTrue);
    });

    testWidgets('selected quick picks toggle off', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      FilterState? latest;
      await tester.pumpWidget(_wrap(SalonListHeader(
        totalRecords: 3,
        filters: const FilterState(
          sort: SalonSort.distance,
          minRating: 4.0,
          hasOffers: true,
        ),
        onChanged: (f) => latest = f,
        onSortTap: () {},
      )));
      await _tapChip(tester, 'chip_nearest');
      expect(latest?.sort, SalonSort.relevance);
      await _tapChip(tester, 'chip_rating');
      expect(latest?.minRating, isNull);
      await _tapChip(tester, 'chip_offers');
      expect(latest?.hasOffers, isFalse);
    });

    testWidgets('Filters chip only when a handler exists, with count',
        (tester) async {
      await tester.pumpWidget(_wrap(SalonListHeader(
        totalRecords: null,
        filters: FilterState.empty,
        onChanged: (_) {},
        onSortTap: () {},
      )));
      expect(find.text('Salons around you'), findsOneWidget);
      expect(find.byKey(const Key('chip_filters')), findsNothing);

      await tester.pumpWidget(_wrap(SalonListHeader(
        totalRecords: 5,
        filters: const FilterState(minRating: 4.0, hasOffers: true),
        onChanged: (_) {},
        onSortTap: () {},
        onFiltersTap: () {},
      )));
      expect(find.text('Filters 2'), findsOneWidget);
    });
  });

  testWidgets('HomeSortSheet returns the picked option', (tester) async {
    SalonSort? picked;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  picked = await HomeSortSheet.show(context, SalonSort.relevance),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sort_rating')));
    await tester.pumpAndSettle();
    expect(picked, SalonSort.rating);
  });
}
