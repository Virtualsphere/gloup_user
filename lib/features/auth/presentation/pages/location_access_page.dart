import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/services/user_location_sync_service.dart';

class LocationAccessPage extends StatefulWidget {
  const LocationAccessPage({super.key});

  @override
  State<LocationAccessPage> createState() => _LocationAccessPageState();
}

class _LocationAccessPageState extends State<LocationAccessPage> {
  bool _isLoading = false;

  Future<void> _handleAllowLocation() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Position? position;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}

        position ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        unawaited(UserLocationSyncService.instance.reportOpenOrLogin());
      }
    } catch (e) {
      debugPrint('[LocationAccessPage] Location error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Granted -> confirm the GPS spot; denied / failed -> confirm manually
    // starting from the stored app location (Figma 21, node 58-2).
    if (mounted) {
      _goToConfirmLocation(position?.latitude, position?.longitude);
    }
  }

  void _handleEnterManually() {
    if (_isLoading) return;
    _goToConfirmLocation(null, null);
  }

  void _goToConfirmLocation(double? latitude, double? longitude) {
    context.push(
      RouteNames.confirmLocation,
      extra: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      // Top Row: Back button + Step progress indicators
                      Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(RouteNames.aboutYou);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.h,
                                horizontal: 4.w,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20.w,
                                color: const Color(0xFF262A30),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Step 1 Indicator (Active: #262A30)
                                Container(
                                  width: 24.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF262A30),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                // Step 2 Indicator (Active: #262A30 in Step 2)
                                Container(
                                  width: 24.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF262A30),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Spacer to balance the back chevron
                          SizedBox(width: 28.w),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // STEP 2 OF 2
                      Text(
                        'STEP 2 OF 2',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Minimalist Map Illustration matching Figma Node 57-2
                      Container(
                        width: double.infinity,
                        height: 280.h,
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.locationOnboardingMap,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 240.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2F6),
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: 64.w,
                                  color: const Color(0xFF2D6FA6),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Title: "Find salons around you"
                      Text(
                        'Find salons around you',
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF262A30),
                          height: 1.25,
                          letterSpacing: -0.4,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Subtitle
                      Text(
                        'Allow location access to see salons nearby, real travel distance and today\'s open slots.',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF717784),
                          height: 1.45,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Bullet 1: "Used only while you're using GloUp"
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B956B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              "Used only while you're using GloUp",
                              style: GoogleFonts.inter(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF262A30),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // Bullet 2: "Never shared with salons"
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B956B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Never shared with salons',
                              style: GoogleFonts.inter(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF262A30),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      SizedBox(height: 24.h),

                      // Button 1: "Allow location access"
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleAllowLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF262A30),
                            disabledBackgroundColor: const Color(0xFF262A30),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Allow location access',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Button 2: "Enter location manually"
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleEnterManually,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.2,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Enter location manually',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF262A30),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: bottomInset > 0 ? (bottomInset + 8.h) : 24.h,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
