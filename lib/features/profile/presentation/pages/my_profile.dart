import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_state.dart';
import 'package:tressy/features/widgets/custom_drop_downs.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/features/widgets/profile_text_field.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  final ValueNotifier<File?> profileImageNotifier = ValueNotifier(null);

  String _selectedGender = 'Not Selected';

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    dateOfBirthController.dispose();
    countryController.dispose();
    profileImageNotifier.dispose();
    super.dispose();
  }


  void _fillFields(ProfileEntity profile) {
    firstNameController.text = profile.firstname.isNotEmpty ? profile.firstname : '';
    lastNameController.text = profile.lastname.isNotEmpty ? profile.lastname : '';
    emailController.text = profile.email.isNotEmpty ? profile.email : '';

    mobileController.text = profile.phone != 0 ? profile.phone.toString() : '';

    if (profile.dateOfBirth.isNotEmpty) {
      try {
        final rawDate = profile.dateOfBirth.replaceAll('-', '/');
        dateOfBirthController.text = rawDate;
      } catch (_) {
        dateOfBirthController.text = profile.dateOfBirth;
      }
    } else {
      dateOfBirthController.text = '';
    }

    countryController.text = profile.country.isNotEmpty ? profile.country : '';


    if (profile.gender.isNotEmpty) {
      final capitalised =
          profile.gender[0].toUpperCase() + profile.gender.substring(1).toLowerCase();
      const validGenders = ['Male', 'Female'];
      setState(() {
        _selectedGender = validGenders.contains(capitalised) ? capitalised : 'Not Selected';
      });
    } else {
      setState(() => _selectedGender = 'Not Selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success && state.profile != null) {
          _fillFields(state.profile!);
        }
      },
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
          appBar: ProfileAppBar(
            title: "Your Profile",
            centerTitle: false,
            onBack: () => Navigator.of(context).pop(),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Stack(
                      children: [
                        // ── Form Container ──────────────────────────
                        Container(
                          width: size.width,
                          margin: EdgeInsets.only(
                            top: size.height * .12,
                            left: 15,
                            right: 15,
                            bottom: 15,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 90.0),

                              // First Name
                              ProfileTextField(
                                labelText: "First Name",
                                controller: firstNameController,
                                inputType: TextInputType.name,
                                inputAction: TextInputAction.next,
                                showClear: true,
                                onChanged: (value) =>
                                    context.read<ProfileBloc>().updateFirstName(value),
                              ),
                              const SizedBox(height: 20.0),

                              // Last Name
                              ProfileTextField(
                                labelText: "Last Name",
                                controller: lastNameController,
                                inputType: TextInputType.name,
                                inputAction: TextInputAction.next,
                                showClear: true,
                                onChanged: (value) =>
                                    context.read<ProfileBloc>().updateLastName(value),
                              ),
                              const SizedBox(height: 20.0),

                              // Email
                              ProfileTextField(
                                labelText: "Email",
                                controller: emailController,
                                inputType: TextInputType.emailAddress,
                                inputAction: TextInputAction.next,
                                showChange: true,
                                onChanged: (value) =>
                                    context.read<ProfileBloc>().updateEmail(value),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email id';
                                  }
                                  if (!emailRegExp.hasMatch(value)) {
                                    return 'Please enter valid email id';
                                  }
                                  return null;
                                },
                              ),

                              // Gender Dropdown
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 20.0,
                                  bottom: 20.0,
                                ),
                                child: CustomDropDownField(
                                  dropdownValue: _selectedGender,
                                  items: ['Not Selected', 'Male', 'Female'],
                                  onChanged: (value) {
                                    setState(() {
                                      context.read<ProfileBloc>()
                                          .updateGender(value ?? 'Not Selected');
                                    });
                                    setState(() => _selectedGender = value ?? 'Not Selected');
                                  },
                                  hintText: 'Select gender',
                                  color: isDarkMode
                                      ? AppColors.white
                                      : AppColors.borderColor,
                                  validator: (value) {
                                    if (value == null || value == 'Not Selected') {
                                      return 'Please select gender';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              // Date of Birth
                              ProfileTextField(
                                labelText: "Date of Birth",
                                controller: dateOfBirthController,
                                inputType: TextInputType.number,
                                inputAction: TextInputAction.next,
                                showClear: true,
                                onTap: () async {
                                  final selectedDate = await pickDate(context);
                                  if (selectedDate != null) {
                                    dateOfBirthController.text =
                                        DateFormat('dd/MM/yyyy').format(selectedDate);
                                    context.read<ProfileBloc>().updateDob(dateOfBirthController.text);
                                  }
                                },
                              ),
                              const SizedBox(height: 20.0),

                              // Mobile with country picker
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Row(
                                  children: [
                                    IntrinsicWidth(
                                      child: CustomCountryPicker(
                                        onChanged: (value) {},
                                      ),
                                    ),
                                    Expanded(
                                      child: ProfileTextField(
                                        labelText: "Mobile",
                                        controller: mobileController,
                                        inputType: TextInputType.number,
                                        inputAction: TextInputAction.done,
                                        showChange: true,
                                        maxLength: 10,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter mobile number';
                                          }
                                          if (value.length != 10) {
                                            return 'Please enter 10 digit mobile number';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) =>
                                            context.read<ProfileBloc>().updateMobile(value),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0),

                              // Country
                              ProfileTextField(
                                labelText: "Country",
                                controller: countryController,
                                inputType: TextInputType.text,
                                showClear: true,
                                isReadOnly: true,
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: false,
                                    countryListTheme: CountryListThemeData(
                                      backgroundColor: isDarkMode
                                          ? Colors.grey.shade900
                                          : AppColors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      textStyle:
                                      context.textTheme.bodyLarge?.copyWith(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                      searchTextStyle:
                                      context.textTheme.bodyLarge?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: isDarkMode
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                      inputDecoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: isDarkMode
                                            ? AppColors.black
                                            : Colors.grey.shade100,
                                        hintText: 'Search country',
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: SvgPicture.asset(
                                            AppIcons.search,
                                            colorFilter: ColorFilter.mode(
                                              isDarkMode
                                                  ? AppColors.white
                                                  : AppColors.greyColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: isDarkMode
                                                ? AppColors.white
                                                : AppColors.border,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: isDarkMode
                                                ? AppColors.white
                                                : AppColors.border,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onSelect: (Country country) {
                                      countryController.text = country.name;
                                      context.read<ProfileBloc>().updateCountry(country.name);
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter country';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  countryController.text = '';
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),

                        // ── Profile Picture ──────────────────────────
                        Positioned(
                          top: 30,
                          left: 0,
                          right: 0,
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.loose,
                            children: [
                              Container(
                                height: 132,
                                width: 132,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDarkMode
                                      ? AppColors.black.withValues(alpha: 0.6)
                                      : AppColors.transparent,
                                ),
                                child: ValueListenableBuilder<File?>(
                                  valueListenable: profileImageNotifier,
                                  builder: (context, file, child) {
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        file != null
                                            ? Image.file(
                                          File(file.path),
                                          fit: BoxFit.cover,
                                        )
                                            : CustomNetworkImage(
                                          imageUrl: state.profile
                                              ?.fullProfilePicUrl ??
                                              '',
                                          imageType: ImageType.profilepic,
                                        ),
                                        if (isDarkMode)
                                          Container(
                                            color:
                                            Colors.black.withOpacity(0.5),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              // Edit icon
                              Positioned(
                                bottom: 10,
                                right: 5,
                                left: size.width * .25,
                                child: InkWell(
                                  onTap: () {
                                    CustomImagePicker.showImagePicker(
                                      context,
                                      cameraOnTap: () {
                                        _pickImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                      galleryOnTap: () {
                                        _pickImage(ImageSource.gallery);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(AppIcons.edit),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: isDarkMode ? AppColors.primary : AppColors.white,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {

                  final isButtonEnabled =
                      !state.isAllEmpty &&
                          state.isChanged &&
                          state.status != ProfileStatus.loading;

                  return PrimaryButton(
                    text: 'Update Profile',
                    isLoading: false,
                    onPressed: isButtonEnabled
                        ? () {
                      _onUpdateProfile();
                    }
                        : null,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _onUpdateProfile() {
    debugPrint('First Name: ${firstNameController.text}');
    debugPrint('Last Name: ${lastNameController.text}');
    debugPrint('Email: ${emailController.text}');
    debugPrint('Phone: ${mobileController.text}');
    debugPrint('DOB: ${dateOfBirthController.text}');
    debugPrint('Country: ${countryController.text}');
    debugPrint('Gender: $_selectedGender');
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await CustomImageCropper.cropImage(
          pickedFile.path,
          isProfile: true,
        );
        if (croppedFile != null) {
          profileImageNotifier.value = File(croppedFile.path);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<DateTime?> pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }
}