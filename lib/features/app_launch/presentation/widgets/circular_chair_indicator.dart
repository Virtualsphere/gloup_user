import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tressy/core/constants/app_images.dart';

enum ChairIndicatorMode {
  blueLoader,
  amberLoader,
  greyFailure,
}

class CircularChairIndicator extends StatefulWidget {
  final ChairIndicatorMode mode;
  final double? size;

  const CircularChairIndicator({
    super.key,
    this.mode = ChairIndicatorMode.blueLoader,
    this.size,
  });

  @override
  State<CircularChairIndicator> createState() => _CircularChairIndicatorState();
}

class _CircularChairIndicatorState extends State<CircularChairIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.mode != ChairIndicatorMode.greyFailure) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(CircularChairIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode == ChairIndicatorMode.greyFailure) {
      _animController.stop();
    } else if (!_animController.isAnimating) {
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.size ?? 160.w;

    if (widget.mode == ChairIndicatorMode.greyFailure) {
      return Container(
        width: 130.w,
        height: 130.w,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F3F5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFF717784),
            BlendMode.srcIn,
          ),
          child: Image.asset(
            AppImages.salonChair,
            width: 58.w,
            height: 58.w,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    final isAmber = widget.mode == ChairIndicatorMode.amberLoader;
    final arcColor = isAmber ? const Color(0xFFA16207) : const Color(0xFF1D70B8);
    final bgColor = isAmber ? const Color(0xFFFBF6EE) : const Color(0xFFEBF5FB);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: diameter - 8.w,
            height: diameter - 8.w,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
          // Rotating arc
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animController.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(diameter, diameter),
                  painter: _ArcPainter(
                    arcColor: arcColor,
                    strokeWidth: 3.5.w,
                  ),
                ),
              );
            },
          ),
          // Center salon chair
          Image.asset(
            AppImages.salonChair,
            width: 68.w,
            height: 68.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color arcColor;
  final double strokeWidth;

  _ArcPainter({
    required this.arcColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw ~100 degree arc
    canvas.drawArc(rect, -math.pi / 2, 1.6, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.arcColor != arcColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

