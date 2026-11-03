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

      expect(find.text('Device Location Disabled'), findsOneWidget);
      expect(
        find.textContaining('Device location must be enabled before allowing a booking'),
        findsOneWidget,
      );
      expect(find.text('Open Location Settings'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Open Location Settings'));
      await tester.pump();
      expect(openSettingsCalled, isTrue);

      await tester.tap(find.text('Cancel'));
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

      expect(find.text('Location Permission Required'), findsOneWidget);
      expect(
        find.textContaining('Location permission is permanently denied'),
        findsOneWidget,
      );
      expect(find.text('Open App Settings'), findsOneWidget);

      await tester.tap(find.text('Open App Settings'));
      await tester.pump();
      expect(openSettingsCalled, isTrue);
    });
  });
}
