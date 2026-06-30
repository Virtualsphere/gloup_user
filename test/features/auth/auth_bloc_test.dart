import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/auth/domain/repositories/auth_repository.dart';
import 'package:tressy/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:tressy/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/features/auth/services/social_auth_service.dart';

import '../../helpers/test_fixtures.dart';

class MockSendOtpUseCase extends Mock implements SendOtpUseCase {}

class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSocialAuthService extends Mock implements SocialAuthService {}

void main() {
  late MockSendOtpUseCase sendOtpUseCase;
  late MockVerifyOtpUseCase verifyOtpUseCase;
  late MockAuthRepository authRepository;
  late MockSocialAuthService socialAuthService;

  AuthBloc buildBloc() => AuthBloc(
        sendOtpUseCase: sendOtpUseCase,
        verifyOtpUseCase: verifyOtpUseCase,
        socialAuthService: socialAuthService,
        authRepository: authRepository,
      );

  setUp(() {
    sendOtpUseCase = MockSendOtpUseCase();
    verifyOtpUseCase = MockVerifyOtpUseCase();
    authRepository = MockAuthRepository();
    socialAuthService = MockSocialAuthService();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, OtpSentSuccess] when send OTP succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const SendOtpEvent('9876543210')),
      setUp: () {
        when(() => sendOtpUseCase('9876543210'))
            .thenAnswer((_) async => const Right(sendOtpSuccess));
      },
      expect: () => [
        const AuthLoading(),
        const OtpSentSuccess(sendOtpSuccess),
      ],
      verify: (_) {
        verify(() => sendOtpUseCase('9876543210')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when send OTP fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const SendOtpEvent('9876543210')),
      setUp: () {
        when(() => sendOtpUseCase('9876543210')).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to send OTP')),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Failed to send OTP'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, OtpVerifiedSuccess] when verify OTP succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const VerifyOtpEvent(phone: '9876543210', otp: '123456'),
      ),
      setUp: () {
        when(() => verifyOtpUseCase('9876543210', '123456'))
            .thenAnswer((_) async => const Right(verifyOtpSuccess));
      },
      expect: () => [
        const AuthLoading(),
        const OtpVerifiedSuccess(verifyOtpSuccess),
      ],
      verify: (_) {
        verify(() => verifyOtpUseCase('9876543210', '123456')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when verify OTP fails',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const VerifyOtpEvent(phone: '9876543210', otp: '000000'),
      ),
      setUp: () {
        when(() => verifyOtpUseCase('9876543210', '000000')).thenAnswer(
          (_) async => const Left(ServerFailure('Invalid OTP')),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Invalid OTP'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthInitial on ResetAuthEvent',
      build: buildBloc,
      seed: () => const AuthFailure('stale error'),
      act: (bloc) => bloc.add(const ResetAuthEvent()),
      expect: () => [const AuthInitial()],
    );

    blocTest<AuthBloc, AuthState>(
      'maps unexpected failure to generic message on send OTP',
      build: buildBloc,
      act: (bloc) => bloc.add(const SendOtpEvent('9876543210')),
      setUp: () {
        when(() => sendOtpUseCase('9876543210')).thenAnswer(
          (_) async => const Left(CacheFailure('cache miss')),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure('An unexpected error occurred'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'maps network failure to AuthFailure message on verify OTP',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const VerifyOtpEvent(phone: '9876543210', otp: '123456'),
      ),
      setUp: () {
        when(() => verifyOtpUseCase('9876543210', '123456')).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure('No internet connection'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthInitial when Google sign-in is cancelled',
      build: buildBloc,
      act: (bloc) => bloc.add(const GoogleSignInEvent()),
      setUp: () {
        when(() => socialAuthService.getGoogleCredential())
            .thenAnswer((_) async => SocialAuthCancelled());
      },
      expect: () => [const AuthLoading(), const AuthInitial()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when Google sign-in returns an error',
      build: buildBloc,
      act: (bloc) => bloc.add(const GoogleSignInEvent()),
      setUp: () {
        when(() => socialAuthService.getGoogleCredential()).thenAnswer(
          (_) async => SocialAuthError('Google sign-in failed'),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Google sign-in failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits SocialAuthSuccess when Google sign-in succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const GoogleSignInEvent()),
      setUp: () {
        when(() => socialAuthService.getGoogleCredential()).thenAnswer(
          (_) async => GoogleCredential('google-id-token'),
        );
        when(() => authRepository.googleLogin('google-id-token'))
            .thenAnswer((_) async => const Right(verifyOtpSuccess));
      },
      expect: () => [
        const AuthLoading(),
        const SocialAuthSuccess('jwt-token'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when Google backend login fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const GoogleSignInEvent()),
      setUp: () {
        when(() => socialAuthService.getGoogleCredential()).thenAnswer(
          (_) async => GoogleCredential('google-id-token'),
        );
        when(() => authRepository.googleLogin('google-id-token')).thenAnswer(
          (_) async => const Left(ServerFailure('Google login rejected')),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Google login rejected'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthInitial when Apple sign-in is cancelled',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppleSignInEvent()),
      setUp: () {
        when(() => socialAuthService.getAppleCredential())
            .thenAnswer((_) async => SocialAuthCancelled());
      },
      expect: () => [const AuthLoading(), const AuthInitial()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits SocialAuthSuccess when Apple sign-in succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppleSignInEvent()),
      setUp: () {
        when(() => socialAuthService.getAppleCredential()).thenAnswer(
          (_) async => AppleCredential(
            authorizationCode: 'auth-code',
            identityToken: 'identity-token',
            userIdentifier: 'user-123',
          ),
        );
        when(
          () => authRepository.appleLogin(
            authorizationCode: 'auth-code',
            identityToken: 'identity-token',
            userIdentifier: 'user-123',
          ),
        ).thenAnswer((_) async => const Right(verifyOtpSuccess));
      },
      expect: () => [
        const AuthLoading(),
        const SocialAuthSuccess('jwt-token'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when Apple backend login fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppleSignInEvent()),
      setUp: () {
        when(() => socialAuthService.getAppleCredential()).thenAnswer(
          (_) async => AppleCredential(
            authorizationCode: 'auth-code',
            identityToken: 'identity-token',
            userIdentifier: 'user-123',
          ),
        );
        when(
          () => authRepository.appleLogin(
            authorizationCode: any(named: 'authorizationCode'),
            identityToken: any(named: 'identityToken'),
            userIdentifier: any(named: 'userIdentifier'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Apple login rejected')),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Apple login rejected'),
      ],
    );
  });
}
