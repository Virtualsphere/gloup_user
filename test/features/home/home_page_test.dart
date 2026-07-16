import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/features/home/data/datasources/service_discovery_datasource.dart';
import 'package:tressy/features/home/presentation/pages/home_page.dart';

import '../../helpers/widget_test_helpers.dart';

class MockServiceDiscoveryDataSource extends Mock
    implements ServiceDiscoveryDataSource {}

void main() {
  late MockHomeBloc homeBloc;
  late MockServiceDiscoveryDataSource serviceDiscovery;

  setUpAll(() async {
    registerWidgetTestFallbacks();
    await initWidgetTestStorage(
      preferences: {
        'is_logged_in': false,
        'location_permission_dialog_shown': true,
      },
    );
  });

  setUp(() {
    homeBloc = MockHomeBloc();
    stubHomeBlocLoading(homeBloc);

    serviceDiscovery = MockServiceDiscoveryDataSource();
    when(() => serviceDiscovery.getTopCategories(sex: any(named: 'sex')))
        .thenAnswer((_) async => []);

    if (sl.isRegistered<ServiceDiscoveryDataSource>()) {
      sl.unregister<ServiceDiscoveryDataSource>();
    }
    sl.registerLazySingleton<ServiceDiscoveryDataSource>(() => serviceDiscovery);
  });

  tearDown(() {
    if (sl.isRegistered<ServiceDiscoveryDataSource>()) {
      sl.unregister<ServiceDiscoveryDataSource>();
    }
  });

  testWidgets('shows shimmer placeholders while home data is loading',
      (tester) async {
    setWidgetTestScreenSize(tester);

    await tester.pumpWidget(
      buildHomePageTestHarness(
        homeBloc: homeBloc,
        child: const HomePage(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    while (tester.takeException() != null) {}

    expect(find.byType(Shimmer), findsWidgets);
    expect(find.byIcon(Icons.cut_outlined), findsWidgets);
  });
}
