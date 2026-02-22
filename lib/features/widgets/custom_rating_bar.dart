import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tressy/core/constants/app_colors.dart';

class CustomRatingBar extends StatelessWidget {
  const CustomRatingBar({
    super.key,
    this.rating,
    this.ignoreGestures = false,
    required this.onRatingUpdate,
    this.iconSize = 24,
    this.isGradient = true,
  });

  final dynamic rating;
  final bool ignoreGestures;
  final Function(double) onRatingUpdate;
  final double iconSize;
  final bool isGradient;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      itemCount: 5,
      initialRating: rating ?? 0.0,
      direction: Axis.horizontal,
      maxRating: 1,
      itemSize: iconSize,
      ignoreGestures: ignoreGestures,
      allowHalfRating: false,
      itemPadding: EdgeInsets.only(right: 10),
      ratingWidget: RatingWidget(
        full: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                if (!isGradient)
                  AppColors.ratingYellowDark
                else
                  AppColors.ratingYellowLight,
                AppColors.ratingYellowDark,
              ],
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.star,
            color: Colors.white,
          ),
        ),
        half: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                if (!isGradient)
                  AppColors.ratingYellowDark
                else
                  AppColors.ratingYellowLight,
                AppColors.ratingYellowDark,
              ],
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.star_half,
            color: Colors.white,
          ),
        ),
        empty: const Icon(
          Icons.star,
          color: AppColors.borderColor,
        ),
      ),
      onRatingUpdate: onRatingUpdate,
    );
  }
}
