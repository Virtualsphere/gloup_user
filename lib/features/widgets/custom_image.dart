import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    required this.imageType,
    this.placeHolderHeight = 36,
  });

  final String imageUrl;
  final ImageType imageType;
  final double placeHolderHeight;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: apiImageUrl(
        imageType: imageType,
        imageUrl: imageUrl,
      ),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                AppIcons.placeHolderBg,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppIcons.placeGallery,
              width: placeHolderHeight,
              height: placeHolderHeight,
              colorFilter: ColorFilter.mode(
                  isDarkMode ? AppColors.primaryDark : AppColors.primaryDark,
                  BlendMode.modulate),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                AppIcons.placeHolderBg,
              ),
              fit: BoxFit.cover,
            ),
            color: isDarkMode
                ? AppColors.primaryDark.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppIcons.placeGallery,
              width: placeHolderHeight,
              height: placeHolderHeight,
              colorFilter: ColorFilter.mode(
                  isDarkMode
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.primaryDark.withValues(alpha: 0.9),
                  BlendMode.modulate),
            ),
          ),
        );
      },
    );
  }

  String apiImageUrl({
    required ImageType imageType,
    required String imageUrl,
  }) {
    switch (imageType) {
      case ImageType.images:
        return '${ApiRoutes.baseUrl}/${Keys.images}/$imageUrl';
      case ImageType.profilepic:
        return '${ApiRoutes.baseUrl}/${Keys.profilePic}/$imageUrl';
      case ImageType.documents:
        return '${ApiRoutes.baseUrl}/${Keys.documents}/$imageUrl';
      case ImageType.notype:
        return imageUrl;
    }
  }
}

class CustomImageCropper {
  static Future<CroppedFile?> cropImage(String imagePath,
      {bool isProfile = false}) async {
    try {
      return await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'GloUp',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: AppColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            cropStyle: isProfile ? CropStyle.circle : CropStyle.rectangle,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
          )
        ],
      );
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }
}

class CustomImagePicker {
  static Future<void> showImagePicker(
    BuildContext context, {
    required VoidCallback cameraOnTap,
    required VoidCallback galleryOnTap,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: Themes.primaryBoxDecorationPurple,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        visualDensity: VisualDensity(vertical: -2),
                        leading: SvgPicture.asset(
                          AppIcons.camera,
                          colorFilter: ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: HeaderTextBlack(
                          title: 'Take Picture',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          isBodoniModa: false,
                        ),
                        onTap: cameraOnTap,
                      ),
                      ListTile(
                        visualDensity: VisualDensity(vertical: -2),
                        leading: SvgPicture.asset(
                          AppIcons.gallery,
                          colorFilter: ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: HeaderTextBlack(
                          title: 'Choose Photo',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          isBodoniModa: false,
                        ),
                        onTap: galleryOnTap,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
