import 'package:flutter/widgets.dart';
import 'package:tressy/core/services/app_analytics_service.dart';

/// Wraps the widget tree to capture tap coordinates and detect rage taps.
class AnalyticsTapTracker extends StatefulWidget {
  final Widget child;

  const AnalyticsTapTracker({super.key, required this.child});

  @override
  State<AnalyticsTapTracker> createState() => _AnalyticsTapTrackerState();
}

class _AnalyticsTapTrackerState extends State<AnalyticsTapTracker> {
  final List<DateTime> _recentTapTimes = [];
  Offset? _lastTapPosition;

  void _onPointerDown(PointerDownEvent event) {
    final size = MediaQuery.maybeOf(context)?.size;
    if (size == null || size.width == 0 || size.height == 0) return;

    final x = (event.position.dx / size.width).clamp(0.0, 1.0);
    final y = (event.position.dy / size.height).clamp(0.0, 1.0);
    final now = DateTime.now();

    // Rage tap detection: 3+ taps in same ~40px area within 1000ms
    _recentTapTimes.removeWhere((t) => now.difference(t).inMilliseconds > 1000);
    if (_lastTapPosition != null &&
        (event.position - _lastTapPosition!).distance < 40) {
      _recentTapTimes.add(now);
      if (_recentTapTimes.length >= 3) {
        AppAnalyticsService.instance.trackRageTap(
          'tap_area',
          taps: _recentTapTimes.length,
        );
        _recentTapTimes.clear();
      }
    } else {
      _recentTapTimes.clear();
      _recentTapTimes.add(now);
    }
    _lastTapPosition = event.position;

    // Send generic tap coordinates for heatmap/analytics
    AppAnalyticsService.instance.trackTap(
      'screen_tap',
      x: x,
      y: y,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: widget.child,
    );
  }
}

