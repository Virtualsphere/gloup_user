import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/dev_info.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/legal_content_widgets.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactBottomSheet extends StatelessWidget {
  const ContactBottomSheet({super.key});

  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw Exception('Could not launch $uri');
    }
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ContactBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.surfaceDark : AppColors.white;

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 32),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          
          SvgPicture.asset(
            AppIcons.gloUp,
            colorFilter: ColorFilter.mode(
              isDarkMode ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),

          const LegalBodyText(
            'JR STYLE\'O BOOKING AND FASHION PVT LTD',
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          const LegalBodyText(
            'No. 54, Chola Avenue, SNM Green City,\nVillar Road, Thanjavur',
          ),
          const SizedBox(height: 16),
          const LegalDualContactEmailText(
            prefix: 'Email: ',
            emails: ['booking@gloup.in', 'contact@gloup.in'],
          ),
          const SizedBox(height: 4),
          const LegalContactPhoneText(
            prefix: 'Phone: ',
            phone: '+91 75388 08796',
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleContainer(
                icon: AppIcons.website,
                containerHeight: 52,
                iconHeight: 24,
                onTap: () => _launchURL('https://gloup.in/'),
              ),
              CircleContainer(
                icon: AppIcons.call,
                containerHeight: 52,
                iconHeight: 24,
                onTap: () => _launchURL('tel:+917538808796'),
              ),
              CircleContainer(
                icon: AppIcons.mail,
                containerHeight: 52,
                iconHeight: 24,
                onTap: () => _launchURL('mailto:contact@gloup.in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
