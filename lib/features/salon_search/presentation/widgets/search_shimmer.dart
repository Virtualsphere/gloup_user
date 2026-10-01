import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/home/presentation/widgets/home_shimmers.dart';

class SearchShimmer extends StatelessWidget {
  final bool isDarkMode;

  const SearchShimmer({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: 16,
        left: AppSizes.paddingM,
        right: AppSizes.paddingM,
        bottom: 16,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSizes.paddingM),
          child: HomeShimmers.buildVerticalSalonCardShimmer(context),
        );
      },
    );
  }
}

