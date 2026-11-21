enum AppLaunchPhase {
  firstOpen,
  chairLoading,
  slowNetwork,
  failure,
  homeSkeleton,
  completed,
}

class AppLaunchStateEntity {
  final AppLaunchPhase phase;
  final String localityName;
  final int elapsedSeconds;
  final String? errorMessage;
  final String? errorCode;
  final bool isOfflineReady;

  const AppLaunchStateEntity({
    required this.phase,
    this.localityName = 'Anna Nagar',
    this.elapsedSeconds = 0,
    this.errorMessage,
    this.errorCode,
    this.isOfflineReady = true,
  });

  AppLaunchStateEntity copyWith({
    AppLaunchPhase? phase,
    String? localityName,
    int? elapsedSeconds,
    String? errorMessage,
    String? errorCode,
    bool? isOfflineReady,
  }) {
    return AppLaunchStateEntity(
      phase: phase ?? this.phase,
      localityName: localityName ?? this.localityName,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      isOfflineReady: isOfflineReady ?? this.isOfflineReady,
    );
  }
}

