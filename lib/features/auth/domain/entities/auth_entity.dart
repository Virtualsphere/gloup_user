import 'package:equatable/equatable.dart';

abstract class AuthEntity extends Equatable {
  final int status;
  final String message;

  const AuthEntity({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [status, message];
}

class SendOtpEntity extends AuthEntity {
  const SendOtpEntity({
    required super.status,
    required super.message,
  });

  @override
  List<Object?> get props => [status, message];
}

class VerifyOtpEntity extends AuthEntity {
  final String token;
  final String? name;
  final String? gender;
  final bool isDetailsFound;
  final bool isNewUser;

  const VerifyOtpEntity({
    required super.status,
    required super.message,
    required this.token,
    this.name,
    this.gender,
    this.isDetailsFound = true,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [status, message, token, name, gender, isDetailsFound, isNewUser];
}
