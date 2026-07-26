/// Server-aligned booking price math for Review & Confirm.
///
/// Backend (`formatSalonResponse`) conventions:
/// - [price] = payable unit price (`discounted_amount` when on offer, else `amount`)
/// - [originalPrice] = MRP only when discounted; otherwise null
///
/// List amount = Σ max(MRP, payable). Discount = list − payable.
/// Never skip a service when MRP is missing — fall back to payable price.
class BookingPriceCalculator {
  BookingPriceCalculator._();

  static const double defaultGstPercentage = 5.0;

  /// Parses ₹ strings / nums into a non-negative double.
  static double parseMoney(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble().clamp(0.0, double.infinity);
    if (value is String) {
      final parsed =
          double.tryParse(value.replaceAll(RegExp(r'[₹,\s]'), '').trim());
      return (parsed ?? 0.0).clamp(0.0, double.infinity);
    }
    return 0.0;
  }

  /// Payable unit price for one selected service map.
  static double sellingPriceOf(Map<String, dynamic> service) =>
      parseMoney(service['price']);

  /// Display / MRP unit price. Falls back to selling price when MRP is absent.
  static double listPriceOf(Map<String, dynamic> service) {
    final selling = sellingPriceOf(service);
    final list = parseMoney(service['originalPrice']);
    if (list <= 0) return selling;
    return list >= selling ? list : selling;
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

    for (final service in services) {
      final selling = sellingPriceOf(service);
      final list = listPriceOf(service);
      listAmount += list;
      payableSubtotal += selling;
      final lineDiscount = list - selling;
      if (lineDiscount > 0) serviceDiscount += lineDiscount;
    }

    final safeCoupon = couponDiscount.clamp(0.0, payableSubtotal);
    final taxable = (payableSubtotal - safeCoupon).clamp(0.0, double.infinity);
    final gst = (taxable * gstPercentage) / 100;
    final totalBeforeWallet = taxable + gst + platformFee;
    final finalTotal =
        (totalBeforeWallet - walletAmountUsed).clamp(0.0, double.infinity);

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
