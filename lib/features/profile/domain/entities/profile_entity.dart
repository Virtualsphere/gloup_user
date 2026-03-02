abstract class ProfileEntity {
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
}