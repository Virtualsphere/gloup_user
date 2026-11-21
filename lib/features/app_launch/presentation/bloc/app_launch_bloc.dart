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

  Timer? _timer;
  int _seconds = 0;

  AppLaunchBloc({
    required this.checkLaunchStatusUseCase,
    required this.resolveLaunchAreaUseCase,
    required this.repository,
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
      emit(state.copyWith(
        phase: AppLaunchPhase.chairLoading,
        localityName: locality,
        elapsedSeconds: 0,
      ));
      _startLoadingTimer();
    }
  }

  Future<void> _onProceedFromFirstOpen(
    ProceedFromFirstOpen event,
    Emitter<AppLaunchState> emit,
  ) async {
    await repository.markFirstOpenCompleted();
    emit(state.copyWith(
      phase: AppLaunchPhase.chairLoading,
      elapsedSeconds: 0,
    ));
    _startLoadingTimer();
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
        state.phase == AppLaunchPhase.firstOpen) {
      return;
    }

    // After 15 seconds -> Failure
    if (event.second >= 15) {
      _timer?.cancel();
      emit(state.copyWith(
        phase: AppLaunchPhase.failure,
        elapsedSeconds: event.second,
        errorMessage: 'Check your mobile data or Wi-Fi and try again. Nothing you booked is lost.',
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
    // User chooses to keep waiting; stay in slowNetwork but keep timer ticking towards failure
    emit(state.copyWith(
      phase: AppLaunchPhase.slowNetwork,
    ));
  }

  void _onRetryAppLaunch(
    RetryAppLaunchTriggered event,
    Emitter<AppLaunchState> emit,
  ) {
    _startLoadingTimer();
    emit(state.copyWith(
      phase: AppLaunchPhase.chairLoading,
      elapsedSeconds: 0,
      errorMessage: null,
      errorCode: null,
    ));
  }

  void _onBrowseSavedSalons(
    BrowseSavedSalonsTriggered event,
    Emitter<AppLaunchState> emit,
  ) {
    _timer?.cancel();
    emit(state.copyWith(
      phase: AppLaunchPhase.homeSkeleton,
    ));
  }

  void _onCompleteAppLaunch(
    CompleteAppLaunchTriggered event,
    Emitter<AppLaunchState> emit,
  ) {
    _timer?.cancel();
    emit(state.copyWith(
      phase: AppLaunchPhase.completed,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

