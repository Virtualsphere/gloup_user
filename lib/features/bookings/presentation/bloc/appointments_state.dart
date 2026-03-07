import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';

class AppointmentsState {
  final bool isLoading;
  final List<AppointmentEntity> upcoming;
  final List<AppointmentEntity> past;
  final String? errorMessage;

  const AppointmentsState({
    this.isLoading = false,
    this.upcoming = const [],
    this.past = const [],
    this.errorMessage,
  });

  AppointmentsState copyWith({
    bool? isLoading,
    List<AppointmentEntity>? upcoming,
    List<AppointmentEntity>? past,
    String? errorMessage,
  }) {
    return AppointmentsState(
      isLoading: isLoading ?? this.isLoading,
      upcoming: upcoming ?? this.upcoming,
      past: past ?? this.past,
      errorMessage: errorMessage,
    );
  }
}
