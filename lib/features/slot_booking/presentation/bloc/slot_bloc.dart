import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/slot_booking/domain/usecases/get_slot_status_usecase.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_event.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_state.dart';

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  final GetSlotStatusUseCase getSlotStatusUseCase;
  final GetStoreHolidaysUseCase getStoreHolidaysUseCase;

  SlotBloc({
    required this.getSlotStatusUseCase,
    required this.getStoreHolidaysUseCase,
  }) : super(SlotState.initial()) {
    on<LoadSlotsEvent>(_onLoadSlots);
    on<LoadHolidaysEvent>(_onLoadHolidays);
    on<SelectSlotEvent>(_onSelectSlot);
    on<ClearSelectedSlotEvent>(_onClearSelectedSlot);
  }

  Future<void> _onLoadSlots(
    LoadSlotsEvent event,
    Emitter<SlotState> emit,
  ) async {
    emit(state.copyWithLoading());

    final result = await getSlotStatusUseCase(
      salonId: event.salonId,
      date: event.date,
    );

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (day) => emit(state.copyWithSuccess(
        slots: day.slots,
        date: event.date,
        salonId: event.salonId,
        isHoliday: day.isHoliday,
        holidayReason: day.holidayReason,
        holidayType: day.holidayType,
        weekdayName: day.weekdayName,
      )),
    );
  }

  Future<void> _onLoadHolidays(
    LoadHolidaysEvent event,
    Emitter<SlotState> emit,
  ) async {
    final result = await getStoreHolidaysUseCase(
      salonId: event.salonId,
      from: event.from,
      to: event.to,
    );
    result.fold(
      (_) {},
      (dates) => emit(state.copyWithHolidays(dates.toSet())),
    );
  }

  void _onSelectSlot(
    SelectSlotEvent event,
    Emitter<SlotState> emit,
  ) {
    emit(state.copyWithSelectedSlot(event.time, event.slotId));
  }

  void _onClearSelectedSlot(
    ClearSelectedSlotEvent event,
    Emitter<SlotState> emit,
  ) {
    emit(state.copyWithSelectedSlot(null, null));
  }
}
