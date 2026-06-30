/// Single source of truth for customer booking cancellation timing.
class CancellationPolicy {
  CancellationPolicy._();

  static const int hoursBeforeAppointment = 2;

  static String _hoursLabel(int hours) =>
      '$hours ${hours == 1 ? 'hour' : 'hours'}';

  static String get hoursLabel => _hoursLabel(hoursBeforeAppointment);

  static String get moreThanBeforeAppointmentTitle =>
      'More than $hoursLabel Before Appointment';

  static String get lessThanBeforeAppointmentTitle =>
      'Less than $hoursLabel Before Appointment';

  /// Shown when cancellation is blocked inside the minimum notice window.
  static String get cancellationDeadlineMessage =>
      'Bookings can only be canceled up to $hoursLabel before the scheduled time.';
}
