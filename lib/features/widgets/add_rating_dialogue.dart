import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/features/profile/presentation/model/review_data.dart';
import 'package:tressy/features/widgets/custom_rating_bar.dart';
import 'package:tressy/features/widgets/custom_text_field.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/primary_button.dart';

class AddRatingDialogue {
  late TextEditingController reviewController;
  double reviewRating = 1.0;

  Future<dynamic> showAddReviewDialogue({
    required BuildContext context,
    required ReviewData reviewData,
    required bool isEditReview,
  }) async {
    reviewController =
        TextEditingController(text: reviewData.reviewDescription);
    reviewRating = reviewData.rating.toDouble();
    Size size = MediaQuery.of(context).size;
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (Platform.isIOS) {
              return CupertinoAlertDialog(
                insetAnimationCurve: Curves.decelerate,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your Opinion Matter To Us!',
                      style: context.textTheme.displaySmall?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.borderColor),
                    ),
                    BodyTextHint(
                      title: 'How’s our Service?',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    SizedBox(height: 20),
                    CustomRatingBar(
                      rating: reviewRating,
                      iconSize: 34,
                      ignoreGestures: false,
                      isGradient: false,
                      onRatingUpdate: (value) {
                        if (context.mounted) {
                          setState(() => reviewRating = value);
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    CupertinoTextField(
                      controller: reviewController,
                      placeholder: 'Write Something....',
                      style: AppTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ).textStyle,
                      placeholderStyle: AppTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondary,
                      ).textStyle,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.borderColor,
                        ),
                      ),
                      maxLines: 5,
                    ),
                  ],
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
                    onPressed: () {},
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
                backgroundColor: context.colorScheme.surface,
                insetPadding: EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Your Opinion Matter To Us!',
                        style: context.textTheme.displaySmall?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontSize: 20.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: isDarkMode ? AppColors.white : AppColors.borderColor,thickness: 1.0,),
                      ),
                      Text(
                        'How’s our Service?',
                        style: context.textTheme.displaySmall?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomRatingBar(
                        rating: reviewRating,
                        iconSize: 34,
                        ignoreGestures: false,
                        isGradient: false,
                        onRatingUpdate: (value) {
                          if (context.mounted) {
                            setState(() => reviewRating = value);
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: reviewController,
                        hintText: 'Write Something....',
                        maxLines: 5,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 56,
                                width: size.width / 2.6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                    color: isDarkMode ? AppColors.borderColor : AppColors.white,
                                  border: Border.all(color: isDarkMode ? AppColors.borderColor : AppColors.borderColor, width: 1.0)
                                ),
                                child: Center(
                                  child: Text(
                                    'Not Now',
                                    style: context.textTheme.displaySmall?.copyWith(
                                      color: AppColors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: PrimaryButton(
                              text: 'Submit',
                              isLoading: false,
                              onPressed: (){},
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}