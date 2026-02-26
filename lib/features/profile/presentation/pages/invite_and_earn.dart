import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_text_field.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';

class InviteAndEarn extends StatefulWidget {
  const InviteAndEarn({super.key});

  @override
  State<InviteAndEarn> createState() => _InviteAndEarnState();
}

class _InviteAndEarnState extends State<InviteAndEarn> {
  late TextEditingController referralCodeController;
  final GlobalKey<FormState> referralFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    referralCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProfileAppBar(
          title: "Invite & Earn",
          centerTitle: false,
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(15),
                children: [
                  SvgPicture.asset(AppIcons.inviteAndEarn),
                  SizedBox(
                    height: 10.0,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Invite your friends and both of you get exclusive salon discounts up to ',
                          style: GoogleFonts.bodoniModa(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.rupeeNormal,
                                height: 16,
                                width: 16,
                                colorFilter: ColorFilter.mode(
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              HeaderTextBlack(
                                title: '199! ',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                isBodoniModa: true,
                              ),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: ' Because good hair days are better together.',
                          style: GoogleFonts.bodoniModa(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  HeaderTextBlack(
                    title: 'Share your code',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: DottedBorderContainer(
                      borderColor: AppColors.black,
                      child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 5),
                        child: Row(
                          children: [
                            HeaderTextBlack(
                              title: 'referralCode',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: 'referralCode',
                                  ),
                                );
                              },
                              icon: SvgPicture.asset(
                                AppIcons.copy,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.white,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Form(
                      key: referralFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderTextBlack(
                            title: 'Enter your friend’s referral code below',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          SizedBox(height: 20),
                          CustomTextField(
                            controller: referralCodeController,
                            hintText: 'e.g. SALON123',
                            inputType: TextInputType.text,
                            inputAction: TextInputAction.done,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter referral code';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          CustomOutlineButton(
                            title: 'Apply & Claim',
                            onTap: () async {
                              if (referralFormKey.currentState!.validate()) {}
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: CustomFullButton(
                title: 'Invite Friends',
                onTap: () {
                  Share.share('Welcome to GloUp Salon!!');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final double dashLength;
  final double dashSpace;
  final Color borderColor;
  final BorderRadius borderRadius;

  const DottedBorderContainer({
    super.key,
    required this.child,
    this.dashLength = 4,
    this.dashSpace = 2,
    this.borderColor = AppColors.textDisabled,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(
        dashLength: dashLength,
        dashSpace: dashSpace,
        borderColor: borderColor,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final double dashLength;
  final double dashSpace;
  final Color borderColor;
  final BorderRadius borderRadius;

  DottedBorderPainter({
    required this.dashLength,
    required this.dashSpace,
    required this.borderColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final outerRect = Offset.zero & size;
    final rrect = borderRadius.toRRect(outerRect);
    final path = Path()..addRRect(rrect);

    final dashPath = _createDashedPath(path, dashLength, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double dashSpace) {
    final Path dashedPath = Path();
    double distance = 0.0;

    for (final PathMetric metric in source.computeMetrics()) {
      while (distance < metric.length) {
        final double end = distance + dashLength;
        dashedPath.addPath(
          metric.extractPath(distance, end.clamp(0.0, metric.length)),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
