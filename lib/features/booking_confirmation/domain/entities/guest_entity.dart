/// Domain entity for guest
class GuestEntity {
  final int? guestId;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String status;

  const GuestEntity({
    this.guestId,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.status,
  });

  /// Check if guest is active
  bool get isActive => status.toLowerCase() == 'active';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestEntity &&
          runtimeType == other.runtimeType &&
          guestId == other.guestId &&
          name == other.name &&
          age == other.age &&
          gender == other.gender &&
          phone == other.phone &&
          status == other.status;

  @override
  int get hashCode =>
      guestId.hashCode ^
      name.hashCode ^
      age.hashCode ^
      gender.hashCode ^
      phone.hashCode ^
      status.hashCode;
}
