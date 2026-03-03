import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final int id;
  final String firstname;
  final String lastname;
  final int phone;
  final String email;
  final String dateOfBirth;
  final String city;
  final String invitedCode;
  final String wallet;
  final String profilePic;
  final String fullProfilePicUrl;
  final String gender;
  final String country;
  final String status;

  const ProfileEntity({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.email,
    required this.dateOfBirth,
    required this.city,
    required this.invitedCode,
    required this.wallet,
    required this.profilePic,
    required this.fullProfilePicUrl,
    required this.gender,
    required this.country,
    required this.status,
  });

  String get fullName => '$firstname $lastname'.trim();

  ProfileEntity copyWith({
    String? firstname,
    String? lastname,
    int? phone,
    String? email,
    String? dateOfBirth,
    String? city,
    String? gender,
    String? country,
    String? profilePic,
  }) {
    return ProfileEntity(
      id: id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      city: city ?? this.city,
      invitedCode: invitedCode,
      wallet: wallet,
      profilePic: profilePic ?? this.profilePic,
      fullProfilePicUrl: fullProfilePicUrl,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstname,
    lastname,
    phone,
    email,
    dateOfBirth,
    city,
    invitedCode,
    wallet,
    profilePic,
    fullProfilePicUrl,
    gender,
    country,
    status,
  ];
}