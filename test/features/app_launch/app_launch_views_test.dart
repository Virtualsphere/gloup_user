import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_first_open_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_chair_loader_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_slow_network_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_failure_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_home_skeleton_view.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppLaunchFirstOpenView displays brand and triggers onProceed', (tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));
    bool proceeded = false;

    await tester.pumpWidget(
      buildTestMaterialApp(
        child: AppLaunchFirstOpenView(
          onProceed: () {
            proceeded = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Book salons near you. Instantly.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Best salon deals'), findsOneWidget);
    expect(find.text('Verified partner salons'), findsOneWidget);
    expect(find.text('Instant slot booking'), findsOneWidget);

    final getStartedFinder = find.text('Get Started');
    await tester.tap(getStartedFinder, warnIfMissed: false);
    await tester.pump();

    expect(proceeded, isTrue);
  });

  testWidgets('AppLaunchChairLoaderView displays animated loader and locality', (tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));

    await tester.pumpWidget(
      buildTestMaterialApp(
        child: const AppLaunchChairLoaderView(locality: 'Indiranagar'),
      ),
    );
    await tester.pump();

    expect(find.text('Finding salons near Indiranagar...'), findsOneWidget);
    expect(find.text('NOW LIVE IN'), findsOneWidget);
  });

  testWidgets('AppLaunchSlowNetworkView displays actions and triggers callbacks', (tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));
    bool browseTapped = false;
    bool waitingTapped = false;

    await tester.pumpWidget(
      buildTestMaterialApp(
        child: AppLaunchSlowNetworkView(
          onBrowseSavedSalons: () => browseTapped = true,
          onKeepWaiting: () => waitingTapped = true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Taking longer than usual'), findsOneWidget);
    expect(find.text('Browse saved salons'), findsOneWidget);
    expect(find.text('Keep waiting'), findsOneWidget);

    await tester.tap(find.text('Browse saved salons'));
    await tester.pump();
    expect(browseTapped, isTrue);

    await tester.tap(find.text('Keep waiting'));
    await tester.pump();
    expect(waitingTapped, isTrue);
  });

  testWidgets('AppLaunchFailureView displays error details and triggers callbacks', (tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));
    bool retryTapped = false;
    bool settingsTapped = false;

    await tester.pumpWidget(
      buildTestMaterialApp(
        child: AppLaunchFailureView(
          errorMessage: 'Unable to reach server.',
          errorCode: 'Error GL-503 · server didn\'t respond',
          onTryAgain: () => retryTapped = true,
          onOpenNetworkSettings: () => settingsTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('We couldn\'t load GloUp'), findsOneWidget);
    expect(find.text('Unable to reach server.'), findsOneWidget);
    expect(find.text('Error GL-503 · server didn\'t respond'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Open network settings'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryTapped, isTrue);

    await tester.tap(find.text('Open network settings'));
    await tester.pump();
    expect(settingsTapped, isTrue);
  });

  testWidgets('AppLaunchHomeSkeletonView renders shimmer placeholders', (tester) async {
    setWidgetTestScreenSize(tester, size: const Size(400, 950));

    await tester.pumpWidget(
      buildTestMaterialApp(
        child: const AppLaunchHomeSkeletonView(locality: 'Koramangala'),
      ),
    );
    await tester.pump();

    expect(find.text('Finding salons near Koramangala...'), findsOneWidget);
  });
}
