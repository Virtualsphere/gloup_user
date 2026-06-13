import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/extensions/string_extensions.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: ProfileAppBar(
        title: "Support",
        centerTitle: false,
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizes.paddingL),
              Container(
                padding: EdgeInsets.only(left: 16.0, top: 10.0, bottom: 10.0),
                decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.black : AppColors.white,
                    borderRadius: BorderRadius.circular(10.0)),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(vertical: -2),
      tileColor: isDarkMode ? Colors.grey.shade900 : AppColors.white,
      leading: SvgPicture.asset(
        icon,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          isDarkMode ? AppColors.white : AppColors.black,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title.capitalize(),
        style: context.textTheme.bodySmall?.copyWith(
          color: isDarkMode ? AppColors.white : AppColors.black,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
