import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;

  ProfileBloc({required this.getProfileUseCase}) : super(const ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
  }

  Future<void> _onGetProfile(GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(ProfileFailure(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onRefreshProfile(RefreshProfileEvent event, Emitter<ProfileState> emit) async {
    // Keep current state while refreshing in background
    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(ProfileFailure(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
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