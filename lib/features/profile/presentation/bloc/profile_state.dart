import 'package:equatable/equatable.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {}

class ProfileLoggingOut extends ProfileState {
  const ProfileLoggingOut();
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileDeleting extends ProfileState {}

class ProfileDeleted extends ProfileState {
  final String message;

  const ProfileDeleted(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
