import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/home/domain/entities/welcome_offer.dart';
import 'package:tressy/features/home/presentation/widgets/welcome_offer_dialog.dart';

final _now = DateTime.utc(2026, 1, 1, 12);

WelcomeOffer _offer({Duration? left, String? description}) => WelcomeOffer(
      couponId: 9,
      code: 'GLOWNEW',
      title: 'Flat 50% off your first booking',
      description: description,
      validUntil: left == null ? null : _now.add(left),
    );

void main() {
  group('WelcomeOffer.tryParse', () {
    test('parses the API payload', () {
      final o = WelcomeOffer.tryParse({
        'couponId': 9,
        'code': 'GLOWNEW',
        'title': 'Flat 50% off your first booking',
        'description': 'Up to ₹100 off',
        'validUntil': '2026-01-03T10:00:00.000Z',
      })!;
      expect(o.code, 'GLOWNEW');
      expect(o.description, 'Up to ₹100 off');
      expect(o.validUntil, DateTime.utc(2026, 1, 3, 10));
    });

    test('rejects missing offer, code or id', () {
      expect(WelcomeOffer.tryParse(null), isNull);
      expect(WelcomeOffer.tryParse({'couponId': 1, 'code': ' '}), isNull);
      expect(WelcomeOffer.tryParse({'code': 'X'}), isNull);
    });

    test('blank title and description get defaults', () {
      final o = WelcomeOffer.tryParse(
          {'couponId': 1, 'code': 'X', 'title': '', 'description': ' '})!;
      expect(o.title, 'Welcome gift');
      expect(o.description, isNull);
      expect(o.validUntil, isNull);
    });
  });

  group('timing', () {
    test('countdown only under 6 hours and not when expired', () {
      expect(
          _offer(left: const Duration(hours: 5)).showCountdown(_now), isTrue);
      expect(
          _offer(left: const Duration(hours: 6)).showCountdown(_now), isFalse);
      expect(
          _offer(left: const Duration(hours: 40)).showCountdown(_now), isFalse);
      expect(_offer(left: Duration.zero).showCountdown(_now), isFalse);
      expect(_offer().showCountdown(_now), isFalse);
    });

    test('isExpired', () {
      expect(_offer(left: const Duration(minutes: -1)).isExpired(_now), isTrue);
      expect(_offer(left: const Duration(minutes: 1)).isExpired(_now), isFalse);
      expect(_offer().isExpired(_now), isFalse);
    });

    test('formatCountdown', () {
      expect(
          WelcomeOffer.formatCountdown(const Duration(hours: 5, minutes: 12)),
          '5h 12m left');
      expect(WelcomeOffer.formatCountdown(const Duration(minutes: 42)),
          '42m left');
      expect(WelcomeOffer.formatCountdown(const Duration(seconds: 20)),
          'Less than a minute left');
    });

    test('shownKey changes with the offer window', () {
      expect(_offer(left: const Duration(hours: 1)).shownKey,
          isNot(_offer(left: const Duration(hours: 2)).shownKey));
    });
  });

  group('WelcomeOfferDialog', () {
    Future<void> open(
      WidgetTester tester,
      WelcomeOffer offer, {
      VoidCallback? onBook,
      VoidCallback? onTerms,
    }) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => WelcomeOfferDialog(
                    offer: offer,
                    onBookSalon: onBook ?? () {},
                    onTerms: onTerms ?? () {},
                    now: () => _now,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows content and a countdown near expiry', (tester) async {
      await open(
        tester,
        _offer(
            left: const Duration(hours: 2, minutes: 5),
            description: 'Up to ₹100'),
      );
      expect(find.text('WELCOME GIFT'), findsOneWidget);
      expect(find.text('Flat 50% off your first booking'), findsOneWidget);
      expect(find.text('Up to ₹100'), findsOneWidget);
      expect(find.text('GLOWNEW'), findsOneWidget);
      expect(find.text('2h 5m left'), findsOneWidget);

      // Unmount so the countdown ticker is cancelled before the test ends.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('no countdown when far from expiry', (tester) async {
      await open(tester, _offer(left: const Duration(hours: 40)));
      expect(find.byKey(const Key('welcome_countdown')), findsNothing);
    });

    testWidgets('Copy puts the code on the clipboard', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await open(tester, _offer());
      await tester.tap(find.byKey(const Key('welcome_copy')));
      await tester.pump();
      expect(copied, 'GLOWNEW');

      // Let the confirmation toast's timer finish.
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('Book a salon closes the dialog and calls back',
        (tester) async {
      var booked = 0;
      await open(tester, _offer(), onBook: () => booked++);
      await tester.tap(find.byKey(const Key('welcome_book')));
      await tester.pumpAndSettle();
      expect(booked, 1);
      expect(find.byKey(const Key('welcome_book')), findsNothing);
    });

    testWidgets('close and T&C', (tester) async {
      var terms = 0;
      await open(tester, _offer(), onTerms: () => terms++);
      await tester.tap(find.byKey(const Key('welcome_terms')));
      expect(terms, 1);
      await tester.tap(find.byKey(const Key('welcome_close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('welcome_close')), findsNothing);
    });
  });
}
