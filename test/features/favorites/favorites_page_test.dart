import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/features/favorites/presentation/pages/favorites_page.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

import '../../helpers/widget_test_helpers.dart';

SalonEntity _salon(String id, String name) => SalonEntity(
      id: id,
      salonName: name,
      salonImage: '',
      images: const [],
      rating: 4.5,
      reviewCount: 10,
      distance: 1,
      address: 'Adyar',
      displayAddress: 'Adyar',
      isPremium: false,
      isFavorite: true,
      categories: const [],
      languageCodes: const [],
    );

void main() {
  late MockFavoritesBloc bloc;

  setUpAll(() async {
    registerWidgetTestFallbacks();
    await initWidgetTestStorage(preferences: {'is_logged_in': true});
    await LocalStorageService.setAccessToken('test-token');
  });

  setUp(() {
    bloc = MockFavoritesBloc();
    final state = FavoritesState(
      listStatus: FavoritesListStatus.loaded,
      favoritesList: [_salon('1', 'Alpha Salon'), _salon('2', 'Beta Salon')],
    );
    stubBlocBase<FavoritesBloc, FavoritesState>(bloc, state);
    when(() => bloc.add(any())).thenReturn(null);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    setWidgetTestScreenSize(tester, size: const Size(900, 1600));
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => BlocProvider<FavoritesBloc>.value(
        value: bloc,
        child: const MaterialApp(home: FavoritesPage()),
      ),
    ));
    await tester.pump();
  }

  testWidgets('shows title, saved count and salons', (tester) async {
    await pumpPage(tester);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('2 saved'), findsOneWidget);
    expect(find.text('Alpha Salon'), findsOneWidget);
    expect(find.text('Beta Salon'), findsOneWidget);
  });

  testWidgets('removing a heart hides the card, offers Undo, and Undo restores',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('fav_heart')).first);
    await tester.pumpAndSettle();
    expect(find.text('Alpha Salon'), findsNothing);
    expect(find.text('1 saved'), findsOneWidget);
    expect(find.text('Removed Alpha Salon'), findsOneWidget);
    verify(() => bloc.add(const ToggleFavoriteEvent(1, true))).called(1);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha Salon'), findsOneWidget);
    expect(find.text('2 saved'), findsOneWidget);
    verify(() => bloc.add(const ToggleFavoriteEvent(1, false))).called(1);
  });

  testWidgets('empty list shows the empty state', (tester) async {
    stubBlocBase<FavoritesBloc, FavoritesState>(
      bloc,
      const FavoritesState(listStatus: FavoritesListStatus.loaded),
    );
    await pumpPage(tester);
    expect(find.byKey(const Key('favorites_empty')), findsOneWidget);
    expect(find.text('0 saved'), findsOneWidget);
  });
}
