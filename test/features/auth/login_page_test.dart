import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/core/constants/app_strings.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/features/auth/presentation/pages/login_page.dart';

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

  Future<void> pumpLoginPage(WidgetTester tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));
    await tester.pumpWidget(
      buildTestMaterialApp(
        child: LoginPage(authBloc: authBloc),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapContinue(WidgetTester tester) async {
    final continueFinder = find.text('Continue');
    await tester.ensureVisible(continueFinder);
    await tester.tap(continueFinder);
    await tester.pump();
  }

  group('LoginPage', () {
    testWidgets('renders Figma elements properly', (tester) async {
      await pumpLoginPage(tester);

      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Booked today'), findsOneWidget);
      expect(find.text('12,480+'), findsOneWidget);
      expect(find.text('Partner salons'), findsOneWidget);
      expect(find.text('1,200+'), findsOneWidget);
      expect(find.text('Look good.\nBook in seconds.'), findsOneWidget);
      expect(find.text('Log in or sign up'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Continue as guest'), findsOneWidget);
    });

    testWidgets('shows required validation when phone is empty', (tester) async {
      await pumpLoginPage(tester);

      await tapContinue(tester);

      expect(find.text(AppStrings.validationRequired), findsOneWidget);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('shows phone validation when number is not 10 digits',
        (tester) async {
      await pumpLoginPage(tester);

      await tester.enterText(find.byType(TextFormField), '12345');
      await tapContinue(tester);

      expect(
        find.text('Please enter a valid 10-digit phone number'),
        findsOneWidget,
      );
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('dispatches SendOtpEvent for valid 10-digit phone', (tester) async {
      await pumpLoginPage(tester);

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tapContinue(tester);

      expect(find.text(AppStrings.validationRequired), findsNothing);
      verify(() => authBloc.add(const SendOtpEvent('9876543210'))).called(1);
    });
  });
}
