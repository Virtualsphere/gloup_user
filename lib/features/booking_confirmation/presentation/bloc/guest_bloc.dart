import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/get_all_guests_usecase.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/add_guest_usecase.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/update_guest_usecase.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_event.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GetAllGuestsUseCase getAllGuestsUseCase;
  final AddGuestUseCase addGuestUseCase;
  final UpdateGuestUseCase updateGuestUseCase;

  GuestBloc({
    required this.getAllGuestsUseCase,
    required this.addGuestUseCase,
    required this.updateGuestUseCase,
  }) : super(GuestState.initial()) {
    on<LoadGuestsEvent>(_onLoadGuests);
    on<SelectGuestEvent>(_onSelectGuest);
    on<AddGuestEvent>(_onAddGuest);
    on<UpdateGuestEvent>(_onUpdateGuest);
  }

  Future<void> _onLoadGuests(
    LoadGuestsEvent event,
    Emitter<GuestState> emit,
  ) async {
    emit(state.copyWithLoading());

    final result = await getAllGuestsUseCase();

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (guests) => emit(state.copyWithSuccess(guests)),
    );
  }

  void _onSelectGuest(
    SelectGuestEvent event,
    Emitter<GuestState> emit,
  ) {
    emit(state.copyWithSelectedGuest(event.index));
  }

  Future<void> _onAddGuest(
    AddGuestEvent event,
    Emitter<GuestState> emit,
  ) async {
    emit(state.copyWithAdding());

    final result = await addGuestUseCase(
      name: event.name,
      gender: event.gender,
      age: event.age,
      phone: event.phone,
    );

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (_) {
        // After successful add, reload the guest list
        emit(state.copyWithAddSuccess('Guest added successfully'));
        add(const LoadGuestsEvent());
      },
    );
  }

  Future<void> _onUpdateGuest(
    UpdateGuestEvent event,
    Emitter<GuestState> emit,
  ) async {
    emit(state.copyWithUpdating());

    final result = await updateGuestUseCase(
      guestId: event.guestId,
      name: event.name,
      gender: event.gender,
      age: event.age,
      phone: event.phone,
    );

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (_) {
        // After successful update, reload the guest list
        emit(state.copyWithUpdateSuccess('Guest updated successfully'));
        add(const LoadGuestsEvent());
      },
    );
  }
}
