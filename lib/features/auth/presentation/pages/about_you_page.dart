import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';

class AboutYouPage extends StatefulWidget {
  final DioClient? dioClient;

  const AboutYouPage({
    super.key,
    this.dioClient,
  });

  @override
  State<AboutYouPage> createState() => _AboutYouPageState();
}

class _AboutYouPageState extends State<AboutYouPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  String? _selectedGender; // 'male' or 'female'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _nameFocusNode.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _nameFocusNode.removeListener(_onFieldChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty && _selectedGender != null;
  }

  Future<void> _handleContinue() async {
    if (!_isFormValid || _isLoading) return;

    final fullName = _nameController.text.trim();
    final gender = _selectedGender!;

    setState(() {
      _isLoading = true;
    });

    try {
      final client = widget.dioClient ?? sl<DioClient>();
      final parts = fullName.split(' ');
      final firstname = parts.first;
      final lastname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final formData = FormData.fromMap({
        'firstname': firstname,
        if (lastname.isNotEmpty) 'lastname': lastname,
        'name': fullName,
        'gender': gender,
      });

      await client.patch(
        ApiRoutes.getUserProfile,
        data: formData,
      );

      // Cache locally
      await LocalStorageService.setString(Keys.userName, fullName);
      await LocalStorageService.setString('selected_gender', gender);

      if (mounted) {
        CustomToast.showSuccess(context, "Profile updated successfully!");
        try {
          context.go(RouteNames.home);
        } catch (_) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      // Even if network fails, cache locally and proceed to home
      await LocalStorageService.setString(Keys.userName, fullName);
      await LocalStorageService.setString('selected_gender', gender);

      if (mounted) {
        try {
          context.go(RouteNames.home);
        } catch (_) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                                context.go(RouteNames.home);
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
                                // Step 2 Indicator (Inactive: #D9DADC)
                                Container(
                                  width: 24.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9DADC),
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

                      // STEP 1 OF 2
                      Text(
                        'STEP 1 OF 2',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Title: "Tell us about you"
                      Text(
                        'Tell us about you',
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF262A30),
                          height: 1.25,
                          letterSpacing: -0.4,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Subtitle: "So we can show salons and services made for you"
                      Text(
                        'So we can show salons and services made for you',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF717784),
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Single clean TextFormField matching Figma with OutlineInputBorder
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF262A30),
                        ),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Your name',
                          labelStyle: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF717784),
                          ),
                          floatingLabelStyle: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: _nameFocusNode.hasFocus
                                ? const Color(0xFF262A30)
                                : const Color(0xFF717784),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: 'Enter your name',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF262A30),
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Section Title: "I'm looking for services for"
                      Text(
                        "I'm looking for services for",
                        style: GoogleFonts.inter(
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF262A30),
                        ),
                      ),

                      SizedBox(height: 14.h),

                      // Gender Cards: Men & Women
                      Row(
                        children: [
                          // Men Card
                          Expanded(
                            child: _GenderCard(
                              title: 'Men',
                              isMale: true,
                              imagePath: AppImages.genderMen,
                              isSelected: _selectedGender == 'male',
                              onTap: () {
                                setState(() {
                                  _selectedGender = 'male';
                                });
                              },
                            ),
                          ),

                          SizedBox(width: 12.w),

                          // Women Card
                          Expanded(
                            child: _GenderCard(
                              title: 'Women',
                              isMale: false,
                              imagePath: AppImages.genderWomen,
                              isSelected: _selectedGender == 'female',
                              onTap: () {
                                setState(() {
                                  _selectedGender = 'female';
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Footnote: "You can switch anytime from Home or your profile."
                      Text(
                        'You can switch anytime from Home or your profile.',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF717784),
                        ),
                      ),

                      const Spacer(),

                      SizedBox(height: 20.h),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _isFormValid && !_isLoading ? _handleContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? const Color(0xFF262A30)
                                : const Color(0xFFC9CED6),
                            disabledBackgroundColor: const Color(0xFFC9CED6),
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
                                  'Continue',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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

class _GenderCard extends StatelessWidget {
  final String title;
  final bool isMale;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.title,
    required this.isMale,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Figma colors:
    // When selected: Men has soft blue #E6EDF3 tint, Women has soft blush or same #E6EDF3 tint.
    // When unselected: subtle soft cool gray #F4F5F7.
    final Color topBgColor = isSelected
        ? const Color(0xFFE6EDF3)
        : const Color(0xFFF4F5F7);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 200.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF262A30)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color.fromRGBO(20, 24, 30, 0.08),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Top Image container with tinted background filling upper card
            Expanded(
              child: Container(
                width: double.infinity,
                color: topBgColor,
                padding: EdgeInsets.all(12.w),
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          isMale
                              ? Icons.face_rounded
                              : Icons.face_3_rounded,
                          size: 48.w,
                          color: const Color(0xFF717784),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom row: Vector icon + Label + Selection radio
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Vector-drawn gender symbol (avoids Android emoji font overrides)
                      isMale
                          ? const _MaleIcon(
                              color: Color(0xFF262A30),
                              size: 16,
                            )
                          : _FemaleIcon(
                              color: isSelected
                                  ? const Color(0xFF262A30)
                                  : const Color(0xFF2D6FA6),
                              size: 16,
                            ),
                      SizedBox(width: 8.w),
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF262A30),
                        ),
                      ),
                    ],
                  ),

                  // Selection radio/checkmark indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF262A30)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF262A30)
                            : const Color(0xFFD1D5DB),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 14.w,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom-painted vector Male symbol (♂)
class _MaleIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _MaleIcon({
    this.color = const Color(0xFF262A30),
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _MaleIconPainter(color: color),
      ),
    );
  }
}

class _MaleIconPainter extends CustomPainter {
  final Color color;

  _MaleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Circle at bottom-left
    final circleCenter = Offset(w * 0.42, h * 0.58);
    final circleRadius = w * 0.28;
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // Diagonal arrow line towards top-right (45 degrees)
    final arrowStart = Offset(
      circleCenter.dx + circleRadius * 0.7071,
      circleCenter.dy - circleRadius * 0.7071,
    );
    final arrowEnd = Offset(w * 0.88, h * 0.12);
    canvas.drawLine(arrowStart, arrowEnd, paint);

    // Arrow heads
    final headLen = w * 0.32;
    canvas.drawLine(arrowEnd, Offset(arrowEnd.dx - headLen, arrowEnd.dy), paint);
    canvas.drawLine(arrowEnd, Offset(arrowEnd.dx, arrowEnd.dy + headLen), paint);
  }

  @override
  bool shouldRepaint(covariant _MaleIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Custom-painted vector Female symbol (♀)
class _FemaleIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _FemaleIcon({
    this.color = const Color(0xFF2D6FA6),
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _FemaleIconPainter(color: color),
      ),
    );
  }
}

class _FemaleIconPainter extends CustomPainter {
  final Color color;

  _FemaleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Circle at top-center
    final circleCenter = Offset(w * 0.5, h * 0.38);
    final circleRadius = w * 0.28;
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // Vertical stem straight down
    final stemTop = Offset(w * 0.5, circleCenter.dy + circleRadius);
    final stemBottom = Offset(w * 0.5, h * 0.92);
    canvas.drawLine(stemTop, stemBottom, paint);

    // Horizontal crossbar
    final crossY = circleCenter.dy + circleRadius + (stemBottom.dy - stemTop.dy) * 0.45;
    final armLen = w * 0.22;
    canvas.drawLine(
      Offset(w * 0.5 - armLen, crossY),
      Offset(w * 0.5 + armLen, crossY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FemaleIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
