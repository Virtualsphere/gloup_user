import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/core/extensions/string_extensions.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ActionBar(
                title: 'Support',
                isBackButtonDecoration: true,
              ),
              Container(
                padding: EdgeInsets.only(left: 16.0,top: 10.0,bottom: 10.0),
                decoration: Themes.borderDecoration(),
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    ProfileListTile(
                      title: 'Privacy Policy',
                      icon: AppImages.privacyPolicy,
                      onTap: () {
                        context.pushNamed(RouteNames.privacyPolicy);
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade100,
                      indent: 56,
                    ),
                    ProfileListTile(
                      title: 'Terms of Use',
                      icon: AppImages.termsCondition,
                      onTap: () {
                        context.pushNamed(RouteNames.termsConditions);
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade100,
                      indent: 56,
                    ),
                    ProfileListTile(
                      title: 'Cancellation',
                      icon: AppImages.cancellation,
                      onTap: () {
                        context.pushNamed(RouteNames.cancellation);
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade100,
                      indent: 56,
                    ),
                    ProfileListTile(
                      title: 'Contact',
                      icon: AppImages.call,
                      onTap: () {
                        context.pushNamed(RouteNames.contact);
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade100,
                      indent: 56,
                    ),
                    ProfileListTile(
                      title: 'FAQs',
                      icon: AppImages.faq,
                      onTap: () {
                        context.pushNamed(RouteNames.faqs);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title, icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(vertical: -2),
      leading: SvgPicture.asset(
        icon,
        height: 24,
        width: 24,
      ),
      title: HeaderTextBlack(
        title: title.capitalize(),
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
