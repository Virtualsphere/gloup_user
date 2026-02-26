import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/core/extensions/string_extensions.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_drop_downs.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/features/widgets/profile_text_field.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ValueNotifier<File?> profileImageNotifier = ValueNotifier(null);
  late TextEditingController firstNameController,
      lastNameController,
      emailController,
      dateOfBirthController,
      mobileController,
      dayController,
      yearController,
      countryController;

  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    dateOfBirthController = TextEditingController();
    mobileController = TextEditingController();
    countryController = TextEditingController(text: 'India');
    dayController = TextEditingController();
    yearController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    mobileController.dispose();
    countryController.dispose();
    dayController.dispose();
    yearController.dispose();

    profileImageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProfileAppBar(
          title: "Your Profile",
          centerTitle: false,
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: size.width,
                        margin: EdgeInsets.only(
                            top: size.height * .12,
                            left: 15,
                            right: 15,
                            bottom: 15),
                        decoration: Themes.borderDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 90.0),
                            ProfileTextField(
                              labelText: "First Name",
                              controller: firstNameController,
                              inputType: TextInputType.name,
                              inputAction: TextInputAction.next,
                              showClear: true,
                            ),
                            SizedBox(height: 20.0),
                            ProfileTextField(
                              labelText: "Last Name",
                              controller: lastNameController,
                              inputType: TextInputType.name,
                              inputAction: TextInputAction.next,
                              showClear: true,
                            ),
                            SizedBox(height: 20.0),
                            ProfileTextField(
                              labelText: "Email",
                              controller: emailController,
                              inputType: TextInputType.emailAddress,
                              inputAction: TextInputAction.next,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter email id';
                                } else if (!emailRegExp.hasMatch(value)) {
                                  return 'Please enter valid email id';
                                } else {
                                  return null;
                                }
                              },
                              showChange: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 20.0,
                                  bottom: 20.0),
                              child: CustomDropDownField(
                                dropdownValue: 'Not Selected',
                                items: ['Not Selected', 'Male', 'Female'],
                                onChanged: (value) {
                                  // authController.setGender = value;
                                },
                                hintText: 'Select gender',
                                color: AppColors.secondary,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select gender';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            ProfileTextField(
                              labelText: "Date of Birth",
                              controller: dateOfBirthController,
                              inputType: TextInputType.number,
                              inputAction: TextInputAction.next,
                              showClear: true,
                              onTap: () async {
                                DateTime? selectedDate =
                                    await pickDate(context);
        
                                if (selectedDate != null) {
                                  dateOfBirthController.text =
                                      DateFormat('dd/MM/yyyy')
                                          .format(selectedDate);
                                  print(selectedDate); // full DateTime object
                                }
                              },
                            ),
                            SizedBox(height: 20.0),
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
                                          if (value!.isEmpty) {
                                            return 'Please enter mobile number';
                                          } else if (value.length != 10) {
                                            return 'Please enter 10 digit mobile number';
                                          } else {
                                            return null;
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0),
                            ProfileTextField(
                              labelText: "Country",
                              controller: countryController,
                              inputType: TextInputType.number,
                              showClear: true,
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: false,
                                  countryListTheme: CountryListThemeData(
                                    searchTextStyle: AppTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.primary,
                                    ).textStyle,
                                    textStyle: AppTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.primary,
                                    ).textStyle,
                                    inputDecoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Search country',
                                      hintStyle: AppTextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.secondary,
                                      ).textStyle,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: SvgPicture.asset(
                                          AppIcons.search,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onSelect: (Country country) {
                                    countryController.text = country.name;
                                  },
                                );
                              },
                              isReadOnly: true,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter country';
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {
                                countryController.text = '';
                                setState(() {});
                              },
                            ),
                            SizedBox(
                              height: 20.0,
                            )
                          ],
                        ),
                      ),
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
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: ValueListenableBuilder(
                                valueListenable: profileImageNotifier,
                                builder: (context, file, child) {
                                  return file != null
                                      ? Image.file(
                                          File(file.path),
                                          fit: BoxFit.cover,
                                        )
                                      : CustomNetworkImage(
                                          imageUrl: '',
                                          imageType: ImageType.profilepic,
                                        );
                                },
                              ),
                            ),
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
                                    child: SvgPicture.asset(
                                      AppIcons.edit,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: CustomFullButton(
            title: 'Update Profile',
            onTap: () async {},
          ),
        ),
      ),
    );
  }

  // Image Picker:-
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
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    return pickedDate;
  }
}

class ProfileDetailText extends StatelessWidget {
  const ProfileDetailText({
    super.key,
    required this.title,
    required this.data,
    this.isEmail = false,
  });

  final String title, data;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderTextBlack(
            title: title.capitalize(),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          BodyTextHint(
            title: isEmail ? data.toLowerCase() : data.capitalize(),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          )
        ],
      ),
    );
  }
}
