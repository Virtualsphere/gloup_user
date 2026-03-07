class AppointmentItemEntity {
  final double amount;
  final int serviceId;
  final String serviceName;
  final String serviceDuration;

  const AppointmentItemEntity({
    required this.amount,
    required this.serviceId,
    required this.serviceName,
    required this.serviceDuration,
  });
}

class AppointmentEntity {
  final int id;
  final String bookingDate;
  final double totalAmount;
  final double discountedAmount;
  final String appointmentStatus;
  final String slotFrom;
  final String slotTo;
  final int storeId;
  final String salonName;
  final List<String> images;
  final String addressLine1;
  final String addressLine2;
  final String district;
  final String city;
  final String latitude;
  final String longitude;
  final double averageRating;
  final String status; // "upcomming" | "past"
  final List<AppointmentItemEntity> items;

  const AppointmentEntity({
    required this.id,
    required this.bookingDate,
    required this.totalAmount,
    required this.discountedAmount,
    required this.appointmentStatus,
    required this.slotFrom,
    required this.slotTo,
    required this.storeId,
    required this.salonName,
    required this.images,
    required this.addressLine1,
    required this.addressLine2,
    required this.district,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.averageRating,
    required this.status,
    required this.items,
  });
}
