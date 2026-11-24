import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/auth/presentation/pages/about_you_page.dart';

import '../../helpers/widget_test_helpers.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient dioClient;

  setUpAll(() async {
    registerWidgetTestFallbacks();
    await initWidgetTestStorage();
  });

  setUp(() {
    dioClient = MockDioClient();
    when(() => dioClient.patch(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/user/app/v2/profile'),
        statusCode: 200,
        data: {'success': true, 'message': 'Profile updated successfully'},
      ),
    );
  });

  Future<void> pumpAboutYouPage(WidgetTester tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));
    await tester.pumpWidget(
      buildTestMaterialApp(
        child: AboutYouPage(
          dioClient: dioClient,
        ),
      ),
    );
    await tester.pump();
  }

  group('AboutYouPage Figma Design', () {
    testWidgets('renders all onboarding elements properly', (tester) async {
      await pumpAboutYouPage(tester);

      expect(find.text('STEP 1 OF 2'), findsOneWidget);
      expect(find.text('Tell us about you'), findsOneWidget);
      expect(
        find.text('So we can show salons and services made for you'),
        findsOneWidget,
      );
      expect(find.text('Your name'), findsOneWidget);
      expect(find.text("I'm looking for services for"), findsOneWidget);
      expect(find.text('Men'), findsOneWidget);
      expect(find.text('Women'), findsOneWidget);
      expect(
        find.text('You can switch anytime from Home or your profile.'),
        findsOneWidget,
      );
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('continue button is disabled initially', (tester) async {
      await pumpAboutYouPage(tester);

      final continueBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(continueBtn.onPressed, isNull);
    });

    testWidgets('filling name and selecting gender enables continue button',
        (tester) async {
      await pumpAboutYouPage(tester);

      // Enter name
      await tester.enterText(find.byType(TextField), 'Uday Sivagurunathan');
      await tester.pump();

      // Still disabled without gender
      var continueBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(continueBtn.onPressed, isNull);

      // Select Men
      await tester.tap(find.text('Men'));
      await tester.pump();

      // Now enabled
      continueBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(continueBtn.onPressed, isNotNull);

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(seconds: 3));

      // Verify LocalStorage was updated
      expect(LocalStorageService.getString(Keys.userName), 'Uday Sivagurunathan');
      expect(LocalStorageService.getString('selected_gender'), 'male');
    });
  });
}
