import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/profile/presentation/pages/support.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ActionBar(
              title: 'Settings',
              isBackButtonDecoration: true,
            ),
            ProfileDeleteCard(
              name: "John Doe",
              gender: "Female",
              imageUrl: "https://i.pravatar.cc/300",
              onDeleteTap: () {
                if (kDebugMode) {
                  print("Delete account");
                }
              },
            ),
            SizedBox(
              height: AppSizes.paddingM,
            ),
            Container(
              decoration: Themes.borderDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: ProfileListTile(
                title: 'Delete Account',
                icon: AppIcons.delete,
                onTap: () {
                  CustomDialogues.showCancelDialogue(
                    context,
                    title: 'Delete Account',
                    submitOnTap: () async {
                      context.pop();
                      // await deleteUser();
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
class ProfileDeleteCard extends StatelessWidget {
  final String name;
  final String gender;
  final VoidCallback onDeleteTap;
  final String? imageUrl;

  const ProfileDeleteCard({
    super.key,
    required this.name,
    required this.gender,
    required this.onDeleteTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: Themes.borderDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: imageUrl == null || imageUrl!.isEmpty
                    ? const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                  size: 28,
                )
                    : ClipOval(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Name & Gender
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    gender,
                    style: const TextStyle(
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingM),

          SizedBox(
            height: 50,
            width: double.infinity,
            child: CustomFullButton(
              title: 'Delete Account',
              onTap: onDeleteTap,
            ),
          ),
        ],
      ),
    );
  }
}
