import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/profile/presentation/model/review_data.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_rating_bar.dart';
import 'package:tressy/features/widgets/custom_text_field.dart';

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
                    HeaderTextBlack(
                      title: 'Your Opinion Matter To Us!',
                      fontSize: 20,
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
                backgroundColor: AppColors.background,
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
                      HeaderTextBlack(
                        title: 'Your Opinion Matter To Us!',
                        fontSize: 20,
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
                              borderRadius: 15,
                              onTap: () async {
                                /*final profileController =
                                context.read<ProfileController>();
                                CustomDialogues.showLoadingDialogue(context);
                                if (isEditReview) {
                                  await profileController.updateReview(
                                    reviewId: reviewData.reviewId!,
                                    rating: reviewRating,
                                    description: reviewController.text.trim(),
                                  );
                                } else {
                                  await profileController.addReview(
                                    storeId: reviewData.storeId!,
                                    rating: reviewRating,
                                    description: reviewController.text.trim(),
                                  );
                                }
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                final response =
                                    profileController.getApiResponse;
                                if (response.status == Status.COMPLETED) {
                                  context.pop();
                                  CustomToast.show(
                                    context,
                                    title: '${response.data}',
                                  );
                                  await profileController.getAllReview();
                                } else {
                                  CustomToast.show(
                                    context,
                                    title: '${response.message}',
                                  );
                                }*/
                              },
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