class OrderEntity {
  final int orderId;
  final String razorpayOrderId;
  final double amount;
  final String currency;
  final String bookingDate;
  final String status;

  const OrderEntity({
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.bookingDate,
    required this.status,
  });
}
