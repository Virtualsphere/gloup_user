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

  const VerifyOtpEntity({
    required super.status,
    required super.message,
    required this.token,
  });

  @override
  List<Object?> get props => [status, message, token];
}
