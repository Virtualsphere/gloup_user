import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';
import 'package:tressy/shared/widgets/hd_cached_network_image.dart';

/// Hero banner carousel (Figma 3-2): rounded cards with a peek of the next
/// card and dot indicators. Banners are image-only until the API sends text.
class HomeHeroBanner extends StatefulWidget {
  final List<CarouselBannerEntity> banners;
  final bool isLoading;
  final ValueChanged<CarouselBannerEntity>? onBannerTap;
  final Duration autoPlayInterval;

  const HomeHeroBanner({
    super.key,
    required this.banners,
    this.isLoading = false,
    this.onBannerTap,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<HomeHeroBanner> createState() => _HomeHeroBannerState();
}

class _HomeHeroBannerState extends State<HomeHeroBanner> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(HomeHeroBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _index = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = 168.h;

    if (widget.isLoading && widget.banners.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: HomeDesignTokens.screenGutter.w,
          vertical: 12.h,
        ),
        child: Container(
          key: const Key('hero_banner_skeleton'),
          height: height,
          decoration: BoxDecoration(
            color: HomeDesignTokens.border,
            borderRadius: BorderRadius.circular(HomeDesignTokens.cardRadius.r),
          ),
        ),
      );
    }

    // No banners: collapse instead of leaving an empty slot.
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12.h),
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final banner = widget.banners[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  key: Key('hero_banner_$i'),
                  onTap: widget.onBannerTap == null
                      ? null
                      : () => widget.onBannerTap!(banner),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(HomeDesignTokens.cardRadius.r),
                    child: ColoredBox(
                      color: HomeDesignTokens.heroBannerBg,
                      child: HdCachedNetworkImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          SizedBox(height: 10.h),
          Row(
            key: const Key('hero_banner_dots'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _index ? 18.w : 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: i == _index
                        ? HomeDesignTokens.textPrimary
                        : HomeDesignTokens.border,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
            ],
          ),
        ],
        SizedBox(height: 12.h),
      ],
    );
  }
}
