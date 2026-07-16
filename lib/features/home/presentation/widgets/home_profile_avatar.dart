import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class HomeProfileAvatar extends StatelessWidget {
  const HomeProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profilePicUrl = switch (state) {
          ProfileLoaded(:final profile) => profile.fullProfilePicUrl,
          ProfileUpdating(:final profile) => profile.fullProfilePicUrl,
          ProfileUpdateSuccess(:final profile) => profile.fullProfilePicUrl,
          ProfileUpdateFailure(:final profile) => profile.fullProfilePicUrl,
          _ => '',
        };

        final showPhoto =
            LocalStorageService.isLoggedIn && profilePicUrl.isNotEmpty;

        return InkWell(
          onTap: () => context.pushNamed(RouteNames.personalProfile),
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
          child: Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppColors.backgroundDark : AppColors.background,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: showPhoto
                ? CustomNetworkImage(
                    imageUrl: profilePicUrl,
                    imageType: ImageType.profilepic,
                  )
                : Center(
                    child: Icon(
                      Icons.person,
                      color: isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      size: AppSizes.iconS,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
