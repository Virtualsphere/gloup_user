import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';
import 'package:url_launcher/url_launcher.dart';

class DevInfo extends StatefulWidget {
  const DevInfo({super.key});

  @override
  State<DevInfo> createState() => _DevInfoState();
}

class _DevInfoState extends State<DevInfo> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ActionBar(
              title: 'Developer Info',
              isBackButtonDecoration: true,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(15),
                children: [
                  Stack(
                    fit: StackFit.passthrough,
                    children: [
                      CircleBorderContainer(
                        height: 296,
                        child: CircleBorderContainer(
                          height: 218,
                          child: CircleBorderContainer(
                            height: 138,
                            child: SvgPicture.network(
                                'https://ik.imagekit.io/bfzb9z4tav/assets/Nutz_R_c7vy0Z41x.svg?updatedAt=1626781279459'),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: size.width * .08,
                        top: 0,
                        child: CircleContainer(
                          icon: AppIcons.bfButton,
                          containerHeight: 25,
                          iconHeight: 14,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: size.width * .08,
                        top: 0,
                        child: CircleContainer(
                          icon: AppIcons.system,
                          containerHeight: 25,
                          iconHeight: 14,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 30,
                        child: CircleContainer(
                          icon: AppIcons.pen,
                          containerHeight: 25,
                          iconHeight: 14,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppColors.disabledColor),
                  ),
                  HeaderTextBlack(
                    title: 'About Us',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title:
                        'We deliver premium IT services using the latest technologies at affordable rates. Whether you\'re starting from scratch or scaling an existing business, we\'re here to help—calm, committed, and always ready to support you.',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.locationFill,
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 10),
                      HeaderTextBlack(
                        title: 'Erode, Tamil Nadu, India',
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      CircleContainer(
                        icon: AppIcons.linedIn,
                        containerHeight: 48,
                        iconHeight: 24,
                        onTap: () {
                          launchURL('https://in.linkedin.com/company/nutz');
                        },
                      ),
                      SizedBox(width: 15),
                      CircleContainer(
                        icon: AppIcons.website,
                        containerHeight: 48,
                        iconHeight: 24,
                        onTap: () {
                          launchURL('https://nutz.in/');
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}

class CircleBorderContainer extends StatelessWidget {
  const CircleBorderContainer({super.key, required this.height, this.child});

  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: AppColors.disabledColor,
          width: 1,
        ),
        shape: BoxShape.circle,
      ),
      child: child != null
          ? Center(
              child: child,
            )
          : SizedBox(),
    );
  }
}

class CircleContainer extends StatelessWidget {
  const CircleContainer({
    super.key,
    required this.icon,
    required this.containerHeight,
    required this.iconHeight,
    this.onTap,
  });

  final String icon;
  final double containerHeight, iconHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: containerHeight,
        width: containerHeight,
        decoration: BoxDecoration(
          color: AppColors.circleGreyColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            height: iconHeight,
            width: iconHeight,
          ),
        ),
      ),
    );
  }
}
