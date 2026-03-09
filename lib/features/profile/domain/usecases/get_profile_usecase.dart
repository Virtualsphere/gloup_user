import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';
import 'package:tressy/features/profile/domain/repositories/profile_repository.dart';

///get profile:-
class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call() async {
    return await repository.getProfile();
  }
}

///logout:-
class LogoutUseCase {
  final ProfileRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return repository.logout();
  }
}

///update profile:-
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(ProfileEntity profile) async {
    return repository.updateProfile(profile);
  }
}

///Delete Profile:-
class DeleteProfileUseCase {
  final ProfileRepository repository;

  DeleteProfileUseCase(this.repository);

  Future<Either<Failure, DeleteProfileEntity>> call() async {
    return await repository.deleteProfile();
  }
}