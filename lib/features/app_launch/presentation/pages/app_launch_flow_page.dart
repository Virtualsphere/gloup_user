import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/notification_routes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/services/firebase_notification_service.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/app_launch/domain/entities/app_launch_status.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_bloc.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_event.dart';
import 'package:tressy/features/app_launch/presentation/bloc/app_launch_state.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_chair_loader_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_failure_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_first_open_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_home_skeleton_view.dart';
import 'package:tressy/features/app_launch/presentation/pages/app_launch_slow_network_view.dart';

class AppLaunchFlowPage extends StatefulWidget {
  final AppLaunchPhase? forcedPhase;

  const AppLaunchFlowPage({
    super.key,
    this.forcedPhase,
  });

  @override
  State<AppLaunchFlowPage> createState() => _AppLaunchFlowPageState();
}

class _AppLaunchFlowPageState extends State<AppLaunchFlowPage> {
  late AppLaunchBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<AppLaunchBloc>();
    _bloc.add(StartAppLaunchFlow(
      forceFirstOpen: widget.forcedPhase == AppLaunchPhase.firstOpen,
      forceChairLoader: widget.forcedPhase == AppLaunchPhase.chairLoading,
      forceSlowNetwork: widget.forcedPhase == AppLaunchPhase.slowNetwork,
      forceFailure: widget.forcedPhase == AppLaunchPhase.failure,
      forceHomeSkeleton: widget.forcedPhase == AppLaunchPhase.homeSkeleton,
    ));
  }

  void _proceedToMainApp() {
    if (!mounted) return;

    final isLoggedIn = LocalStorageService.isLoggedIn;
    if (!isLoggedIn) {
      FirebaseNotificationService.clearPendingLaunchMessage();
      context.go(RouteNames.login);
      return;
    }

    final launchMessage =
        FirebaseNotificationService.takePendingLaunchMessage();
    if (launchMessage != null) {
      NotificationRoutes.navigateFromMessage(
        GoRouter.of(context),
        launchMessage,
      );
      return;
    }

    context.go(RouteNames.home);
  }

  Future<void> _openNetworkSettings() async {
    // Attempt opening network/app settings via system scheme or show guidance
    final Uri settingsUri = Uri.parse('app-settings:');
    try {
      if (await canLaunchUrl(settingsUri)) {
        await launchUrl(settingsUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please check your Wi-Fi or Mobile Data in your device settings.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please check your Wi-Fi or Mobile Data in your device settings.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<AppLaunchBloc, AppLaunchState>(
        listener: (context, state) {
          if (state.phase == AppLaunchPhase.completed) {
            _proceedToMainApp();
          }
        },
        builder: (context, state) {
          switch (state.phase) {
            case AppLaunchPhase.firstOpen:
              return AppLaunchFirstOpenView(
                onProceed: () {
                  _bloc.add(const ProceedFromFirstOpen());
                },
              );

            case AppLaunchPhase.chairLoading:
              return AppLaunchChairLoaderView(
                locality: state.localityName,
              );

            case AppLaunchPhase.slowNetwork:
              return AppLaunchSlowNetworkView(
                onBrowseSavedSalons: () {
                  _bloc.add(const BrowseSavedSalonsTriggered());
                },
                onKeepWaiting: () {
                  _bloc.add(const KeepWaitingTriggered());
                },
              );

            case AppLaunchPhase.failure:
              return AppLaunchFailureView(
                errorMessage: state.errorMessage,
                errorCode: state.errorCode,
                onTryAgain: () {
                  _bloc.add(const RetryAppLaunchTriggered());
                },
                onOpenNetworkSettings: _openNetworkSettings,
              );

            case AppLaunchPhase.homeSkeleton:
              return AppLaunchHomeSkeletonView(
                locality: state.localityName,
              );

            case AppLaunchPhase.completed:
              return AppLaunchHomeSkeletonView(
                locality: state.localityName,
              );
          }
        },
      ),
    );
  }
}

