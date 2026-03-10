import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;
  final DeleteProfileUseCase deleteProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
    required this.deleteProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
    on<DeleteProfileEvent>(_onDeleteProfile);
  }

  ///Get Profile:-
  Future<void> _onGetProfile(
      GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(ProfileFailure(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onRefreshProfile(
      RefreshProfileEvent event, Emitter<ProfileState> emit) async {
    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(ProfileFailure(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  ///Update Profile:-
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());

    final result = await updateProfileUseCase(event.profile);

    await result.fold(
      (failure) async {
        emit(ProfileFailure(failure.message));
      },
      (_) async {
        final refresh = await getProfileUseCase();

        refresh.fold(
          (failure) => emit(ProfileFailure(failure.message)),
          (profile) => emit(ProfileLoaded(profile)),
        );
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoggingOut());
    final result = await logoutUseCase();
    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => null)!;
      emit(ProfileFailure(_mapFailureToMessage(failure)));
    } else {
      await LocalStorageService.clearAll();
      await LocalStorageService.setOnboardingCompleted(true);
      emit(const ProfileLoggedOut());
    }
  }

  ///Delete Profile:-
  Future<void> _onDeleteProfile(
      DeleteProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileDeleting());

    final result = await deleteProfileUseCase();

    await result.fold(
          (failure) async {
        emit(ProfileFailure(_mapFailureToMessage(failure)));
      },
          (response) async {
        if (response.success == true) {
          await LocalStorageService.clearAll();
          await LocalStorageService.setOnboardingCompleted(true);

          emit(ProfileDeleted(
            response.message ?? "Profile deleted successfully",
          ));
        } else {
          emit(ProfileFailure(
            response.message ?? "Failed to delete profile",
          ));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
