import 'package:tressy/features/auth/domain/entities/auth_entity.dart';

class SendOtpModel extends SendOtpEntity {
  const SendOtpModel({
    required super.status,
    required super.message,
  });

  factory SendOtpModel.fromJson(Map<String, dynamic> json) {
    return SendOtpModel(
      status: json['status'] as int,
      message: json['data'] as String? ?? 'OTP Sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': message,
    };
  }
}

class VerifyOtpModel extends VerifyOtpEntity {
  const VerifyOtpModel({
    required super.status,
    required super.message,
    required super.token,
    super.name,
    super.gender,
    super.isDetailsFound,
    super.isNewUser,
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final name = (data['name'] as String?)?.trim() ??
        [data['firstname'], data['lastname']].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ').trim();
    final gender = data['gender'] as String?;
    final explicitDetailsFound = data['is_details_found'] as bool?;
    final hasDetails = explicitDetailsFound ?? (name.isNotEmpty && gender != null && gender.trim().isNotEmpty);

    return VerifyOtpModel(
      status: json['status'] as int,
      message: json['message'] as String? ?? 'OTP Verified Successfully',
      token: data['token'] as String,
      name: name.isNotEmpty ? name : null,
      gender: gender,
      isDetailsFound: hasDetails,
      isNewUser: data['is_new_user'] as bool? ?? !hasDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': {
        'token': token,
        'name': name,
        'gender': gender,
        'is_details_found': isDetailsFound,
        'is_new_user': isNewUser,
      },
    };
  }
}
