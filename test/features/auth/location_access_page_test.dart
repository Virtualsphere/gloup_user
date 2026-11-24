import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/auth/presentation/pages/location_access_page.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() async {
    registerWidgetTestFallbacks();
    await initWidgetTestStorage();
  });

  Future<void> pumpLocationAccessPage(WidgetTester tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));
    await tester.pumpWidget(
      buildTestMaterialApp(
        child: const LocationAccessPage(),
      ),
    );
    await tester.pump();
  }

  group('LocationAccessPage Figma Node 57-2', () {
    testWidgets('renders all Step 2 elements properly', (tester) async {
      await pumpLocationAccessPage(tester);

      expect(find.text('STEP 2 OF 2'), findsOneWidget);
      expect(find.text('Find salons around you'), findsOneWidget);
      expect(
        find.text(
            'Allow location access to see salons nearby, real travel distance and today\'s open slots.'),
        findsOneWidget,
      );
      expect(
        find.text("Used only while you're using GloUp"),
        findsOneWidget,
      );
      expect(
        find.text('Never shared with salons'),
        findsOneWidget,
      );
      expect(find.text('Allow location access'), findsOneWidget);
      expect(find.text('Enter location manually'), findsOneWidget);
    });

    testWidgets('allow location button is present and clickable',
        (tester) async {
      await pumpLocationAccessPage(tester);

      final allowBtn = find.text('Allow location access');
      expect(allowBtn, findsOneWidget);
      await tester.tap(allowBtn);
      await tester.pump();
    });

    testWidgets('enter manually button is present and clickable',
        (tester) async {
      await pumpLocationAccessPage(tester);

      final manualBtn = find.text('Enter location manually');
      expect(manualBtn, findsOneWidget);
      await tester.tap(manualBtn);
      await tester.pump();
    });
  });
}
