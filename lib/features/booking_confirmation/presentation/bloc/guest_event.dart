import 'package:equatable/equatable.dart';

abstract class GuestEvent extends Equatable {
  const GuestEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all guests
class LoadGuestsEvent extends GuestEvent {
  const LoadGuestsEvent();
}

/// Event to select a guest
class SelectGuestEvent extends GuestEvent {
  final int index;

  const SelectGuestEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Event to add a new guest
class AddGuestEvent extends GuestEvent {
  final String name;
  final String gender;
  final int age;
  final String phone;

  const AddGuestEvent({
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, gender, age, phone];
}

/// Event to update an existing guest
class UpdateGuestEvent extends GuestEvent {
  final int guestId;
  final String? name;
  final String? gender;
  final int? age;
  final String? phone;

  const UpdateGuestEvent({
    required this.guestId,
    this.name,
    this.gender,
    this.age,
    this.phone,
  });

  @override
  List<Object?> get props => [guestId, name, gender, age, phone];
}
