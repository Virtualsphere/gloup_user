import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';

class AppointmentItemModel {
  final double amount;
  final int serviceId;
  final String serviceName;
  final String serviceDuration;

  const AppointmentItemModel({
    required this.amount,
    required this.serviceId,
    required this.serviceName,
    required this.serviceDuration,
  });

  factory AppointmentItemModel.fromJson(Map<String, dynamic> json) {
    return AppointmentItemModel(
      amount: (json['amount'] as num).toDouble(),
      serviceId: json['service_id'] as int,
      serviceName: json['service_name'] as String? ?? '',
      serviceDuration: json['service_duration'] as String? ?? '',
    );
  }

  AppointmentItemEntity toEntity() => AppointmentItemEntity(
        amount: amount,
        serviceId: serviceId,
        serviceName: serviceName,
        serviceDuration: serviceDuration,
      );
}

class AppointmentModel {
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
  final String status;
  final List<AppointmentItemModel> items;

  const AppointmentModel({
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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final common = json['common_data'] as Map<String, dynamic>;
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return AppointmentModel(
      id: common['id'] as int,
      bookingDate: common['booking_date'] as String? ?? '',
      totalAmount: (common['total_amount'] as num).toDouble(),
      discountedAmount: (common['discounted_amount'] as num).toDouble(),
      appointmentStatus: common['appointment_status'] as String? ?? '',
      slotFrom: common['slot_from'] as String? ?? '',
      slotTo: common['slot_to'] as String? ?? '',
      storeId: common['store_id'] as int,
      salonName: common['name'] as String? ?? '',
      images: (common['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      addressLine1: common['addressLine1'] as String? ?? '',
      addressLine2: common['addressLine2'] as String? ?? '',
      district: common['district'] as String? ?? '',
      city: common['city'] as String? ?? '',
      latitude: common['latitude'] as String? ?? '0',
      longitude: common['longitude'] as String? ?? '0',
      averageRating:
          double.tryParse(common['averagerating']?.toString() ?? '0') ?? 0.0,
      status: common['status'] as String? ?? '',
      items: rawItems
          .map((e) => AppointmentItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  AppointmentEntity toEntity() => AppointmentEntity(
        id: id,
        bookingDate: bookingDate,
        totalAmount: totalAmount,
        discountedAmount: discountedAmount,
        appointmentStatus: appointmentStatus,
        slotFrom: slotFrom,
        slotTo: slotTo,
        storeId: storeId,
        salonName: salonName,
        images: images,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        district: district,
        city: city,
        latitude: latitude,
        longitude: longitude,
        averageRating: averageRating,
        status: status,
        items: items.map((e) => e.toEntity()).toList(),
      );
}
