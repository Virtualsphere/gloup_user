import 'package:equatable/equatable.dart';

abstract class SlotEvent extends Equatable {
  const SlotEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load slots for a specific salon and date
class LoadSlotsEvent extends SlotEvent {
  final int salonId;
  final String date; // Format: YYYY-MM-DD

  const LoadSlotsEvent({
    required this.salonId,
    required this.date,
  });

  @override
  List<Object?> get props => [salonId, date];
}

/// Event to select a slot
class SelectSlotEvent extends SlotEvent {
  final String time;
  final int slotId;

  const SelectSlotEvent(this.time, this.slotId);

  @override
  List<Object?> get props => [time, slotId];
}

/// Event to clear selected slot
class ClearSelectedSlotEvent extends SlotEvent {
  const ClearSelectedSlotEvent();
}
