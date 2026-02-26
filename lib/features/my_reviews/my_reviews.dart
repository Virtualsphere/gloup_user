import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/profile/presentation/model/review_data.dart';
import 'package:tressy/features/widgets/add_rating_dialogue.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/custom_rating_bar.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProfileAppBar(
          title: "My Reviews",
          centerTitle: false,
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.paddingL),
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
    List<String> services = [
      "Hair Cut",
      "Facial",
      "Makeup",
      "Spa",
      "Beard Trim",
    ];
    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
      padding: EdgeInsets.all(10),
      decoration: Themes.borderDecoration(radius: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
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
              CustomPopupMenuButton(
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SizedBox(
              height: 2.0,
              child: Divider(
                color: AppColors.disabledColor,
                thickness: 1.5,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15.0,
              ),
              SizedBox(
                height: 30.0, // reduce overall height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return buildServiceChip(services[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Completed on 23/02/2026',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppIcons.rupeeNormal,
                          height: 14.0,
                          width: 14.0,
                          colorFilter: ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        const Text(
                          '1000',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  height: 2.0,
                  child: Divider(
                    color: AppColors.disabledColor,
                    thickness: 1.5,
                  ),
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: AppColors.borderColor,
                  border: Border.all(color: AppColors.borderColor)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${reviewData.reviewDescription}',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){showInputDialog(context, reviewData.reviewDescription);},
                        child: SvgPicture.asset(AppIcons.edit,color: AppColors.black,),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
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

  //service chip:-
  Widget buildServiceChip(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 12, // smaller text
            height: 1,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        // reduces internal padding
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        backgroundColor: AppColors.circleGreyColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: AppColors.circleGreyColor,
          ),
        ),
      ),
    );
  }

  //view comment pop up window:-
  void showInputDialog(BuildContext context, String? reviewDescription) {
    TextEditingController controller =
        TextEditingController(text: reviewDescription);

    showDialog(
      context: context,
      builder: (context) {
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
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeaderTextBlack(
                        title: 'View Comments',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.clear,
                          size: 23.0,
                          color: AppColors.black,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                    child: TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Type here...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                    child: CustomFullButton(
                      title: 'Save',
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
