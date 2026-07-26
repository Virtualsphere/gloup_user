import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/features/booking_confirmation/domain/utils/booking_price_calculator.dart';

void main() {
  group('BookingPriceCalculator', () {
    test('sums payable prices when originalPrice is null', () {
      final services = [
        {'id': 1, 'price': 199.0, 'originalPrice': null},
        {'id': 2, 'price': 699.0, 'originalPrice': null},
        {'id': 3, 'price': 199.0, 'originalPrice': null},
        {'id': 4, 'price': 59.0, 'originalPrice': null},
        {'id': 5, 'price': 59.0, 'originalPrice': null},
        {'id': 6, 'price': 49.0, 'originalPrice': null},
        {'id': 7, 'price': 99.0, 'originalPrice': null},
      ];

      final breakdown = BookingPriceCalculator.fromServices(services);

      expect(breakdown.listAmount, 1363.0);
      expect(breakdown.serviceDiscount, 0.0);
      expect(breakdown.payableSubtotal, 1363.0);
      expect(breakdown.gstAmount, closeTo(68.15, 0.01));
      expect(breakdown.finalTotal, closeTo(1431.15, 0.01));
    });

    test('uses MRP for amount and selling price for payable when discounted',
        () {
      final services = [
        {'id': 1, 'price': 29.0, 'originalPrice': 63.0},
        {'id': 2, 'price': 500.0, 'originalPrice': null},
      ];

      final breakdown = BookingPriceCalculator.fromServices(services);

      expect(breakdown.listAmount, 563.0);
      expect(breakdown.serviceDiscount, 34.0);
      expect(breakdown.payableSubtotal, 529.0);
      expect(breakdown.finalTotal, closeTo(529.0 * 1.05, 0.01));
    });

    test('does not treat originalPrice 0 as MRP', () {
      final breakdown = BookingPriceCalculator.fromServices([
        {'id': 1, 'price': 199.0, 'originalPrice': 0.0},
      ]);

      expect(breakdown.listAmount, 199.0);
      expect(breakdown.serviceDiscount, 0.0);
      expect(breakdown.payableSubtotal, 199.0);
    });

    test('applies coupon before GST and floors at zero', () {
      final breakdown = BookingPriceCalculator.fromServices(
        [
          {'id': 1, 'price': 100.0},
          {'id': 2, 'price': 100.0},
        ],
        couponDiscount: 50,
        walletAmountUsed: 10,
      );

      expect(breakdown.taxableAmount, 150.0);
      expect(breakdown.gstAmount, closeTo(7.5, 0.01));
      expect(breakdown.finalTotal, closeTo(147.5, 0.01));
    });

    test('handles int prices from JSON/route extras (device variance)', () {
      final breakdown = BookingPriceCalculator.fromServices([
        {'id': 1, 'price': 1699, 'originalPrice': null},
      ]);

      expect(breakdown.payableSubtotal, 1699.0);
      expect(breakdown.finalTotal, closeTo(1699.0 * 1.05, 0.01));
      expect(breakdown.finalTotal.toStringAsFixed(0), isNot('0'));
    });

    test('falls back to amount key when price is missing', () {
      final breakdown = BookingPriceCalculator.fromServices([
        {'id': 1, 'amount': 1699},
      ]);

      expect(breakdown.payableSubtotal, 1699.0);
      expect(breakdown.listAmount, 1699.0);
    });

    test('falls back to originalPrice when payable price is zero', () {
      final breakdown = BookingPriceCalculator.fromServices([
        {'id': 1, 'price': 0, 'originalPrice': 1699},
      ]);

      expect(breakdown.payableSubtotal, 1699.0);
      expect(breakdown.finalTotal, greaterThan(0));
    });

    test('parses currency strings', () {
      final breakdown = BookingPriceCalculator.fromServices([
        {'id': 1, 'price': '₹1,699'},
      ]);

      expect(breakdown.payableSubtotal, 1699.0);
    });

    test('normalizeServices tolerates loosely typed maps', () {
      final services = BookingPriceCalculator.normalizeServices([
        <dynamic, dynamic>{'id': 1, 'price': 1699, 'name': 'Cut'},
        null,
        'bad',
      ]);

      expect(services.length, 1);
      expect(services.first['price'], 1699.0);
      expect(
        BookingPriceCalculator.fromServices(services).payableSubtotal,
        1699.0,
      );
    });
  });
}
