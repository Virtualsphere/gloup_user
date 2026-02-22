import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/dev_info.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  Future<void> launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ActionBar(title: 'Contact', isBackButtonDecoration: true),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15),
                physics: NeverScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: SvgPicture.asset(
                      AppIcons.gloUp,
                    ),
                  ),
                  SizedBox(height: 40),
                  HeaderTextBlack(
                    title: 'Mission',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title:
                    'To simplify and elevate the beauty and grooming experience by providing a seamless, user-friendly platform that connects customers with trusted salons and professionals, offering convenience, transparency, and personalized services at their fingertips',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  SizedBox(height: 15),
                  HeaderTextBlack(
                    title: 'Vision',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 10),
                  BodyTextHint(
                    title:
                    'To become India’s most trusted and innovative salon booking ecosystem, redefining how people discover, book, and experience beauty and wellness, while empowering salons and professionals to grow in the digital era.',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleContainer(
                        icon: AppIcons.website,
                        containerHeight: 48,
                        iconHeight: 24,
                        onTap: () async {
                          await launchURL("https://gloup.in/");
                        },
                      ),
                      CircleContainer(
                        icon: AppIcons.call,
                        containerHeight: 48,
                        iconHeight: 24,
                        onTap: () async {
                          await launchURL("tel:+91 80 6217 9224'");
                        },
                      ),
                      CircleContainer(
                        icon: AppIcons.mail,
                        containerHeight: 48,
                        iconHeight: 24,
                        onTap: () async {
                          await launchURL("mailto:contact@gloup.in");
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
