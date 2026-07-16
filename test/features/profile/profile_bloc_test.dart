import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';

import '../../helpers/test_fixtures.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockDeleteProfileUseCase extends Mock implements DeleteProfileUseCase {}

void main() {
  late MockGetProfileUseCase getProfileUseCase;
  late MockUpdateProfileUseCase updateProfileUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockDeleteProfileUseCase deleteProfileUseCase;

  ProfileBloc buildBloc() => ProfileBloc(
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
        logoutUseCase: logoutUseCase,
        deleteProfileUseCase: deleteProfileUseCase,
      );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(testProfile);
    const secureStorageChannel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      switch (call.method) {
        case 'read':
          return null;
        case 'write':
        case 'delete':
        case 'deleteAll':
          return null;
        default:
          return null;
      }
    });
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'onboarding_completed': true,
    });
    await LocalStorageService.init();
  });

  setUp(() {
    getProfileUseCase = MockGetProfileUseCase();
    updateProfileUseCase = MockUpdateProfileUseCase();
    logoutUseCase = MockLogoutUseCase();
    deleteProfileUseCase = MockDeleteProfileUseCase();
  });

  group('ProfileBloc', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when get profile succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const GetProfileEvent()),
      setUp: () {
        when(() => getProfileUseCase())
            .thenAnswer((_) async => const Right(testProfile));
      },
      expect: () => [
        const ProfileLoading(),
        const ProfileLoaded(testProfile),
      ],
      verify: (_) {
        verify(() => getProfileUseCase()).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when get profile fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const GetProfileEvent()),
      setUp: () {
        when(() => getProfileUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to load profile')),
        );
      },
      expect: () => [
        const ProfileLoading(),
        const ProfileFailure('Failed to load profile'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoggingOut, ProfileLoggedOut] when logout succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const LogoutEvent()),
      setUp: () {
        when(() => logoutUseCase()).thenAnswer((_) async => const Right(null));
      },
      expect: () => [
        const ProfileLoggingOut(),
        const ProfileLoggedOut(),
      ],
      verify: (_) {
        verify(() => logoutUseCase()).called(1);
        expect(LocalStorageService.isLoggedIn, isFalse);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoggingOut, ProfileFailure] when logout fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const LogoutEvent()),
      setUp: () {
        when(() => logoutUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Logout failed')),
        );
      },
      expect: () => [
        const ProfileLoggingOut(),
        const ProfileFailure('Logout failed'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileLoaded on refresh without loading state',
      build: buildBloc,
      act: (bloc) => bloc.add(const RefreshProfileEvent()),
      setUp: () {
        when(() => getProfileUseCase())
            .thenAnswer((_) async => const Right(testProfile));
      },
      expect: () => [const ProfileLoaded(testProfile)],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileFailure when refresh fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const RefreshProfileEvent()),
      setUp: () {
        when(() => getProfileUseCase()).thenAnswer(
          (_) async => const Left(NetworkFailure('Offline')),
        );
      },
      expect: () => [const ProfileFailure('Offline')],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits update flow ending in ProfileLoaded when update succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateProfileEvent(testProfile)),
      setUp: () {
        when(() => updateProfileUseCase(testProfile))
            .thenAnswer((_) async => const Right(testProfile));
        when(() => getProfileUseCase())
            .thenAnswer((_) async => const Right(testProfile));
      },
      expect: () => [
        const ProfileUpdating(testProfile),
        const ProfileUpdateSuccess(testProfile),
        const ProfileLoaded(testProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileUpdateFailure when update fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateProfileEvent(testProfile)),
      setUp: () {
        when(() => updateProfileUseCase(testProfile)).thenAnswer(
          (_) async => const Left(ServerFailure('Update rejected')),
        );
      },
      expect: () => [
        const ProfileUpdating(testProfile),
        const ProfileUpdateFailure('Update rejected', testProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileUpdateFailure when refresh fails after update',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateProfileEvent(testProfile)),
      setUp: () {
        when(() => updateProfileUseCase(testProfile))
            .thenAnswer((_) async => const Right(testProfile));
        when(() => getProfileUseCase()).thenAnswer(
          (_) async => const Left(ServerFailure('Refresh failed')),
        );
      },
      expect: () => [
        const ProfileUpdating(testProfile),
        const ProfileUpdateFailure('Refresh failed', testProfile),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileDeleted and clears storage when delete succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const DeleteProfileEvent()),
      setUp: () {
        when(() => deleteProfileUseCase())
            .thenAnswer((_) async => const Right(testDeleteProfileSuccess));
      },
      expect: () => [
        ProfileDeleting(),
        const ProfileDeleted('Profile deleted successfully'),
      ],
      verify: (_) {
        expect(LocalStorageService.isLoggedIn, isFalse);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileFailure when delete API returns success false',
      build: buildBloc,
      act: (bloc) => bloc.add(const DeleteProfileEvent()),
      setUp: () {
        when(() => deleteProfileUseCase())
            .thenAnswer((_) async => const Right(testDeleteProfileFailure));
      },
      expect: () => [
        ProfileDeleting(),
        const ProfileFailure('Failed to delete profile'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileFailure when delete use case fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const DeleteProfileEvent()),
      setUp: () {
        when(() => deleteProfileUseCase()).thenAnswer(
          (_) async => const Left(ValidationFailure('Invalid request')),
        );
      },
      expect: () => [
        ProfileDeleting(),
        const ProfileFailure('An unexpected error occurred'),
      ],
    );
  });
}
