import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/bookings/domain/usecases/get_all_appointments_usecase.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_event.dart';
import 'package:tressy/features/bookings/presentation/bloc/appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final GetAllAppointmentsUseCase getAllAppointmentsUseCase;

  AppointmentsBloc({required this.getAllAppointmentsUseCase})
      : super(const AppointmentsState()) {
    on<LoadAppointmentsEvent>(_onLoadAppointments);
  }

  Future<void> _onLoadAppointments(
    LoadAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getAllAppointmentsUseCase();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (data) => emit(state.copyWith(
        isLoading: false,
        upcoming: data['upcoming'] ?? [],
        past: data['past'] ?? [],
      )),
    );
  }
}
