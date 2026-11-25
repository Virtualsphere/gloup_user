import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';
import 'package:tressy/features/home/presentation/widgets/filters_sheet.dart';

/// Opens the sheet from a button and records what it returns.
class _Harness {
  FilterState? result;
  final drafts = <FilterState>[];
}

Future<_Harness> _open(
  WidgetTester tester, {
  FilterState initial = FilterState.empty,
  Future<int?> Function(FilterState)? count,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final h = _Harness();
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => h.result = await FiltersSheet.show(
              context,
              initial: initial,
              countFor: (d) {
                h.drafts.add(d);
                return count?.call(d) ?? Future.value(38);
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return h;
}

void main() {
  group('paneHasSelection', () {
    test('dots follow the selected filters, never sort', () {
      const f = FilterState(
        sort: SalonSort.rating,
        gender: GenderFilter.female,
        minRating: 4.0,
        maxPrice: 300,
        hasOffers: true,
        maxDistanceKm: 2,
      );
      for (final pane in FilterPane.values) {
        expect(FiltersSheet.paneHasSelection(pane, f),
            pane != FilterPane.sort, reason: pane.name);
      }
      for (final pane in FilterPane.values) {
        expect(FiltersSheet.paneHasSelection(pane, FilterState.empty), isFalse);
      }
    });
  });

  testWidgets('shows live count and applies the draft', (tester) async {
    final h = await _open(tester);
    expect(find.text('Show 38 salons'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quick_rating')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(h.drafts.last.minRating, 4.0);
    expect(find.byKey(const Key('dot_rating')), findsOneWidget);

    await tester.tap(find.byKey(const Key('filters_apply')));
    await tester.pumpAndSettle();
    expect(h.result?.minRating, 4.0);
  });

  testWidgets('close returns nothing', (tester) async {
    final h = await _open(tester);
    await tester.tap(find.byKey(const Key('filters_close')));
    await tester.pumpAndSettle();
    expect(h.result, isNull);
    expect(find.byKey(const Key('filters_apply')), findsNothing);
  });

  testWidgets('panes edit sort, price, distance, offers and gender',
      (tester) async {
    final h = await _open(tester);

    await tester.tap(find.byKey(const Key('sort_priceLowToHigh')));
    await tester.tap(find.byKey(const Key('rail_price')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('price_1')));
    await tester.tap(find.byKey(const Key('rail_distance')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('distance_5')));
    await tester.tap(find.byKey(const Key('rail_offers')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('offers_switch')));
    await tester.tap(find.byKey(const Key('rail_gender')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('gender_female')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('filters_apply')));
    await tester.pumpAndSettle();
    final r = h.result!;
    expect(r.sort, SalonSort.priceLowToHigh);
    expect(r.minPrice, 300);
    expect(r.maxPrice, 600);
    expect(r.maxDistanceKm, 5);
    expect(r.hasOffers, isTrue);
    expect(r.gender, GenderFilter.female);
  });

  testWidgets('Clear all resets the draft', (tester) async {
    final h = await _open(
      tester,
      initial: const FilterState(minRating: 4.0, hasOffers: true),
    );
    await tester.tap(find.byKey(const Key('filters_clear')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('filters_apply')));
    await tester.pumpAndSettle();
    expect(h.result, FilterState.empty);
  });

  testWidgets('zero matches disables Show; failed count keeps it usable',
      (tester) async {
    await _open(tester, count: (_) async => 0);
    final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('filters_apply')));
    expect(button.onPressed, isNull);
    expect(find.text('Show 0 salons'), findsOneWidget);
  });

  testWidgets('count error falls back to a generic label', (tester) async {
    await _open(tester, count: (_) async => throw Exception('boom'));
    expect(find.text('Show salons'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('filters_apply')));
    expect(button.onPressed, isNotNull);
  });
}
