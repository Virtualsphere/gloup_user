import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/core/constants/cancellation_policy.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerWidgetTestFallbacks();
  });

  testWidgets('shows 2-hour cancellation policy in not-allowed dialog',
      (tester) async {
    await tester.pumpWidget(
      buildTestMaterialApp(
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      CustomDialogues.showNotAllowedCancelDialogue(context),
                  child: const Text('Open dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Cancellation not allowed'), findsOneWidget);
    expect(
      find.text(CancellationPolicy.cancellationDeadlineMessage),
      findsOneWidget,
    );
    expect(
      find.textContaining('2 hours'),
      findsOneWidget,
    );
  });
}
