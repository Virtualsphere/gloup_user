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
  });

  factory VerifyOtpModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return VerifyOtpModel(
      status: json['status'] as int,
      message: json['message'] as String? ?? 'OTP Verified Successfully',
      token: data['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': {'token': token},
    };
  }
}
