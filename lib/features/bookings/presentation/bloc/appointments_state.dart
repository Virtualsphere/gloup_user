import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';

class AppointmentsState {
  final bool isLoading;
  final List<AppointmentEntity> upcoming;
  final List<AppointmentEntity> completed;
  final List<AppointmentEntity> cancelled;
  final String? errorMessage;

  const AppointmentsState({
    this.isLoading = false,
    this.upcoming = const [],
    this.completed = const [],
    this.cancelled = const [],
    this.errorMessage,
  });

  AppointmentsState copyWith({
    bool? isLoading,
    List<AppointmentEntity>? upcoming,
    List<AppointmentEntity>? completed,
    List<AppointmentEntity>? cancelled,
    String? errorMessage,
  }) {
    return AppointmentsState(
      isLoading: isLoading ?? this.isLoading,
      upcoming: upcoming ?? this.upcoming,
      completed: completed ?? this.completed,
      cancelled: cancelled ?? this.cancelled,
      errorMessage: errorMessage,
    );
  }
}
