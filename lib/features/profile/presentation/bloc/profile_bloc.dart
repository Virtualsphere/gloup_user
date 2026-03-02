import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;

  ProfileBloc({required this.getProfileUseCase})
      : super(const ProfileState());

  Future<void> getProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await getProfileUseCase();

    result.fold(
          (failure) => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: _mapFailureToMessage(failure),
      )),
          (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,

        firstName: profile.firstname,
        lastName: profile.lastname,
        email: profile.email,
        gender: profile.gender,
        dob: profile.dateOfBirth,
        mobile: profile.phone.toString(),
        country: profile.country,

        initialFirstName: profile.firstname,
        initialLastName: profile.lastname,
        initialEmail: profile.email,
        initialGender: profile.gender,
        initialDob: profile.dateOfBirth,
        initialMobile: profile.phone.toString(),
        initialCountry: profile.country,

        clearError: true,
      )),
    );
  }
  void updateFirstName(String value) =>
      emit(state.copyWith(firstName: value));

  void updateLastName(String value) =>
      emit(state.copyWith(lastName: value));

  void updateEmail(String value) =>
      emit(state.copyWith(email: value));

  void updateGender(String value) =>
      emit(state.copyWith(gender: value));

  void updateDob(String value) =>
      emit(state.copyWith(dob: value));

  void updateMobile(String value) =>
      emit(state.copyWith(mobile: value));

  void updateCountry(String value) =>
      emit(state.copyWith(country: value));

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection';
    if (failure is ServerFailure) return failure.message;
    return 'Something went wrong';
  }
}