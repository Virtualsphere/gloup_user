import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/features/app_launch/domain/entities/app_launch_status.dart';
import 'package:tressy/features/app_launch/domain/repositories/app_launch_repository.dart';
import 'package:tressy/features/app_launch/domain/usecases/check_launch_status_usecase.dart';
import 'package:tressy/features/app_launch/domain/usecases/resolve_launch_area_usecase.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_bloc.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_event.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_state.dart';

class MockAppLaunchRepository extends Mock implements AppLaunchRepository {}
class MockCheckLaunchStatusUseCase extends Mock implements CheckLaunchStatusUseCase {}
class MockResolveLaunchAreaUseCase extends Mock implements ResolveLaunchAreaUseCase {}

void main() {
  late MockAppLaunchRepository mockRepo;
  late MockCheckLaunchStatusUseCase mockCheckLaunchStatusUseCase;
  late MockResolveLaunchAreaUseCase mockResolveLaunchAreaUseCase;
  late AppLaunchBloc bloc;

  setUp(() {
    mockRepo = MockAppLaunchRepository();
    mockCheckLaunchStatusUseCase = MockCheckLaunchStatusUseCase();
    mockResolveLaunchAreaUseCase = MockResolveLaunchAreaUseCase();

    when(() => mockResolveLaunchAreaUseCase()).thenAnswer((_) async => 'Anna Nagar');
    when(() => mockCheckLaunchStatusUseCase()).thenAnswer((_) async => false);
    when(() => mockRepo.checkNetworkReachability()).thenAnswer((_) async => true);
    when(() => mockRepo.checkServerReachability()).thenAnswer((_) async => true);
    when(() => mockRepo.markFirstOpenCompleted()).thenAnswer((_) async {});

    bloc = AppLaunchBloc(
      checkLaunchStatusUseCase: mockCheckLaunchStatusUseCase,
      resolveLaunchAreaUseCase: mockResolveLaunchAreaUseCase,
      repository: mockRepo,
      minAnimationMs: 0, // 0 for fast deterministic tests
      serverRetryWindow: Duration.zero, // no server retries by default
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state has chairLoading phase and default locality', () {
    expect(bloc.state.phase, AppLaunchPhase.chairLoading);
    expect(bloc.state.localityName, '');
  });

  group('Forced preview states', () {
    test('forceFirstOpen emits firstOpen phase immediately', () async {
      bloc.add(const StartAppLaunchFlow(forceFirstOpen: true));
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.firstOpen)),
      );
    });

    test('forceChairLoader emits chairLoading phase immediately', () async {
      bloc.add(const StartAppLaunchFlow(forceChairLoader: true));
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.chairLoading)),
      );
    });

    test('forceSlowNetwork emits slowNetwork phase immediately', () async {
      bloc.add(const StartAppLaunchFlow(forceSlowNetwork: true));
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.slowNetwork)),
      );
    });

    test('forceFailure emits failure phase with error code', () async {
      bloc.add(const StartAppLaunchFlow(forceFailure: true));
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) =>
            s.phase == AppLaunchPhase.failure &&
            s.errorCode == "Error GL-503 · server didn't respond")),
      );
    });

    test('forceHomeSkeleton emits homeSkeleton phase immediately', () async {
      bloc.add(const StartAppLaunchFlow(forceHomeSkeleton: true));
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.homeSkeleton)),
      );
    });
  });

  group('Normal Launch Flow', () {
    test('when isFirstOpen is true, emits firstOpen', () async {
      when(() => mockCheckLaunchStatusUseCase()).thenAnswer((_) async => true);

      bloc.add(const StartAppLaunchFlow());
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.firstOpen)),
      );
    });

    test('when isFirstOpen is false and server is reachable, bootstrap completes', () async {
      when(() => mockCheckLaunchStatusUseCase()).thenAnswer((_) async => false);

      bloc.add(const StartAppLaunchFlow());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.chairLoading),
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.homeSkeleton),
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.completed),
        ]),
      );
    });

    test('when ProceedFromFirstOpen dispatched, marks completed and runs bootstrap', () async {
      bloc.add(const ProceedFromFirstOpen());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.chairLoading),
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.homeSkeleton),
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.completed),
        ]),
      );
      verify(() => mockRepo.markFirstOpenCompleted()).called(1);
    });

    test('when network is offline, emits failure with GL-001', () async {
      when(() => mockRepo.checkNetworkReachability()).thenAnswer((_) async => false);

      bloc.add(const StartAppLaunchFlow());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.chairLoading),
          predicate<AppLaunchState>((s) =>
              s.phase == AppLaunchPhase.failure &&
              s.errorCode == 'Error GL-001 · no internet connection'),
        ]),
      );
    });

    test('when server is unreachable, emits failure with GL-503', () async {
      when(() => mockRepo.checkServerReachability()).thenAnswer((_) async => false);

      bloc.add(const StartAppLaunchFlow());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.chairLoading),
          predicate<AppLaunchState>((s) =>
              s.phase == AppLaunchPhase.failure &&
              s.errorCode == "Error GL-503 · server didn't respond"),
        ]),
      );
    });

    test('server retries until it answers, then completes', () async {
      var calls = 0;
      when(() => mockRepo.checkServerReachability())
          .thenAnswer((_) async => ++calls >= 3);
      final retryBloc = AppLaunchBloc(
        checkLaunchStatusUseCase: mockCheckLaunchStatusUseCase,
        resolveLaunchAreaUseCase: mockResolveLaunchAreaUseCase,
        repository: mockRepo,
        minAnimationMs: 0,
        serverRetryWindow: const Duration(seconds: 5),
        serverRetryInterval: const Duration(milliseconds: 10),
      );
      addTearDown(retryBloc.close);

      retryBloc.add(const StartAppLaunchFlow());
      await expectLater(
        retryBloc.stream,
        emitsInOrder([
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.chairLoading),
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.homeSkeleton),
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.completed),
        ]),
      );
      expect(calls, 3);
    });

    test('KeepWaitingTriggered returns to the chair loader', () async {
      bloc.add(const StartAppLaunchFlow(forceSlowNetwork: true));
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.slowNetwork)),
      );
      bloc.add(const KeepWaitingTriggered());
      await expectLater(
        bloc.stream,
        emits(predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.chairLoading)),
      );
    });

    test('BrowseSavedSalonsTriggered transitions to homeSkeleton then completed', () async {
      bloc.add(const BrowseSavedSalonsTriggered());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.homeSkeleton),
          predicate<AppLaunchState>((s) => s.phase == AppLaunchPhase.completed),
        ]),
      );
    });
  });
}
