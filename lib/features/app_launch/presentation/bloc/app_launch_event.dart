import 'package:equatable/equatable.dart';

abstract class AppLaunchEvent extends Equatable {
  const AppLaunchEvent();

  @override
  List<Object?> get props => [];
}

class StartAppLaunchFlow extends AppLaunchEvent {
  final bool forceFirstOpen;
  final bool forceChairLoader;
  final bool forceSlowNetwork;
  final bool forceFailure;
  final bool forceHomeSkeleton;

  const StartAppLaunchFlow({
    this.forceFirstOpen = false,
    this.forceChairLoader = false,
    this.forceSlowNetwork = false,
    this.forceFailure = false,
    this.forceHomeSkeleton = false,
  });

  @override
  List<Object?> get props => [
        forceFirstOpen,
        forceChairLoader,
        forceSlowNetwork,
        forceFailure,
        forceHomeSkeleton,
      ];
}

class ProceedFromFirstOpen extends AppLaunchEvent {
  const ProceedFromFirstOpen();
}

class AppLaunchTick extends AppLaunchEvent {
  final int second;

  const AppLaunchTick(this.second);

  @override
  List<Object?> get props => [second];
}

class KeepWaitingTriggered extends AppLaunchEvent {
  const KeepWaitingTriggered();
}

class RetryAppLaunchTriggered extends AppLaunchEvent {
  const RetryAppLaunchTriggered();
}

class BrowseSavedSalonsTriggered extends AppLaunchEvent {
  const BrowseSavedSalonsTriggered();
}

class CompleteAppLaunchTriggered extends AppLaunchEvent {
  const CompleteAppLaunchTriggered();
}

