import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/dev_info.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
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
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: ProfileAppBar(
        title: "Contact",
        centerTitle: true,
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15),
                physics: NeverScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: SvgPicture.asset(
                      AppIcons.gloUp,
                      colorFilter: ColorFilter.mode(
                        isDarkMode ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    'Mission',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.displaySmall?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'To simplify and elevate the beauty and grooming experience by providing a seamless, user-friendly platform that connects customers with trusted salons and professionals, offering convenience, transparency, and personalized services at their fingertips',
                    style: context.textTheme.displaySmall?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Vision',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.displaySmall?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'To become India’s most trusted and innovative salon booking ecosystem, redefining how people discover, book, and experience beauty and wellness, while empowering salons and professionals to grow in the digital era.',
                    style: context.textTheme.displaySmall?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 30.0),
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
