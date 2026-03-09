import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> sendOtp(String phone);
  Future<Either<Failure, AuthEntity>> verifyOtp(String phone, String otp);
  Future<Either<Failure, AuthEntity>> googleLogin(String idToken);
  Future<Either<Failure, AuthEntity>> appleLogin({
    required String authorizationCode,
    required String identityToken,
    required String userIdentifier,
  });
}
