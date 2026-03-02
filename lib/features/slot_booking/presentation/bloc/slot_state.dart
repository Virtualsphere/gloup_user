import 'package:equatable/equatable.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';

class SlotState extends Equatable {
  final bool isLoading;
  final List<SlotEntity> slots;
  final String? selectedSlotTime;
  final String? errorMessage;
  final String? currentDate;
  final int? currentSalonId;

  const SlotState({
    this.isLoading = false,
    this.slots = const [],
    this.selectedSlotTime,
    this.errorMessage,
    this.currentDate,
    this.currentSalonId,
  });

  /// Initial state
  factory SlotState.initial() {
    return const SlotState();
  }

  /// Loading state
  SlotState copyWithLoading() {
    return SlotState(
      isLoading: true,
      slots: slots,
      selectedSlotTime: selectedSlotTime,
      currentDate: currentDate,
      currentSalonId: currentSalonId,
    );
  }

  /// Success state
  SlotState copyWithSuccess({
    required List<SlotEntity> slots,
    required String date,
    required int salonId,
  }) {
    return SlotState(
      isLoading: false,
      slots: slots,
      selectedSlotTime: selectedSlotTime,
      currentDate: date,
      currentSalonId: salonId,
    );
  }

  /// Error state
  SlotState copyWithError(String message) {
    return SlotState(
      isLoading: false,
      slots: slots,
      selectedSlotTime: selectedSlotTime,
      errorMessage: message,
      currentDate: currentDate,
      currentSalonId: currentSalonId,
    );
  }

  /// Update selected slot
  SlotState copyWithSelectedSlot(String? time) {
    return SlotState(
      isLoading: isLoading,
      slots: slots,
      selectedSlotTime: time,
      errorMessage: errorMessage,
      currentDate: currentDate,
      currentSalonId: currentSalonId,
    );
  }

  /// Get available slots only
  List<SlotEntity> get availableSlots =>
      slots.where((slot) => slot.isAvailable).toList();

  /// Get booked slots only
  List<SlotEntity> get bookedSlots =>
      slots.where((slot) => slot.isBooked).toList();

  /// Check if a slot is selected
  bool get hasSelectedSlot => selectedSlotTime != null;

  @override
  List<Object?> get props => [
        isLoading,
        slots,
        selectedSlotTime,
        errorMessage,
        currentDate,
        currentSalonId,
      ];
}
