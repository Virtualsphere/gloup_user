import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/core/extensions/string_extensions.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ActionBar(
              title: 'My Profile',
              isBackButtonDecoration: true,
              isClearButton: true,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: size.width,
                        margin: EdgeInsets.only(
                            top: size.height * .12,
                            left: 15,
                            right: 15,
                            bottom: 15),
                        decoration: Themes.borderDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: () {
                                  context.pushNamed(RouteNames.editProfile);
                                },
                                child: BodyTextColors(
                                  title: 'Edit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Align(
                              alignment: Alignment.center,
                              child: HeaderTextBlack(
                                title: '',
                                fontSize: 24,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Divider(color: AppColors.borderColor),
                            ),
                            ProfileDetailText(
                              title: 'First name',
                              data: '-',
                            ),
                            SizedBox(height: 15),
                            ProfileDetailText(
                              title: 'Last name',
                              data: '-',
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ProfileDetailText(
                                  title: 'Mobile Number',
                                  data: '+91 ' '',
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            ProfileDetailText(
                              title: 'Email',
                              data: '-',
                              isEmail: true,
                            ),
                            SizedBox(height: 15),
                            ProfileDetailText(
                              title: 'Date of birth',
                              data: '-',
                            ),
                            SizedBox(height: 15),
                            ProfileDetailText(
                              title: 'Gender',
                              data: '-',
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 0,
                        right: 0,
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.loose,
                          children: [
                            Container(
                              height: 132,
                              width: 132,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: CustomNetworkImage(
                                imageUrl: '',
                                imageType: ImageType.profilepic,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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

class ProfileDetailText extends StatelessWidget {
  const ProfileDetailText({
    super.key,
    required this.title,
    required this.data,
    this.isEmail = false,
  });

  final String title, data;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderTextBlack(
            title: title.capitalize(),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          BodyTextHint(
            title: isEmail ? data.toLowerCase() : data.capitalize(),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          )
        ],
      ),
    );
  }
}
