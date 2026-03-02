import 'package:tressy/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.firstname,
    required super.lastname,
    required super.phone,
    required super.email,
    required super.dateOfBirth,
    required super.city,
    required super.invitedCode,
    required super.wallet,
    required super.profilePic,
    required super.fullProfilePicUrl,
    required super.gender,
    required super.country,
    required super.status,
  });

  factory ProfileModel.fromJson(
      Map<String, dynamic> json, {
        String? imageBaseUrl,
      }) {
    final imagePath = json['profilePic']?.toString() ?? '';

    String fullProfilePicUrl = '';

    if (imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        fullProfilePicUrl = imagePath;
      } else if (imageBaseUrl != null && imageBaseUrl.isNotEmpty) {
        final cleanBase = imageBaseUrl.endsWith('/')
            ? imageBaseUrl.substring(0, imageBaseUrl.length - 1)
            : imageBaseUrl;

        fullProfilePicUrl = '$cleanBase/$imagePath';
      }
    }

    return ProfileModel(
      id: json['id'] as int? ?? 0,
      firstname: (json['firstname'] as String?)?.trim() ?? '',
      lastname: (json['lastname'] as String?)?.trim() ?? '',
      phone: json['phone'] as int? ?? 0,
      email: (json['email'] as String?)?.trim() ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      city: (json['city'] as String?)?.trim() ?? '',
      invitedCode: json['invited_code'] as String? ?? '',
      wallet: json['wallet']?.toString() ?? '0.0000',
      profilePic: imagePath,
      fullProfilePicUrl: fullProfilePicUrl,
      gender: json['gender'] as String? ?? '',
      country: json['country'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'date_of_birth': dateOfBirth,
      'city': city,
      'invited_code': invitedCode,
      'wallet': wallet,
      'profilePic': profilePic,
      'gender': gender,
      'country': country,
      'status': status,
    };
  }
}