import 'package:equatable/equatable.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';

class SlotState extends Equatable {
  final bool isLoading;
  final List<SlotEntity> slots;
  final String? selectedSlotTime;
  final int? selectedSlotId;
  final String? errorMessage;
  final String? currentDate;
  final int? currentSalonId;
  final bool isHoliday;
  final String? holidayReason;
  final String? holidayType;
  final String? weekdayName;
  final Set<String> holidayDates;

  const SlotState({
    this.isLoading = false,
    this.slots = const [],
    this.selectedSlotTime,
    this.selectedSlotId,
    this.errorMessage,
    this.currentDate,
    this.currentSalonId,
    this.isHoliday = false,
    this.holidayReason,
    this.holidayType,
    this.weekdayName,
    this.holidayDates = const {},
  });

  factory SlotState.initial() => const SlotState();

  SlotState copyWithLoading() {
    return SlotState(
      isLoading: true,
      slots: slots,
      selectedSlotTime: selectedSlotTime,
      selectedSlotId: selectedSlotId,
      currentDate: currentDate,
      currentSalonId: currentSalonId,
      isHoliday: isHoliday,
      holidayReason: holidayReason,
      holidayType: holidayType,
      weekdayName: weekdayName,
      holidayDates: holidayDates,
    );
  }

  SlotState copyWithSuccess({
    required List<SlotEntity> slots,
    required String date,
    required int salonId,
    bool isHoliday = false,
    String? holidayReason,
    String? holidayType,
    String? weekdayName,
  }) {
    return SlotState(
      isLoading: false,
      slots: slots,
      selectedSlotTime: selectedSlotTime,
      selectedSlotId: selectedSlotId,
      currentDate: date,
      currentSalonId: salonId,
      isHoliday: isHoliday,
      holidayReason: holidayReason,
      holidayType: holidayType,
      weekdayName: weekdayName,
      holidayDates: holidayDates,
    );
  }

  SlotState copyWithHolidays(Set<String> dates) {
    return SlotState(
      isLoading: isLoading,
      slots: slots,
      selectedSlotTime: selectedSlotTime,
      selectedSlotId: selectedSlotId,
      errorMessage: errorMessage,
      currentDate: currentDate,
      currentSalonId: currentSalonId,
      isHoliday: isHoliday,
      holidayReason: holidayReason,
      holidayType: holidayType,
      weekdayName: weekdayName,
      holidayDates: dates,
    );
  }

  SlotState copyWithError(String message) {
    return SlotState(
      isLoading: false,
      slots: slots,
      selectedSlotTime: selectedSlotTime,
      selectedSlotId: selectedSlotId,
      errorMessage: message,
      currentDate: currentDate,
      currentSalonId: currentSalonId,
      isHoliday: isHoliday,
      holidayReason: holidayReason,
      holidayType: holidayType,
      weekdayName: weekdayName,
      holidayDates: holidayDates,
    );
  }

  SlotState copyWithSelectedSlot(String? time, int? slotId) {
    return SlotState(
      isLoading: isLoading,
      slots: slots,
      selectedSlotTime: time,
      selectedSlotId: slotId,
      errorMessage: errorMessage,
      currentDate: currentDate,
      currentSalonId: currentSalonId,
      isHoliday: isHoliday,
      holidayReason: holidayReason,
      holidayType: holidayType,
      weekdayName: weekdayName,
      holidayDates: holidayDates,
    );
  }

  List<SlotEntity> get availableSlots =>
      slots.where((slot) => slot.isAvailable).toList();

  List<SlotEntity> get bookedSlots =>
      slots.where((slot) => slot.isBooked).toList();

  bool get hasSelectedSlot => selectedSlotTime != null;

  @override
  List<Object?> get props => [
        isLoading,
        slots,
        selectedSlotTime,
        selectedSlotId,
        errorMessage,
        currentDate,
        currentSalonId,
        isHoliday,
        holidayReason,
        holidayType,
        weekdayName,
        holidayDates,
      ];
}
