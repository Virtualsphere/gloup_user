import 'package:tressy/features/profile/domain/entities/profile_entity.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.firstname,
    required super.lastname,
    required super.phone,
    required super.age,
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
      age: json['age'] as int? ?? 0,
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
      'age': age,
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

  Future<FormData> toFormData() async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry("id", id.toString()),
      MapEntry("firstname", firstname),
      MapEntry("lastname", lastname),
      MapEntry("phone", phone.toString()),
      MapEntry('age', age.toString()),
      MapEntry("email", email),
      MapEntry("dob", dateOfBirth),
      MapEntry("city", city),
      MapEntry("invited_code", invitedCode),
      MapEntry("wallet", wallet.toString()),
      MapEntry("gender", gender),
      MapEntry("country", country),
      MapEntry("status", status),
    ]);

    if (profilePic.isNotEmpty && File(profilePic).existsSync()) {
      formData.files.add(
        MapEntry(
          "profilePic",
          await MultipartFile.fromFile(profilePic),
        ),
      );
    }

    return formData;
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      firstname: entity.firstname,
      lastname: entity.lastname,
      phone: entity.phone,
      age: entity.age,
      email: entity.email,
      dateOfBirth: entity.dateOfBirth,
      city: entity.city,
      invitedCode: entity.invitedCode,
      wallet: entity.wallet,
      profilePic: entity.profilePic,
      fullProfilePicUrl: entity.fullProfilePicUrl,
      gender: entity.gender,
      country: entity.country,
      status: entity.status,
    );
  }
}

///Delete Profile:-
class DeleteProfile extends DeleteProfileEntity {
  const DeleteProfile({
    super.success,
    super.message,
  });

  factory DeleteProfile.fromJson(Map<String, dynamic> json) {
    return DeleteProfile(
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
    };
  }
}
