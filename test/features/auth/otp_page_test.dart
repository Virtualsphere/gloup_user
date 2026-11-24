import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinput/pinput.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/features/auth/presentation/pages/otp_page.dart';

import '../../helpers/widget_test_helpers.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() async {
    registerWidgetTestFallbacks();
    await initWidgetTestStorage();
  });

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthInitial());
    when(() => authBloc.stream).thenAnswer((_) => Stream.value(const AuthInitial()));
    when(() => authBloc.close()).thenAnswer((_) async {});
    when(() => authBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpOtpPage(WidgetTester tester, {String phone = '9876543221'}) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));
    await tester.pumpWidget(
      buildTestMaterialApp(
        child: OtpPage(
          phone: phone,
          authBloc: authBloc,
        ),
      ),
    );
    await tester.pump();
  }

  group('OtpPage Figma Design', () {
    testWidgets('renders all verification elements properly', (tester) async {
      await pumpOtpPage(tester);

      expect(find.text('Enter verification code'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Waiting to auto-read the code from SMS'), findsOneWidget);
      expect(find.text("Didn't get the code?"), findsOneWidget);
      expect(find.text('Prefer another way?'), findsOneWidget);
      expect(find.text('Get code on WhatsApp'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
      expect(find.byType(Pinput), findsOneWidget);
    });

    testWidgets('verify button is disabled initially with empty code', (tester) async {
      await pumpOtpPage(tester);

      final verifyBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(verifyBtn.onPressed, isNull);
    });

    testWidgets('entering 4 digits enables verify and dispatches VerifyOtpEvent',
        (tester) async {
      await pumpOtpPage(tester);

      await tester.enterText(find.byType(Pinput), '1234');
      await tester.pump();

      final verifyBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(verifyBtn.onPressed, isNotNull);

      verify(() => authBloc.add(const VerifyOtpEvent(
            phone: '9876543221',
            otp: '1234',
          ))).called(greaterThanOrEqualTo(1));
    });

    testWidgets('tapping WhatsApp option requests resend', (tester) async {
      await pumpOtpPage(tester);

      await tester.tap(find.text('Get code on WhatsApp'));
      await tester.pump(const Duration(seconds: 3));

      verify(() => authBloc.add(const SendOtpEvent('9876543221'))).called(1);
    });
  });
}
