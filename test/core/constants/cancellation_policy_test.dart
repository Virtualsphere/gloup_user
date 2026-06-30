import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/core/constants/cancellation_policy.dart';

void main() {
  group('CancellationPolicy', () {
    test('uses 2-hour notice window', () {
      expect(CancellationPolicy.hoursBeforeAppointment, 2);
      expect(CancellationPolicy.hoursLabel, '2 hours');
    });

    test('policy copy references the same window', () {
      expect(
        CancellationPolicy.moreThanBeforeAppointmentTitle,
        'More than 2 hours Before Appointment',
      );
      expect(
        CancellationPolicy.lessThanBeforeAppointmentTitle,
        'Less than 2 hours Before Appointment',
      );
      expect(
        CancellationPolicy.cancellationDeadlineMessage,
        'Bookings can only be canceled up to 2 hours before the scheduled time.',
      );
    });
  });
}
