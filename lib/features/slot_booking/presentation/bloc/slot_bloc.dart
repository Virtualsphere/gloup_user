import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/slot_booking/domain/usecases/get_slot_status_usecase.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_event.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_state.dart';

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  final GetSlotStatusUseCase getSlotStatusUseCase;

  SlotBloc({
    required this.getSlotStatusUseCase,
  }) : super(SlotState.initial()) {
    on<LoadSlotsEvent>(_onLoadSlots);
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
      (slots) => emit(state.copyWithSuccess(
        slots: slots,
        date: event.date,
        salonId: event.salonId,
      )),
    );
  }

  void _onSelectSlot(
    SelectSlotEvent event,
    Emitter<SlotState> emit,
  ) {
    emit(state.copyWithSelectedSlot(event.time));
  }

  void _onClearSelectedSlot(
    ClearSelectedSlotEvent event,
    Emitter<SlotState> emit,
  ) {
    emit(state.copyWithSelectedSlot(null));
  }
}
