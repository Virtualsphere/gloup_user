import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/features/home/data/models/service_category_model.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';
import 'package:tressy/features/home/presentation/widgets/home_category_grid.dart';
import 'package:tressy/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:tressy/features/home/presentation/widgets/popular_services_rail.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

ServiceCategoryModel _service(int price, int? mrp) => ServiceCategoryModel(
      id: '1',
      name: 'Haircut',
      searchCategory: 'Hair cut -M',
      discountedAmount: price,
      amount: mrp,
    );

void main() {
  group('ServiceCategoryModel', () {
    test('parses amount as MRP', () {
      final m = ServiceCategoryModel.fromJson({
        'category_id': 3,
        'category_name': 'Haircut',
        'discounted_amount': 199,
        'amount': 299,
      });
      expect(m.amount, 299);
    });

    test('amount is null when the API omits it', () {
      final m = ServiceCategoryModel.fromJson(
          {'category_id': 3, 'discounted_amount': 199});
      expect(m.amount, isNull);
    });
  });

  group('PopularServicesRail', () {
    test('struckPrice only when MRP is higher', () {
      expect(PopularServicesRail.struckPrice(_service(199, 299)), 299);
      expect(PopularServicesRail.struckPrice(_service(199, 199)), isNull);
      expect(PopularServicesRail.struckPrice(_service(199, null)), isNull);
    });

    testWidgets('shows price and struck MRP and handles tap', (tester) async {
      ServiceCategoryModel? tapped;
      await tester.pumpWidget(_wrap(PopularServicesRail(
        services: [_service(199, 299)],
        onServiceTap: (s) => tapped = s,
        onSeeAll: () {},
      )));
      expect(find.text('Popular services nearby'), findsOneWidget);
      expect(find.text('₹199'), findsOneWidget);
      expect(find.text('₹299'), findsOneWidget);

      await tester.tap(find.byKey(const Key('service_0')));
      expect(tapped?.name, 'Haircut');
    });

    testWidgets('hides when empty and not loading', (tester) async {
      await tester.pumpWidget(_wrap(PopularServicesRail(
        services: const [],
        onServiceTap: (_) {},
        onSeeAll: () {},
      )));
      expect(find.text('Popular services nearby'), findsNothing);
    });

    testWidgets('shows skeleton while loading', (tester) async {
      await tester.pumpWidget(_wrap(PopularServicesRail(
        services: const [],
        isLoading: true,
        onServiceTap: (_) {},
        onSeeAll: () {},
      )));
      expect(find.byKey(const Key('services_skeleton')), findsOneWidget);
    });
  });

  group('HomeCategoryGrid', () {
    List<CategoryEntity> cats(int n) => [
          for (var i = 0; i < n; i++)
            CategoryEntity(id: '$i', label: 'Cat $i', imageUrl: ''),
        ];

    testWidgets('caps at 8 tiles', (tester) async {
      await tester.pumpWidget(_wrap(HomeCategoryGrid(
        categories: cats(12),
        onCategoryTap: (_, __) {},
        onSeeAll: () {},
      )));
      expect(find.byKey(const Key('category_7')), findsOneWidget);
      expect(find.byKey(const Key('category_8')), findsNothing);
    });

    testWidgets('tap and See all callbacks fire', (tester) async {
      CategoryEntity? tapped;
      var seeAll = 0;
      await tester.pumpWidget(_wrap(HomeCategoryGrid(
        categories: cats(4),
        onCategoryTap: (c, _) => tapped = c,
        onSeeAll: () => seeAll++,
      )));
      await tester.tap(find.byKey(const Key('category_2')));
      expect(tapped?.id, '2');
      await tester.tap(find.byKey(const Key('category_see_all')));
      expect(seeAll, 1);
    });

    testWidgets('skeleton and error states', (tester) async {
      await tester.pumpWidget(_wrap(HomeCategoryGrid(
        categories: const [],
        isLoading: true,
        onCategoryTap: (_, __) {},
        onSeeAll: () {},
      )));
      expect(find.byKey(const Key('category_skeleton')), findsOneWidget);

      var retried = false;
      await tester.pumpWidget(_wrap(HomeCategoryGrid(
        categories: const [],
        error: 'boom',
        onRetry: () => retried = true,
        onCategoryTap: (_, __) {},
        onSeeAll: () {},
      )));
      expect(find.byKey(const Key('category_error')), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('HomeHeroBanner', () {
    testWidgets('skeleton while loading, empty collapses', (tester) async {
      await tester.pumpWidget(_wrap(const HomeHeroBanner(
        banners: [],
        isLoading: true,
      )));
      expect(find.byKey(const Key('hero_banner_skeleton')), findsOneWidget);

      await tester.pumpWidget(_wrap(const HomeHeroBanner(banners: [])));
      expect(find.byKey(const Key('hero_banner_skeleton')), findsNothing);
      expect(find.byKey(const Key('hero_banner_dots')), findsNothing);
    });

    testWidgets('dots show for multiple banners and tap reports banner',
        (tester) async {
      CarouselBannerEntity? tapped;
      await tester.pumpWidget(_wrap(HomeHeroBanner(
        banners: const [
          CarouselBannerEntity(id: 'a', imageUrl: ''),
          CarouselBannerEntity(id: 'b', imageUrl: ''),
        ],
        autoPlayInterval: const Duration(hours: 1),
        onBannerTap: (b) => tapped = b,
      )));
      expect(find.byKey(const Key('hero_banner_dots')), findsOneWidget);
      await tester.tap(find.byKey(const Key('hero_banner_0')));
      expect(tapped?.id, 'a');
    });
  });
}
