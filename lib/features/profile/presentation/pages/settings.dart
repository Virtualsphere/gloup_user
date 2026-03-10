import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/features/auth/presentation/pages/login_page.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_bloc.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_event.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_state.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/add_person_bottom_sheet.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/shared/widgets/edit_person_bottom_sheet.dart';
import 'package:tressy/features/profile/presentation/pages/support.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';

class Settings extends StatelessWidget {
  final ProfileEntity profile;

  const Settings({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GuestBloc>()..add(const LoadGuestsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<ProfileBloc>(),
        ),
      ],
      child: SettingsView(profile: profile),
    );
  }
}

class SettingsView extends StatefulWidget {
  final ProfileEntity profile;

  const SettingsView({super.key, required this.profile});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        /// SHOW LOADER
        if (state is ProfileDeleting) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        /// DELETE SUCCESS
        if (state is ProfileDeleted) {
          Navigator.pop(context); // close loader

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );

          /// Navigate to login and remove all previous screens
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginPage(),
            ),
            (route) => false,
          );
        }

        /// ERROR
        if (state is ProfileFailure) {
          Navigator.pop(context); // close loader

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
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
                name: widget.profile.fullName,
                gender: widget.profile.gender,
                imageUrl: widget.profile.fullProfilePicUrl,
                age: widget.profile.age,
                phone: "${widget.profile.phone}",
                profileImage: true,
              ),
              SizedBox(
                height: AppSizes.paddingM,
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: context.colorScheme.surface,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                        context.read<ProfileBloc>().add(
                              const DeleteProfileEvent(),
                            );
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
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface,
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
                              color: isDarkMode
                                  ? AppColors.black
                                  : AppColors.white,
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
                child: BlocBuilder<GuestBloc, GuestState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.errorMessage != null) {
                      return Center(
                        child: Text(state.errorMessage!),
                      );
                    }

                    final guests = state.guests;

                    if (guests.isEmpty) {
                      return const Center(
                        child: Text("No guests added"),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: guests.length,
                      itemBuilder: (context, index) {
                        final guest = guests[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ProfileDeleteCard(
                            name: guest.name,
                            gender: guest.gender,
                            imageUrl: "",
                            age: guest.age,
                            phone: guest.phone,
                            showMenuButton: true,
                            onEdit: () {
                              if (guest.guestId == null) return;

                              showEditPersonBottomSheet(
                                context,
                                initialName: guest.name,
                                initialAge: guest.age,
                                initialGender: guest.gender,
                                initialPhone: guest.phone,
                                onSave: (result) {
                                  context.read<GuestBloc>().add(
                                        UpdateGuestEvent(
                                          guestId: guest.guestId!,
                                          name: result.fullName,
                                          gender: result.gender,
                                          age: result.age,
                                          phone: result.phone,
                                        ),
                                      );

                                  CustomToast.showInfo(
                                    context,
                                    'Updating ${result.fullName}...',
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
  final int age;
  final String phone;
  final bool profileImage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProfileDeleteCard({
    super.key,
    required this.name,
    required this.gender,
    this.imageUrl,
    required this.age,
    required this.phone,
    this.showMenuButton = false,
    this.profileImage = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
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
              if (profileImage == true) ...[
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
                            imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_outlined,
                                color: AppColors.border,
                                size: 28.0,
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(width: 15),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontSize: AppSizes.font,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          gender.toLowerCase() == 'male'
                              ? Icons.male
                              : gender.toLowerCase() == 'female'
                                  ? Icons.female
                                  : Icons.wc,
                          size: 18,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            gender,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurface,
                              fontSize: AppSizes.font,
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
                        if (onEdit != null) {
                          onEdit!();
                        }
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
                            /*if (onDelete != null) {
                              onDelete!();
                            }*/
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
