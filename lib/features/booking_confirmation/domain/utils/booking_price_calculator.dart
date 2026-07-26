/// Server-aligned booking price math for Review & Confirm.
///
/// Backend (`formatSalonResponse`) conventions:
/// - [price] = payable unit price (`discounted_amount` when on offer, else `amount`)
/// - [originalPrice] = MRP only when discounted; otherwise null
///
/// Some devices / route extras / JSON round-trips coerce whole-rupee amounts to
/// [int] or keep alternate keys (`amount`). Always parse defensively.
class BookingPriceCalculator {
  BookingPriceCalculator._();

  static const double defaultGstPercentage = 5.0;

  /// Parses ₹ strings / ints / doubles into a non-negative [double].
  static double parseMoney(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) {
      final parsed = value.toDouble();
      if (parsed.isNaN || parsed.isInfinite) return 0.0;
      return parsed < 0 ? 0.0 : parsed;
    }
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[₹,\s]'), '').trim();
      if (cleaned.isEmpty || cleaned.toLowerCase() == 'null') return 0.0;
      final parsed = double.tryParse(cleaned) ?? 0.0;
      if (parsed.isNaN || parsed.isInfinite || parsed < 0) return 0.0;
      return parsed;
    }
    return 0.0;
  }

  /// Normalize a loosely-typed service map from navigation extras / JSON.
  static Map<String, dynamic> normalizeService(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    final map = Map<String, dynamic>.from(raw);
    final selling = sellingPriceOf(map);
    final list = listPriceOf(map);
    map['price'] = selling;
    if (list > selling) {
      map['originalPrice'] = list;
    } else if (parseMoney(map['originalPrice']) <= 0) {
      map['originalPrice'] = null;
    }
    return map;
  }

  static List<Map<String, dynamic>> normalizeServices(Iterable<dynamic>? raw) {
    if (raw == null) return const [];
    return raw.map(normalizeService).where((s) => s.isNotEmpty).toList();
  }

  /// Payable unit price for one selected service map.
  static double sellingPriceOf(Map<String, dynamic> service) {
    final candidates = <dynamic>[
      service['price'],
      service['amount'],
      service['discounted_amount'],
      service['discountedAmount'],
      service['sellingPrice'],
    ];
    for (final candidate in candidates) {
      final value = parseMoney(candidate);
      if (value > 0) return value;
    }
    // Malformed promo payloads sometimes leave payable at 0 but MRP set.
    final original = parseMoney(service['originalPrice']);
    return original > 0 ? original : 0.0;
  }

  /// Display / MRP unit price. Falls back to selling price when MRP is absent.
  static double listPriceOf(Map<String, dynamic> service) {
    final selling = sellingPriceOf(service);
    final listCandidates = <dynamic>[
      service['originalPrice'],
      service['mrp'],
      service['amount'],
    ];
    for (final candidate in listCandidates) {
      final list = parseMoney(candidate);
      if (list > 0) {
        return list >= selling ? list : selling;
      }
    }
    return selling;
  }

  static BookingPriceBreakdown fromServices(
    Iterable<Map<String, dynamic>> services, {
    double couponDiscount = 0.0,
    double gstPercentage = defaultGstPercentage,
    double platformFee = 0.0,
    double walletAmountUsed = 0.0,
  }) {
    var listAmount = 0.0;
    var serviceDiscount = 0.0;
    var payableSubtotal = 0.0;

    for (final raw in services) {
      final service = normalizeService(raw);
      final selling = sellingPriceOf(service);
      final list = listPriceOf(service);
      listAmount += list;
      payableSubtotal += selling;
      final lineDiscount = list - selling;
      if (lineDiscount > 0) serviceDiscount += lineDiscount;
    }

    final safeCoupon =
        couponDiscount.clamp(0.0, payableSubtotal).toDouble();
    final taxable =
        (payableSubtotal - safeCoupon).clamp(0.0, double.infinity).toDouble();
    final gst = (taxable * gstPercentage) / 100;
    final totalBeforeWallet = taxable + gst + platformFee;
    final finalTotal = (totalBeforeWallet - walletAmountUsed)
        .clamp(0.0, double.infinity)
        .toDouble();

    return BookingPriceBreakdown(
      listAmount: listAmount,
      serviceDiscount: serviceDiscount,
      payableSubtotal: payableSubtotal,
      couponDiscount: safeCoupon,
      taxableAmount: taxable,
      gstPercentage: gstPercentage,
      gstAmount: gst,
      platformFee: platformFee,
      walletAmountUsed: walletAmountUsed,
      finalTotal: finalTotal,
    );
  }
}

class BookingPriceBreakdown {
  final double listAmount;
  final double serviceDiscount;
  final double payableSubtotal;
  final double couponDiscount;
  final double taxableAmount;
  final double gstPercentage;
  final double gstAmount;
  final double platformFee;
  final double walletAmountUsed;
  final double finalTotal;

  const BookingPriceBreakdown({
    required this.listAmount,
    required this.serviceDiscount,
    required this.payableSubtotal,
    required this.couponDiscount,
    required this.taxableAmount,
    required this.gstPercentage,
    required this.gstAmount,
    required this.platformFee,
    required this.walletAmountUsed,
    required this.finalTotal,
  });
}
