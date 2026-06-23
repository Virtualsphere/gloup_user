import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/dev_info.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/legal_content_widgets.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      appBar: ProfileAppBar(
        title: 'Contact',
        centerTitle: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            const SizedBox(height: 20),
            Center(
              child: SvgPicture.asset(
                AppIcons.gloUp,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Mission',
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'To simplify and elevate the beauty and grooming experience by providing a seamless, '
              'user-friendly platform that connects customers with trusted salons and professionals, '
              'offering convenience, transparency, and personalized services at their fingertips.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Vision',
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'To become India\'s most trusted and innovative salon booking ecosystem, redefining '
              'how people discover, book, and experience beauty and wellness, while empowering '
              'salons and professionals to grow in the digital era.',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const LegalDocumentDivider(),
            const LegalBodyText(
              'JR STYLE\'O BOOKING AND FASHION PVT LTD',
              fontWeight: FontWeight.w500,
            ),
            const LegalBodyText(
              'No. 54, Chola Avenue, SNM Green City, Villar Road, Thanjavur',
            ),
            const LegalDualContactEmailText(
              prefix: 'Email: ',
              emails: ['booking@gloup.in', 'contact@gloup.in'],
            ),
            const LegalContactPhoneText(
              prefix: 'Phone: ',
              phone: '+91 75388 08796',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleContainer(
                  icon: AppIcons.website,
                  containerHeight: 48,
                  iconHeight: 24,
                  onTap: () => _launchURL('https://gloup.in/'),
                ),
                CircleContainer(
                  icon: AppIcons.call,
                  containerHeight: 48,
                  iconHeight: 24,
                  onTap: () => _launchURL('tel:+917538808796'),
                ),
                CircleContainer(
                  icon: AppIcons.mail,
                  containerHeight: 48,
                  iconHeight: 24,
                  onTap: () => _launchURL('mailto:contact@gloup.in'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
