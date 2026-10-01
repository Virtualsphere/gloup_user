import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ServiceTicker extends StatefulWidget {
  final List<Map<String, dynamic>> services;
  final bool isOfferCard;

  const ServiceTicker({
    super.key,
    required this.services,
    this.isOfferCard = false,
  });

  @override
  State<ServiceTicker> createState() => _ServiceTickerState();
}

class _ServiceTickerState extends State<ServiceTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.services.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.services.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.services.isEmpty) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildItem(widget.services[_currentIndex], _currentIndex),
    );
  }

  Widget _buildItem(Map<String, dynamic> srv, int index) {
    final double? discountedPrice = (srv['discountedPrice'] as num?)?.toDouble();
    final double? originalPrice = (srv['price'] as num?)?.toDouble();
    final double displayPrice = discountedPrice ?? originalPrice ?? 0;
    final bool hasDiscount = discountedPrice != null && originalPrice != null && originalPrice > discountedPrice;

    return Row(
      key: ValueKey<int>(index),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 130.w),
          child: Text(
            srv['name']?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              color: widget.isOfferCard ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 3.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: widget.isOfferCard ? Colors.white : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(
          '₹${displayPrice.toInt()}',
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11.sp,
            color: widget.isOfferCard
                ? Colors.white
                : const Color(0xFF1ECB5D), // Green highlighted price
          ),
        ),
        if (hasDiscount && !widget.isOfferCard) ...[
          SizedBox(width: 4.w),
          Text(
            '₹${originalPrice.toInt()}',
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 9.sp,
              decoration: TextDecoration.lineThrough,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
