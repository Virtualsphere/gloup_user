import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';

/// Data model for time slot
class SlotModel extends SlotEntity {
  const SlotModel({
    required super.time,
    required super.status,
  });

  /// Create SlotModel from JSON
  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      time: json['time']?.toString() ?? '',
      status: json['status']?.toString() ?? 'available',
    );
  }

  /// Convert SlotModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'status': status,
    };
  }

  /// Convert to entity
  SlotEntity toEntity() {
    return SlotEntity(
      time: time,
      status: status,
    );
  }
}
