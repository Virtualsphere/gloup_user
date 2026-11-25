import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/home/domain/entities/home_gender.dart';
import 'package:tressy/features/home/presentation/widgets/home_header.dart';

Widget _harness({
  String? wallet,
  HomeGender gender = const HomeGender(),
  ValueChanged<HomeGender>? onGender,
  VoidCallback? onSearch,
  VoidCallback? onLocation,
  bool loading = false,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: HomeHeader(
            title: 'Anna Nagar',
            subtitle: 'Chennai',
            isLoadingLocation: loading,
            onLocationTap: onLocation ?? () {},
            walletLabel: wallet,
            avatar: const CircleAvatar(radius: 20),
            onSearchTap: onSearch ?? () {},
            gender: gender,
            onGenderChanged: onGender ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('HomeGender', () {
    test('apiValue follows tab and unisex switch', () {
      expect(const HomeGender().apiValue, 'male');
      expect(
        const HomeGender(tab: HomeGenderTab.female).apiValue,
        'female',
      );
      expect(
        const HomeGender(includeUnisex: false).apiValue,
        'male_only',
      );
      expect(
        const HomeGender(tab: HomeGenderTab.female, includeUnisex: false)
            .apiValue,
        'female_only',
      );
    });
  });

  group('HomeHeader.formatWallet', () {
    test('formats whole and fractional amounts', () {
      expect(HomeHeader.formatWallet('250.00'), '₹250');
      expect(HomeHeader.formatWallet('99.5'), '₹99.50');
      expect(HomeHeader.formatWallet('0'), '₹0');
    });

    test('returns null for missing or invalid input', () {
      expect(HomeHeader.formatWallet(null), isNull);
      expect(HomeHeader.formatWallet(''), isNull);
      expect(HomeHeader.formatWallet('abc'), isNull);
    });
  });

  group('HomeHeader widget', () {
    testWidgets('shows location, search hint and gender tabs', (tester) async {
      await tester.pumpWidget(_harness());
      expect(find.text('Anna Nagar'), findsOneWidget);
      expect(find.text('Chennai'), findsOneWidget);
      expect(find.text('Search "hair spa"'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
    });

    testWidgets('wallet chip is hidden without a label', (tester) async {
      await tester.pumpWidget(_harness());
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsNothing);

      await tester.pumpWidget(_harness(wallet: '₹250'));
      expect(find.text('₹250'), findsOneWidget);
    });

    testWidgets('tapping Female reports the new tab', (tester) async {
      HomeGender? changed;
      await tester.pumpWidget(_harness(onGender: (g) => changed = g));
      await tester.tap(find.text('Female'));
      expect(changed, const HomeGender(tab: HomeGenderTab.female));
    });

    testWidgets('toggling the UNI SEX switch keeps the tab', (tester) async {
      HomeGender? changed;
      await tester.pumpWidget(_harness(
        gender: const HomeGender(tab: HomeGenderTab.female),
        onGender: (g) => changed = g,
      ));
      await tester.tap(find.byType(Switch));
      expect(
        changed,
        const HomeGender(tab: HomeGenderTab.female, includeUnisex: false),
      );
    });

    testWidgets('search and location taps are forwarded', (tester) async {
      var search = 0;
      var location = 0;
      await tester.pumpWidget(
          _harness(onSearch: () => search++, onLocation: () => location++));
      await tester.tap(find.text('Search "hair spa"'));
      await tester.tap(find.text('Anna Nagar'));
      expect(search, 1);
      expect(location, 1);
    });

    testWidgets('shows a loading label while locating', (tester) async {
      await tester.pumpWidget(_harness(loading: true));
      expect(find.text('Getting location...'), findsOneWidget);
      expect(find.text('Anna Nagar'), findsNothing);
    });
  });
}
