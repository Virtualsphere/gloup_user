import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/add_person_bottom_sheet.dart';
import 'package:tressy/shared/widgets/edit_person_bottom_sheet.dart';
import 'package:tressy/features/profile/presentation/pages/support.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Scaffold(
      // backgroundColor: context.colorScheme.surface,
      appBar: ProfileAppBar(
        title: "Settings",
        centerTitle: false,
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.paddingM),
            ProfileDeleteCard(
              name: "John Doe",
              gender: "Female",
              imageUrl: "https://i.pravatar.cc/300",
            ),
            SizedBox(
              height: AppSizes.paddingM,
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : AppColors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: context.colorScheme.surface,
                ),
              ),
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
                      Navigator.of(context).pop();
                      // await deleteUser();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: AppSizes.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Guest User',
                    style: context.textTheme.displaySmall?.copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showAddPersonBottomSheet(context);
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.white : AppColors.black,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color:
                                isDarkMode ? AppColors.black : AppColors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: isDarkMode
                                  ? AppColors.black
                                  : AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: AppSizes.fontM,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.padding),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ProfileDeleteCard(
                      name: "John Doe",
                      gender: "Female",
                      imageUrl: "https://i.pravatar.cc/300",
                      showMenuButton: true,
                    ),
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
  final String? imageUrl;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;

  const ProfileDeleteCard({
    super.key,
    required this.name,
    required this.gender,
    this.imageUrl,
    this.showMenuButton = false,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : AppColors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: context.colorScheme.surface,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 65,
                height: 65,
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
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.displaySmall?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontSize: AppSizes.font,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.wc,
                          size: 18,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            gender,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.displaySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                              fontSize: AppSizes.font,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showMenuButton == true)
                CustomPopupMenuButton(
                  iconColor: isDarkMode ? AppColors.white : AppColors.black,
                  items: [
                    PopupMenuItemData(
                      title: 'Edit',
                      value: '/edit',
                      onTap: () {
                        showEditPersonBottomSheet(
                          context,
                          initialName: 'John Doe',
                          initialAge: 28,
                          initialGender: 'Male',
                          initialPhone: null,
                          onSave: (result) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Profile updated: ${result.fullName}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    PopupMenuItemData(
                      title: 'Delete',
                      value: '/delete',
                      onTap: () {
                        CustomDialogues.showCancelDialogue(
                          context,
                          title: 'delete this guest user?',
                          submitOnTap: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
          )
        ],
      ),
    );
  }
}
