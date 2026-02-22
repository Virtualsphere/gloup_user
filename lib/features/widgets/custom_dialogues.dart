import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/widgets/custom_button.dart';

class CustomDialogues {
  static Future<dynamic> showCancelDialogue(
      BuildContext context, {
        required String title,
        required VoidCallback submitOnTap,
      }) async {
    return showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: HeaderTextBlack(
              title: 'Are You Sure want to $title',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            actions: [
              CupertinoButton(
                child: HeaderTextBlack(
                  title: 'Not Now',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                onPressed: submitOnTap,
                child: BodyTextColors(
                  title: 'Submit',
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        } else {
          return Dialog(
            backgroundColor: AppColors.scaffoldBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .9,
              ),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HeaderTextBlack(
                      title: 'Are You Sure want to $title',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.borderColor),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 56,
                              decoration: Themes.borderDecoration(),
                              child: Center(
                                child: HeaderTextBlack(
                                  title: 'Not Now',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: CustomFullButton(
                            title: 'Submit',
                            onTap: submitOnTap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  static Future<dynamic> showNotAllowedCancelDialogue(
      BuildContext context, {
        String title = 'Cancel Booking',
      }) async {
    return showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            content: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SvgPicture.asset(AppIcons.cancelNotAllowed),
                    HeaderTextBlack(
                      title: 'Cancellation not allowed',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: BodyTextColors(
                        title:
                        'Bookings can only be canceled up to 8 hours before the scheduled time.',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: AppColors.circleGreyColor,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Dialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SvgPicture.asset(AppIcons.cancelNotAllowed),
                    HeaderTextBlack(
                      title: 'Cancellation not allowed',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: BodyTextColors(
                        title:
                        'Bookings can only be canceled up to 8 hours before the scheduled time.',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: AppColors.circleGreyColor,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  static Future<void> showLoadingDialogue(BuildContext context) async {
    return showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            content: CupertinoActivityIndicator(
              radius: 15,
              color: AppColors.primary,
            ),
          );
        } else {
          return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ButtonProgressBar(),
            ),
          );
        }
      },
    );
  }

  static Future<dynamic> showLocationPermissionDialogue(
      BuildContext context, {
        required VoidCallback onOpenSettings,
      }) async {
    return showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: HeaderTextBlack(
              title: 'Location Permission Required',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: BodyTextColors(
                title:
                'To find nearby salons and provide personalized recommendations, please enable location access in Settings.',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.circleGreyColor,
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              CupertinoButton(
                child: HeaderTextBlack(
                  title: 'Cancel',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                  onOpenSettings();
                },
                child: BodyTextColors(
                  title: 'Open Settings',
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        } else {
          return Dialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .9,
              ),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeaderTextBlack(
                      title: 'Location Permission Required',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 15),
                    BodyTextColors(
                      title:
                      'To find nearby salons and provide personalized recommendations, please enable location access in Settings.',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.circleGreyColor,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.borderColor),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 56,
                              decoration: Themes.borderDecoration(),
                              child: Center(
                                child: HeaderTextBlack(
                                  title: 'Cancel',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: CustomFullButton(
                            title: 'Open Settings',
                            onTap: () {
                              Navigator.pop(context);
                              onOpenSettings();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
