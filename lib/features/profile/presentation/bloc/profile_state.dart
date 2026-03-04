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

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
