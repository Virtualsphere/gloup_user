import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';
import 'package:tressy/features/auth/domain/repositories/auth_repository.dart';
import 'package:tressy/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:tressy/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/features/auth/services/social_auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final SocialAuthService socialAuthService;
  final AuthRepository authRepository;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.socialAuthService,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetAuthEvent>(_onResetAuth);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<AppleSignInEvent>(_onAppleSignIn);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await sendOtpUseCase(event.phone);

    result.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (authEntity) => emit(OtpSentSuccess(authEntity)),
    );
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await verifyOtpUseCase(event.phone, event.otp);

    result.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (authEntity) => emit(OtpVerifiedSuccess(authEntity)),
    );
  }

  void _onResetAuth(ResetAuthEvent event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  Future<void> _onGoogleSignIn(
      GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final credential = await socialAuthService.getGoogleCredential();

    switch (credential) {
      case SocialAuthCancelled():
        emit(const AuthInitial());
      case SocialAuthError(:final message):
        emit(AuthFailure(message));
      case GoogleCredential(:final idToken):
        final result = await authRepository.googleLogin(idToken);
        result.fold(
          (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
          (entity) => emit(
            SocialAuthSuccess((entity as VerifyOtpEntity).token),
          ),
        );
      default:
        emit(const AuthFailure('Unexpected credential type'));
    }
  }

  Future<void> _onAppleSignIn(
      AppleSignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final credential = await socialAuthService.getAppleCredential();

    switch (credential) {
      case SocialAuthCancelled():
        emit(const AuthInitial());
      case SocialAuthError(:final message):
        emit(AuthFailure(message));
      case AppleCredential(
          :final authorizationCode,
          :final identityToken,
          :final userIdentifier,
        ):
        final result = await authRepository.appleLogin(
          authorizationCode: authorizationCode,
          identityToken: identityToken,
          userIdentifier: userIdentifier,
        );
        result.fold(
          (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
          (entity) =>
              emit(SocialAuthSuccess((entity as VerifyOtpEntity).token)),
        );
      default:
        emit(const AuthFailure('Unexpected credential type'));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
