import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/features/category/presentation/widgets/category_salon_row.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/features/favorites/presentation/widgets/favorite_salon_card.dart';
import 'package:tressy/features/home/data/models/service_category_model.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart' show CarouselBannerEntity;
import 'package:tressy/features/home/domain/entities/home_gender.dart';
import 'package:tressy/features/home/domain/entities/welcome_offer.dart';
import 'package:tressy/features/home/presentation/widgets/filters_sheet.dart';
import 'package:tressy/features/home/presentation/widgets/home_category_grid.dart';
import 'package:tressy/features/home/presentation/widgets/home_header.dart';
import 'package:tressy/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:tressy/features/home/presentation/widgets/home_salon_card.dart';
import 'package:tressy/features/home/presentation/widgets/popular_services_rail.dart';
import 'package:tressy/features/home/presentation/widgets/salon_list_header.dart';
import 'package:tressy/features/home/presentation/widgets/welcome_offer_dialog.dart';
import 'package:tressy/shared/domain/entities/offer_badge.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

import '../../helpers/widget_test_helpers.dart';

/// Stress layouts: 360 dp phone, 1.5x text, light and dark. A RenderFlex
/// overflow or any build error fails the test.
final _salon = SalonEntity(
  id: '1',
  salonName: 'A Very Long Salon Name That Should Truncate Nicely Somewhere',
  salonImage: '',
  images: const [],
  rating: 4.5,
  reviewCount: 1234,
  distance: 12.3,
  address: 'Some Long Neighbourhood Name, Chennai',
  displayAddress: 'Some Long Neighbourhood Name, Chennai',
  isPremium: true,
  isFavorite: true,
  dynamicServices: const [
    {'name': 'Premium Hair Spa Treatment', 'price': 1499, 'discountedPrice': 999},
    {'name': 'Keratin Smoothening', 'price': 5000, 'discountedPrice': 3999},
    {'name': 'Bridal Makeup', 'price': 9000, 'discountedPrice': 8000},
  ],
  offerBadge: const OfferBadge(percent: 50, flat: 0, label: 'FLAT ₹1500 OFF'),
  categories: const [],
  languageCodes: const [],
);

Widget _host(Widget child, {required bool dark, FavoritesBloc? favorites}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => BlocProvider<FavoritesBloc>.value(
      value: favorites!,
      child: MaterialApp(
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: c!,
        ),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

void main() {
  late FavoritesBloc favorites;

  setUpAll(() async {
    registerWidgetTestFallbacks();
    await initWidgetTestStorage(preferences: {'is_logged_in': false});
  });

  setUp(() {
    final bloc = MockFavoritesBloc();
    stubBlocBase<FavoritesBloc, FavoritesState>(bloc, const FavoritesState());
    when(() => bloc.add(any())).thenReturn(null);
    favorites = bloc;
  });

  final widgets = <String, Widget Function()>{
    'HomeHeader': () => HomeHeader(
          title: 'A Really Long Neighbourhood Name',
          subtitle: 'Chennai (set manually)',
          isLoadingLocation: false,
          onLocationTap: () {},
          walletLabel: '₹12,500',
          avatar: const CircleAvatar(radius: 20),
          onSearchTap: () {},
          gender: const HomeGender(),
          onGenderChanged: (_) {},
        ),
    'HomeHeroBanner': () => HomeHeroBanner(
          banners: const [
            CarouselBannerEntity(id: 'a', imageUrl: ''),
            CarouselBannerEntity(id: 'b', imageUrl: ''),
          ],
          autoPlayInterval: const Duration(hours: 1),
        ),
    'HomeCategoryGrid': () => HomeCategoryGrid(
          categories: [
            for (var i = 0; i < 8; i++)
              CategoryEntity(id: '$i', label: 'Long Category Name $i', imageUrl: ''),
          ],
          onCategoryTap: (_, __) {},
          onSeeAll: () {},
        ),
    'PopularServicesRail': () => PopularServicesRail(
          services: const [
            ServiceCategoryModel(
              id: '1',
              name: 'Premium Hair Spa Treatment',
              searchCategory: '',
              discountedAmount: 1999,
              amount: 2999,
            ),
          ],
          onServiceTap: (_) {},
          onSeeAll: () {},
        ),
    'SalonListHeader': () => SalonListHeader(
          totalRecords: 1234,
          filters: const FilterState(minRating: 4.0, hasOffers: true),
          onChanged: (_) {},
          onSortTap: () {},
          onFiltersTap: () {},
        ),
    'HomeSalonCard': () => HomeSalonCard(salon: _salon, onTap: () {}),
    'CategorySalonRow': () => CategorySalonRow(
          salon: _salon,
          categoryName: 'Hair Spa',
          onTap: () {},
          onBook: () {},
        ),
    'FavoriteSalonCard': () => FavoriteSalonCard(
          salon: _salon,
          onTap: () {},
          onRemove: () {},
        ),
  };

  for (final dark in [false, true]) {
    for (final entry in widgets.entries) {
      testWidgets('${entry.key} fits 360dp at 1.5x text (${dark ? 'dark' : 'light'})',
          (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _host(entry.value(), dark: dark, favorites: favorites),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('WelcomeOfferDialog fits 360dp at 1.5x text', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: c!,
        ),
        home: Scaffold(
          body: WelcomeOfferDialog(
            offer: const WelcomeOffer(
              couponId: 1,
              code: 'GLOWNEW',
              title: 'Flat 50% off your first booking',
              description: 'Up to ₹100 off on any service. Valid for 48 hours.',
            ),
            onBookSalon: () {},
            onTerms: () {},
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('FiltersSheet fits 360x640 at 1.5x text', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: c!,
        ),
        home: Scaffold(
          body: FiltersSheet(
            initial: FilterState.empty,
            countFor: (_) async => 38,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
