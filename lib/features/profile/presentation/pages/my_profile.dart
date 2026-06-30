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
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
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
  final TextEditingController cityController = TextEditingController();

  final ValueNotifier<File?> profileImageNotifier = ValueNotifier(null);

  String _selectedGender = 'Not Selected';
  int? calculatedAge;

  // Track initial values to detect changes
  String _initialFirstName = '';
  String _initialLastName = '';
  String _initialEmail = '';
  String _initialMobile = '';
  String _initialDob = '';
  String _initialCountry = '';
  String _initialCity = '';
  String _initialGender = 'Not Selected';

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _fillFields(state.profile);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    dateOfBirthController.dispose();
    countryController.dispose();
    cityController.dispose();
    profileImageNotifier.dispose();
    super.dispose();
  }

  void _fillFields(ProfileEntity profile) {
    firstNameController.text =
        profile.firstname.isNotEmpty ? profile.firstname : '';
    lastNameController.text =
        profile.lastname.isNotEmpty ? profile.lastname : '';
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
    cityController.text = profile.city.isNotEmpty ? profile.city : '';

    if (profile.gender.isNotEmpty) {
      final capitalised = profile.gender[0].toUpperCase() +
          profile.gender.substring(1).toLowerCase();
      const validGenders = ['Male', 'Female'];
      setState(() {
        _selectedGender =
            validGenders.contains(capitalised) ? capitalised : 'Not Selected';
      });
    } else {
      setState(() => _selectedGender = 'Not Selected');
    }

    // Store initial values for change detection
    _initialFirstName = firstNameController.text;
    _initialLastName = lastNameController.text;
    _initialEmail = emailController.text;
    _initialMobile = mobileController.text;
    _initialDob = dateOfBirthController.text;
    _initialCountry = countryController.text;
    _initialCity = cityController.text;
    _initialGender = _selectedGender;
    profileImageNotifier.value = null;
  }

  bool get _hasChanges {
    final bool imageChanged = profileImageNotifier.value != null;

    return imageChanged ||
        firstNameController.text != _initialFirstName ||
        lastNameController.text != _initialLastName ||
        emailController.text != _initialEmail ||
        mobileController.text != _initialMobile ||
        dateOfBirthController.text != _initialDob ||
        countryController.text != _initialCountry ||
        cityController.text != _initialCity ||
        _selectedGender != _initialGender;
  }

  bool get _isFormValid {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        _selectedGender != 'Not Selected';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _fillFields(state.profile);
        } else if (state is ProfileUpdateSuccess) {
          _fillFields(state.profile);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Handle loading state
        if (state is ProfileLoading) {
          return SafeArea(
            child: Scaffold(
              backgroundColor:
                  isDarkMode ? AppColors.backgroundDark : AppColors.background,
              appBar: ProfileAppBar(
                title: "Your Profile",
                centerTitle: false,
                onBack: () => Navigator.of(context).pop(),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Handle failure state
        if (state is ProfileFailure) {
          return SafeArea(
            child: Scaffold(
              backgroundColor:
                  isDarkMode ? AppColors.primary : AppColors.background,
              appBar: ProfileAppBar(
                title: "Your Profile",
                centerTitle: false,
                onBack: () => Navigator.of(context).pop(),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProfileBloc>()
                            .add(const GetProfileEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Get profile from state
        ProfileEntity? profile;
        if (state is ProfileLoaded) profile = state.profile;
        if (state is ProfileUpdating) profile = state.profile;
        if (state is ProfileUpdateSuccess) profile = state.profile;
        if (state is ProfileUpdateFailure) profile = state.profile;
        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.backgroundDark : AppColors.background,
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
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surface,
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
                                onChanged: (value) => setState(() {}),
                              ),
                              const SizedBox(height: 20.0),

                              // Last Name
                              ProfileTextField(
                                labelText: "Last Name",
                                controller: lastNameController,
                                inputType: TextInputType.name,
                                inputAction: TextInputAction.next,
                                showClear: true,
                                onChanged: (value) => setState(() {}),
                              ),
                              const SizedBox(height: 20.0),

                              // Email
                              ProfileTextField(
                                labelText: "Email",
                                controller: emailController,
                                inputType: TextInputType.emailAddress,
                                inputAction: TextInputAction.next,
                                showChange: true,
                                onChanged: (value) => setState(() {}),
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
                                  labelText: 'Gender',
                                  dropdownValue: _selectedGender,
                                  items: ['Not Selected', 'Male', 'Female'],
                                  onChanged: (value) {
                                    setState(() => _selectedGender =
                                        value ?? 'Not Selected');
                                  },
                                  hintText: 'Select gender',
                                  color: isDarkMode
                                      ? AppColors.white
                                      : AppColors.borderColor,
                                  validator: (value) {
                                    if (value == null ||
                                        value == 'Not Selected') {
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
                                        DateFormat('dd-MM-yyyy')
                                            .format(selectedDate);
                                    calculatedAge = calculateAge(selectedDate);
                                    setState(() {});
                                  }
                                },
                              ),
                              const SizedBox(height: 20.0),

                              // Mobile with country picker
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mobile',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IntrinsicWidth(
                                          child: CustomCountryPicker(
                                            onChanged: (value) {},
                                          ),
                                        ),
                                        Expanded(
                                          child: ProfileTextField(
                                            includeOuterPadding: false,
                                            controller: mobileController,
                                            inputType: TextInputType.number,
                                            inputAction: TextInputAction.done,
                                            showChange: true,
                                            maxLength: 10,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter mobile number';
                                              }
                                              if (value.length != 10) {
                                                return 'Please enter 10 digit mobile number';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) =>
                                                setState(() {}),
                                          ),
                                        ),
                                      ],
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
                                      setState(() {});
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

                              // City
                              ProfileTextField(
                                labelText: "City",
                                controller: cityController,
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.done,
                                showClear: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter city';
                                  }
                                  return null;
                                },
                                onChanged: (value) => setState(() {}),
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),

                        // ── Profile Picture ──────────────────────────
                        Positioned(
                          top: 60,
                          left: 0,
                          right: 0,
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.loose,
                            children: [
                              Container(
                                height: 96,
                                width: 96,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDarkMode
                                      ? AppColors.backgroundDark
                                      : AppColors.background,
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
                                                imageUrl: profile
                                                        ?.fullProfilePicUrl ??
                                                    '',
                                                imageType: ImageType.profilepic,
                                              ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              // Edit icon
                              Positioned(
                                bottom: 10,
                                right: 15,
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
          bottomNavigationBar: SafeArea(
            child: Container(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 15.0),
                child: PrimaryButton(
                  text: 'Update Profile',
                  isLoading: state is ProfileUpdating,
                  onPressed: (_isFormValid && _hasChanges)
                      ? () {
                          _onUpdateProfile();
                        }
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onUpdateProfile() {
    final currentState = context.read<ProfileBloc>().state;

    ProfileEntity? currentProfile;
    if (currentState is ProfileLoaded) {
      currentProfile = currentState.profile;
    } else if (currentState is ProfileUpdateSuccess) {
      currentProfile = currentState.profile;
    } else if (currentState is ProfileUpdateFailure) {
      currentProfile = currentState.profile;
    }

    if (currentProfile != null) {
      final updatedProfile = currentProfile.copyWith(
        firstname: firstNameController.text.trim(),
        lastname: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: int.tryParse(mobileController.text.trim()),
        age: calculatedAge,
        dateOfBirth: dateOfBirthController.text.trim(),
        country: countryController.text.trim(),
        city: cityController.text.trim(),
        gender: _selectedGender,
        profilePic:
            profileImageNotifier.value?.path ?? currentProfile.profilePic,
      );

      context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile));
    }
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
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  //calculate age:-
  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
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
