import 'package:equatable/equatable.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class OtpSentSuccess extends AuthState {
  final AuthEntity authEntity;

  const OtpSentSuccess(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

class OtpVerifiedSuccess extends AuthState {
  final AuthEntity authEntity;

  const OtpVerifiedSuccess(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
