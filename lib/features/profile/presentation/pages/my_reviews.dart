import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/profile/presentation/model/review_data.dart';
import 'package:tressy/features/widgets/add_rating_dialogue.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/custom_rating_bar.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';

class MyReviews extends StatefulWidget {
  const MyReviews({super.key});

  @override
  State<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  final List<ReviewData> dummyReviews = [
    ReviewData(
      profilePic: "https://i.pravatar.cc/150?img=1",
      rating: 4.5,
      reviewDescription: "Very good store and friendly staff.",
      reviewId: 101,
      updatedAt: "2026-02-20",
      storeName: "Fresh Mart",
      district: "Central",
      city: "Chennai",
    ),
    ReviewData(
      profilePic: "https://i.pravatar.cc/150?img=2",
      rating: 3,
      reviewDescription: "Average experience. Can improve service.",
      reviewId: 102,
      updatedAt: "2026-02-18",
      storeName: "Daily Needs",
      district: "North",
      city: "Bangalore",
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ActionBar(
              title: 'My Reviews',
              isBackButtonDecoration: true,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dummyReviews.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final review = dummyReviews[index];
                  return MyReviewContainer(
                    reviewData: review,
                    deleteOnTap: () {
                      if (kDebugMode) {
                        print("Delete tapped for reviewId: ${review.reviewId}");
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyReviewContainer extends StatelessWidget {
  const MyReviewContainer({
    super.key,
    required this.reviewData,
    required this.deleteOnTap,
  });

  final ReviewData reviewData;
  final VoidCallback deleteOnTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
      padding: EdgeInsets.all(10),
      decoration: Themes.borderDecoration(radius: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 123,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomNetworkImage(
                  imageUrl: '${reviewData.storeImages?[0]}',
                  imageType: ImageType.images,
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 15),
                  title: HeaderTextBlack(
                    title: '${reviewData.storeName}',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: BodyTextHint(
                      title: '${reviewData.district}, ${reviewData.city}',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.disabledColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  height: 51,
                  width: 51,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: CustomNetworkImage(
                    imageUrl: '${reviewData.profilePic}',
                    imageType: ImageType.profilepic,
                  ),
                ),
                title: HeaderTextBlack(
                  title: 'You',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                subtitle: BodyTextHint(
                  title: formatDateTime(reviewData.updatedAt!),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: CustomPopupMenuButton(
                  items: [
                    PopupMenuItemData(
                      title: 'Edit',
                      value: '/edit',
                      onTap: () {
                        AddRatingDialogue().showAddReviewDialogue(
                          context: context,
                          reviewData: reviewData,
                          isEditReview: true,
                        );
                      },
                    ),
                    PopupMenuItemData(
                      title: 'Delete',
                      value: '/delete',
                      onTap: () {
                        CustomDialogues.showCancelDialogue(
                          context,
                          title: 'delete this review',
                          submitOnTap: () {
                            context.pop();
                            deleteOnTap();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CustomRatingBar(
                  rating: reviewData.rating?.toDouble(),
                  ignoreGestures: true,
                  onRatingUpdate: (rating) {},
                ),
              ),
              HeaderTextBlack(
                title: '${reviewData.reviewDescription}',
                fontSize: 16,
                fontWeight: FontWeight.w300,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5)
            ],
          )
        ],
      ),
    );
  }

  String formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    final formatted =
        DateFormat('EEE, d MMM, yyyy \'at\' h.mm a').format(dateTime);
    return formatted;
  }
}
