import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/shared/widgets/location_required_dialog.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  Widget buildTestWidget({
    required LocationRequiredDialogType type,
    required VoidCallback onOpenSettings,
    required VoidCallback onCancel,
  }) {
    return buildTestMaterialApp(
      child: Scaffold(
        body: LocationRequiredDialog(
          type: type,
          onOpenSettings: onOpenSettings,
          onCancel: onCancel,
        ),
      ),
    );
  }

  group('LocationRequiredDialog', () {
    testWidgets('renders properly for serviceDisabled type', (tester) async {
      setWidgetTestScreenSize(tester, size: const Size(600, 1000));
      bool openSettingsCalled = false;
      bool cancelCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          type: LocationRequiredDialogType.serviceDisabled,
          onOpenSettings: () => openSettingsCalled = true,
          onCancel: () => cancelCalled = true,
        ),
      );

      expect(find.text('Device location is off'), findsOneWidget);
      expect(
        find.textContaining('Turn on GPS so we can confirm your booking'),
        findsOneWidget,
      );
      expect(find.text('Turn on GPS'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);

      await tester.tap(find.text('Turn on GPS'));
      await tester.pump();
      expect(openSettingsCalled, isTrue);

      await tester.tap(find.text('Not now'));
      await tester.pump();
      expect(cancelCalled, isTrue);
    });

    testWidgets('renders properly for permissionDeniedForever type',
        (tester) async {
      setWidgetTestScreenSize(tester, size: const Size(600, 1000));
      bool openSettingsCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          type: LocationRequiredDialogType.permissionDeniedForever,
          onOpenSettings: () => openSettingsCalled = true,
          onCancel: () {},
        ),
      );

      expect(find.text('Allow location in Settings'), findsOneWidget);
      expect(
        find.textContaining("You've blocked location for GloUp"),
        findsOneWidget,
      );
      expect(find.text('Open settings'), findsOneWidget);

      await tester.tap(find.text('Open settings'));
      await tester.pump();
      expect(openSettingsCalled, isTrue);
    });
  });
}
