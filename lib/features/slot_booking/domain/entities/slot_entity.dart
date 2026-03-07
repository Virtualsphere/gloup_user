/// Domain entity for time slot
class SlotEntity {
  final int salonId;
  final String time;
  final String status; // "available" or "booked"

  const SlotEntity({
    required this.salonId,
    required this.time,
    required this.status,
  });

  /// Check if slot is available
  bool get isAvailable => status.toLowerCase() == 'available';

  /// Check if slot is booked
  bool get isBooked => status.toLowerCase() == 'booked';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotEntity &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          status == other.status;

  @override
  int get hashCode => time.hashCode ^ status.hashCode;
}
