import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/app_launch/domain/entities/app_launch_status.dart';
import 'package:tressy/features/app_launch/domain/repositories/app_launch_repository.dart';
import 'package:tressy/features/app_launch/domain/usecases/check_launch_status_usecase.dart';
import 'package:tressy/features/app_launch/domain/usecases/resolve_launch_area_usecase.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_event.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_state.dart';

class AppLaunchBloc extends Bloc<AppLaunchEvent, AppLaunchState> {
  final CheckLaunchStatusUseCase checkLaunchStatusUseCase;
  final ResolveLaunchAreaUseCase resolveLaunchAreaUseCase;
  final AppLaunchRepository repository;
  final int minAnimationMs;

  Timer? _timer;
  int _seconds = 0;
  bool _bootstrapInProgress = false;

  AppLaunchBloc({
    required this.checkLaunchStatusUseCase,
    required this.resolveLaunchAreaUseCase,
    required this.repository,
    this.minAnimationMs = 1200,
  }) : super(AppLaunchState.initial()) {
    on<StartAppLaunchFlow>(_onStartAppLaunchFlow);
    on<ProceedFromFirstOpen>(_onProceedFromFirstOpen);
    on<AppLaunchTick>(_onAppLaunchTick);
    on<KeepWaitingTriggered>(_onKeepWaiting);
    on<RetryAppLaunchTriggered>(_onRetryAppLaunch);
    on<BrowseSavedSalonsTriggered>(_onBrowseSavedSalons);
    on<CompleteAppLaunchTriggered>(_onCompleteAppLaunch);
  }

  Future<void> _onStartAppLaunchFlow(
    StartAppLaunchFlow event,
    Emitter<AppLaunchState> emit,
  ) async {
    _timer?.cancel();
    _seconds = 0;
    _bootstrapInProgress = false;

    // Resolve locality name
    final locality = await resolveLaunchAreaUseCase();

    // Check force preview overrides
    if (event.forceFirstOpen) {
      emit(state.copyWith(
        phase: AppLaunchPhase.firstOpen,
        localityName: locality,
        elapsedSeconds: 0,
      ));
      return;
    }
    if (event.forceChairLoader) {
      emit(state.copyWith(
        phase: AppLaunchPhase.chairLoading,
        localityName: locality,
        elapsedSeconds: 0,
      ));
      return;
    }
    if (event.forceSlowNetwork) {
      emit(state.copyWith(
        phase: AppLaunchPhase.slowNetwork,
        localityName: locality,
        elapsedSeconds: 6,
      ));
      return;
    }
    if (event.forceFailure) {
      emit(state.copyWith(
        phase: AppLaunchPhase.failure,
        localityName: locality,
        elapsedSeconds: 15,
        errorMessage: 'Check your mobile data or Wi-Fi and try again.',
        errorCode: 'Error GL-503 · server didn\'t respond',
      ));
      return;
    }
    if (event.forceHomeSkeleton) {
      emit(state.copyWith(
        phase: AppLaunchPhase.homeSkeleton,
        localityName: locality,
        elapsedSeconds: 0,
      ));
      return;
    }

    final isFirst = await checkLaunchStatusUseCase();
    if (isFirst) {
      emit(state.copyWith(
        phase: AppLaunchPhase.firstOpen,
        localityName: locality,
        elapsedSeconds: 0,
      ));
    } else {
      await _performLaunchBootstrap(locality, emit);
    }
  }

  Future<void> _onProceedFromFirstOpen(
    ProceedFromFirstOpen event,
    Emitter<AppLaunchState> emit,
  ) async {
    await repository.markFirstOpenCompleted();
    await _performLaunchBootstrap(state.localityName, emit);
  }

  Future<void> _performLaunchBootstrap(
    String locality,
    Emitter<AppLaunchState> emit,
  ) async {
    _bootstrapInProgress = true;
    _seconds = 0;
    emit(state.copyWith(
      phase: AppLaunchPhase.chairLoading,
      localityName: locality,
      elapsedSeconds: 0,
      errorMessage: null,
      errorCode: null,
    ));
    _startLoadingTimer();

    final stopwatch = Stopwatch()..start();

    // 1. Verify basic network reachability
    final hasNetwork = await repository.checkNetworkReachability();
    if (!hasNetwork) {
      _timer?.cancel();
      _bootstrapInProgress = false;
      emit(state.copyWith(
        phase: AppLaunchPhase.failure,
        errorMessage:
            'You seem to be offline. Check your mobile data or Wi-Fi and try again.',
        errorCode: 'Error GL-001 · no internet connection',
      ));
      return;
    }

    // 2. Check backend server reachability
    final serverOk = await repository.checkServerReachability();

    // Enforce smooth minimum animation duration
    final elapsedMs = stopwatch.elapsedMilliseconds;
    if (elapsedMs < minAnimationMs) {
      await Future.delayed(Duration(milliseconds: minAnimationMs - elapsedMs));
    }

    if (isClosed || !_bootstrapInProgress) return;

    if (serverOk) {
      _timer?.cancel();
      _bootstrapInProgress = false;

      // Brief skeleton shimmer before completing transition to main app
      emit(state.copyWith(
        phase: AppLaunchPhase.homeSkeleton,
      ));

      await Future.delayed(const Duration(milliseconds: 350));
      if (isClosed) return;

      emit(state.copyWith(
        phase: AppLaunchPhase.completed,
      ));
    } else {
      // If server check failed, check if network dropped
      final networkAlive = await repository.checkNetworkReachability();
      _timer?.cancel();
      _bootstrapInProgress = false;

      if (!networkAlive) {
        emit(state.copyWith(
          phase: AppLaunchPhase.failure,
          errorMessage:
              'Check your mobile data or Wi-Fi and try again. Nothing you booked is lost.',
          errorCode: 'Error GL-001 · connection lost',
        ));
      } else {
        emit(state.copyWith(
          phase: AppLaunchPhase.failure,
          errorMessage:
              'Check your mobile data or Wi-Fi and try again. Nothing you booked is lost.',
          errorCode: 'Error GL-503 · server didn\'t respond',
        ));
      }
    }
  }

  void _startLoadingTimer() {
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      add(AppLaunchTick(_seconds));
    });
  }

  void _onAppLaunchTick(
    AppLaunchTick event,
    Emitter<AppLaunchState> emit,
  ) {
    if (state.phase == AppLaunchPhase.completed ||
        state.phase == AppLaunchPhase.firstOpen ||
        state.phase == AppLaunchPhase.failure) {
      return;
    }

    // After 15 seconds -> Failure
    if (event.second >= 15) {
      _timer?.cancel();
      _bootstrapInProgress = false;
      emit(state.copyWith(
        phase: AppLaunchPhase.failure,
        elapsedSeconds: event.second,
        errorMessage:
            'Check your mobile data or Wi-Fi and try again. Nothing you booked is lost.',
        errorCode: 'Error GL-503 · server didn\'t respond',
      ));
      return;
    }

    // After 6 seconds -> Slow network
    if (event.second >= 6 && state.phase == AppLaunchPhase.chairLoading) {
      emit(state.copyWith(
        phase: AppLaunchPhase.slowNetwork,
        elapsedSeconds: event.second,
      ));
      return;
    }

    emit(state.copyWith(elapsedSeconds: event.second));
  }

  void _onKeepWaiting(
    KeepWaitingTriggered event,
    Emitter<AppLaunchState> emit,
  ) {
    emit(state.copyWith(
      phase: AppLaunchPhase.slowNetwork,
    ));
  }

  Future<void> _onRetryAppLaunch(
    RetryAppLaunchTriggered event,
    Emitter<AppLaunchState> emit,
  ) async {
    await _performLaunchBootstrap(state.localityName, emit);
  }

  Future<void> _onBrowseSavedSalons(
    BrowseSavedSalonsTriggered event,
    Emitter<AppLaunchState> emit,
  ) async {
    _timer?.cancel();
    _bootstrapInProgress = false;
    emit(state.copyWith(
      phase: AppLaunchPhase.homeSkeleton,
    ));
    await Future.delayed(const Duration(milliseconds: 350));
    if (isClosed) return;
    emit(state.copyWith(
      phase: AppLaunchPhase.completed,
    ));
  }

  void _onCompleteAppLaunch(
    CompleteAppLaunchTriggered event,
    Emitter<AppLaunchState> emit,
  ) {
    _timer?.cancel();
    _bootstrapInProgress = false;
    emit(state.copyWith(
      phase: AppLaunchPhase.completed,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _bootstrapInProgress = false;
    return super.close();
  }
}

