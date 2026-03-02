import 'package:equatable/equatable.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  // Editable fields
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String dob;
  final String mobile;
  final String country;
  final String imagePath;

  // Initial values (to compare changes)
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String initialGender;
  final String initialDob;
  final String initialMobile;
  final String initialCountry;
  final String initialImagePath;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.gender = 'Not Selected',
    this.dob = '',
    this.mobile = '',
    this.country = '',
    this.imagePath = '',
    this.initialFirstName = '',
    this.initialLastName = '',
    this.initialEmail = '',
    this.initialGender = 'Not Selected',
    this.initialDob = '',
    this.initialMobile = '',
    this.initialCountry = '',
    this.initialImagePath = '',
  });

  bool get isChanged =>
      firstName != initialFirstName ||
      lastName != initialLastName ||
      email != initialEmail ||
      gender != initialGender ||
      dob != initialDob ||
      mobile != initialMobile ||
      country != initialCountry ||
      imagePath != initialImagePath;

  bool get isAllEmpty =>
      firstName.isEmpty &&
      lastName.isEmpty &&
      email.isEmpty &&
      dob.isEmpty &&
      mobile.isEmpty &&
      country.isEmpty &&
      gender == 'Not Selected';

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
    bool clearError = false,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    String? dob,
    String? mobile,
    String? country,
    String? initialFirstName,
    String? initialLastName,
    String? initialEmail,
    String? initialGender,
    String? initialDob,
    String? initialMobile,
    String? initialCountry,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      mobile: mobile ?? this.mobile,
      country: country ?? this.country,
      initialFirstName: initialFirstName ?? this.initialFirstName,
      initialLastName: initialLastName ?? this.initialLastName,
      initialEmail: initialEmail ?? this.initialEmail,
      initialGender: initialGender ?? this.initialGender,
      initialDob: initialDob ?? this.initialDob,
      initialMobile: initialMobile ?? this.initialMobile,
      initialCountry: initialCountry ?? this.initialCountry,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        errorMessage,
        firstName,
        lastName,
        email,
        gender,
        dob,
        mobile,
        country,
        initialFirstName,
        initialLastName,
        initialEmail,
        initialGender,
        initialDob,
        initialMobile,
        initialCountry,
      ];
}
