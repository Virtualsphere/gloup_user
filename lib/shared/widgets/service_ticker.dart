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
  static const Color _badgeTextColor = Color(0xFF212121);

  int _currentIndex = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _services = const [];

  @override
  void initState() {
    super.initState();
    _services = _normalize(widget.services);
    _startTicker();
  }

  @override
  void didUpdateWidget(covariant ServiceTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _normalize(widget.services);
    if (!_sameServices(_services, next)) {
      _services = next;
      _currentIndex = 0;
      _startTicker();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> _normalize(List<Map<String, dynamic>> input) {
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};

    for (final item in input) {
      final name = item['name']?.toString().trim() ?? '';
      if (name.isEmpty) continue;

      final discounted = item['discountedPrice'] ?? item['discounted_price'];
      final price = item['price'] ?? item['amount'];
      if (discounted == null && price == null) continue;

      final key = '$name|${discounted ?? price}';
      if (!seen.add(key)) continue;

      out.add({
        'name': name,
        'price': price,
        'discountedPrice': discounted ?? price,
      });
      if (out.length >= 5) break;
    }
    return out;
  }

  bool _sameServices(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i]['name'] != b[i]['name'] ||
          a[i]['price'] != b[i]['price'] ||
          a[i]['discountedPrice'] != b[i]['discountedPrice']) {
        return false;
      }
    }
    return true;
  }

  void _startTicker() {
    _timer?.cancel();
    if (_services.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _services.length <= 1) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _services.length;
      });
    });
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double _exactPrice(Map<String, dynamic> srv) {
    return _asDouble(srv['discountedPrice']) ?? _asDouble(srv['price']) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_services.isEmpty) return const SizedBox.shrink();

    final index = _currentIndex % _services.length;
    final textColor =
        widget.isOfferCard ? Colors.white : _badgeTextColor;

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.7),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _buildItem(_services[index], index, textColor),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> srv, int index, Color textColor) {
    final displayPrice = _exactPrice(srv);

    return Row(
      key: ValueKey<String>('${srv['name']}-$index'),
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
              color: textColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 3.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: widget.isOfferCard
                  ? Colors.white
                  : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(
          '₹${displayPrice.toInt()}',
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11.sp,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
