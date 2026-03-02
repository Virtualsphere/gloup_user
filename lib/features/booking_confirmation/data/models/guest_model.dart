import 'package:tressy/features/booking_confirmation/domain/entities/guest_entity.dart';

/// Data model for guest
class GuestModel extends GuestEntity {
  const GuestModel({
    super.guestId,
    required super.name,
    required super.age,
    required super.gender,
    required super.phone,
    required super.status,
  });

  /// Create GuestModel from JSON
  factory GuestModel.fromJson(Map<String, dynamic> json) {
    // Parse guestId - try both 'guestId' and 'id' fields
    int? parsedGuestId;
    if (json['guestId'] != null) {
      if (json['guestId'] is int) {
        parsedGuestId = json['guestId'];
      } else {
        parsedGuestId = int.tryParse(json['guestId'].toString());
      }
    } else if (json['id'] != null) {
      if (json['id'] is int) {
        parsedGuestId = json['id'];
      } else {
        parsedGuestId = int.tryParse(json['id'].toString());
      }
    }
    
    return GuestModel(
      guestId: parsedGuestId,
      name: json['name']?.toString() ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      gender: json['gender']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
    );
  }

  /// Convert GuestModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (guestId != null) 'guestId': guestId,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'status': status,
    };
  }

  /// Convert to entity
  GuestEntity toEntity() {
    return GuestEntity(
      guestId: guestId,
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      status: status,
    );
  }
}
