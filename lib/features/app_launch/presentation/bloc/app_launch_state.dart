import 'package:equatable/equatable.dart';
import 'package:tressy/features/app_launch/domain/entities/app_launch_status.dart';

class AppLaunchState extends Equatable {
  final AppLaunchPhase phase;
  final String localityName;
  final int elapsedSeconds;
  final String? errorMessage;
  final String? errorCode;
  final bool isOfflineReady;

  const AppLaunchState({
    required this.phase,
    this.localityName = '',
    this.elapsedSeconds = 0,
    this.errorMessage,
    this.errorCode,
    this.isOfflineReady = true,
  });

  factory AppLaunchState.initial() {
    return const AppLaunchState(
      phase: AppLaunchPhase.chairLoading,
      localityName: '',
      elapsedSeconds: 0,
      isOfflineReady: true,
    );
  }

  AppLaunchState copyWith({
    AppLaunchPhase? phase,
    String? localityName,
    int? elapsedSeconds,
    String? errorMessage,
    String? errorCode,
    bool? isOfflineReady,
  }) {
    return AppLaunchState(
      phase: phase ?? this.phase,
      localityName: localityName ?? this.localityName,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      isOfflineReady: isOfflineReady ?? this.isOfflineReady,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        localityName,
        elapsedSeconds,
        errorMessage,
        errorCode,
        isOfflineReady,
      ];
}
