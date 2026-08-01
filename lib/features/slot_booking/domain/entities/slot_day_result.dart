import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';

/// Slot availability for a single day, including store holiday flag.
class SlotDayResult {
  final bool isHoliday;
  final String? holidayReason;
  final String? holidayType; // one_off | weekly
  final String? weekdayName;
  final List<SlotEntity> slots;

  const SlotDayResult({
    required this.isHoliday,
    this.holidayReason,
    this.holidayType,
    this.weekdayName,
    required this.slots,
  });
}
