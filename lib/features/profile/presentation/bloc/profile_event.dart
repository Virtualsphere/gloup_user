import 'package:equatable/equatable.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();
}

class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileEntity profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}