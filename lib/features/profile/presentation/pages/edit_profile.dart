import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/widgets/custom_appbar.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_drop_downs.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/custom_safe_area.dart';
import 'package:tressy/features/widgets/custom_text_field.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    super.key,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  String? month;

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

  final List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  @override
  void initState() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    dateOfBirthController = TextEditingController();
    mobileController = TextEditingController();
    countryController = TextEditingController(text: 'India');
    dayController = TextEditingController();
    yearController = TextEditingController();

    super.initState();
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
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ActionBar(
              title: 'Edit Profile',
              isBackButtonDecoration: true,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15),
                children: [
                  Stack(
                    children: [
                      Container(
                        width: size.width,
                        margin:
                            EdgeInsets.only(top: size.height * .12, bottom: 15),
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: Themes.borderDecoration(),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 100),
                              HeaderTextBlack(
                                title: 'First Name',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(height: 8),
                              CustomTextField(
                                controller: firstNameController,
                                hintText: 'Enter first name',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter first name';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              SizedBox(height: 15),
                              HeaderTextBlack(
                                title: 'Last Name',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(height: 8),
                              CustomTextField(
                                controller: lastNameController,
                                hintText: 'Enter last name',
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter last name';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              SizedBox(height: 15),
                              HeaderTextBlack(
                                title: 'Email Address',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(height: 8),
                              CustomTextField(
                                controller: emailController,
                                hintText: 'Enter email id',
                                textCapitalization: TextCapitalization.none,
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
                              ),
                              SizedBox(height: 15),
                              HeaderTextBlack(
                                title: 'Gender',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(height: 8),
                              CustomDropDownField(
                                dropdownValue: 'Male',
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
                              SizedBox(height: 15),
                              HeaderTextBlack(
                                title: 'Date of Birth',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: dayController,
                                      hintText: 'Day',
                                      maxLength: 2,
                                      inputType: TextInputType.number,
                                      inputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter day';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  SizedBox(
                                    width: size.width * .27,
                                    child: CustomDropDownField(
                                      dropdownValue: month,
                                      items: months,
                                      onChanged: (value) {
                                        setState(() => month = value);
                                      },
                                      hintText: 'Month',
                                      color: AppColors.secondary,
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select month';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: yearController,
                                      hintText: 'Year',
                                      maxLength: 4,
                                      inputType: TextInputType.number,
                                      inputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter year';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              HeaderTextBlack(
                                title: 'Mobile Number',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicWidth(
                                    child: CustomCountryPicker(
                                      onChanged: (value) {},
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: mobileController,
                                      hintText: 'Mobile Number',
                                      inputType: TextInputType.number,
                                      inputAction: TextInputAction.done,
                                      maxLength: 10,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter mobile number';
                                        } else if (value.length != 10) {
                                          return 'Please enter 10 digit mobile number';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              HeaderTextBlack(
                                title: 'Country',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(height: 8),
                              CustomTextField(
                                controller: countryController,
                                hintText: 'Enter your country',
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
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: CustomFullButton(
                title: 'Confirm',
                onTap: () async {},
              ),
            ),
          ],
        ),
      ),
    );
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
}
