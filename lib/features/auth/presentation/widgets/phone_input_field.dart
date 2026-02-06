import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sim_data/sim_data.dart';
import 'package:flutter_sim_data/sim_data_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/custom_alert_dialog.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final bool showSimSelector;
  final String? Function(String?)? validator;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.hintText = 'Mobile Number',
    this.maxLength = 10,
    this.showSimSelector = true,
    this.validator,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  bool _hasShownDialog = false;

  Future<bool> _requestPhonePermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      return false;
    }
    PermissionStatus phoneStatus = await Permission.phone.status;
    if (phoneStatus.isGranted) return true;

    phoneStatus = await Permission.phone.request();
    if (phoneStatus.isGranted) {
      return true;
    } else if (phoneStatus.isPermanentlyDenied) {
      if (context.mounted) {
        await CustomAlertDialog.show(
          context: context,
          title: 'Permission Required',
          description:
              'We need phone permission to auto-fill your mobile number from SIM. Enable it in settings.',
          cancelText: 'Cancel',
          submitText: 'Open Settings',
          onSubmit: () async {
            await openAppSettings();
          },
        );
      }
      return false;
    }
    return false;
  }

  Future<void> _fetchSimData(BuildContext context) async {
    if (_hasShownDialog || !Platform.isAndroid) {
      return;
    }

    if (await _requestPhonePermission(context)) {
      _hasShownDialog = true;
      try {
        final List<SimDataModel> simData = await SimData().getSimData();
        final List<String> mobileNumbers = [];

        for (var sim in simData) {
          if (sim.phoneNumber.isNotEmpty) {
            mobileNumbers.add(sim.phoneNumber);
          }
        }

        if (mobileNumbers.isNotEmpty && context.mounted) {
          _showSimSelectorModal(context, simData);
        } else if (context.mounted) {
          context.showSnackBar(
            "No SIM cards found",
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching SIM data: $e')),
          );
        }
      }
    }
  }

  void _showSimSelectorModal(
      BuildContext context, List<SimDataModel> simCards) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor:
              isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.screenHeight * 0.6,
            ),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Phone numbers list
                    for (int i = 0; i < simCards.length; i++) ...[
                      if (simCards[i].phoneNumber.isNotEmpty)
                        InkWell(
                          onTap: () {
                            final phoneNumber = simCards[i].phoneNumber;
                            final lastDigits = phoneNumber.length > 10
                                ? phoneNumber.substring(phoneNumber.length - 10)
                                : phoneNumber;
                            widget.controller.text = lastDigits;
                            Navigator.pop(context);
                          },
                          child: ListTile(
                            visualDensity: const VisualDensity(vertical: -2),
                            leading: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.call,
                                color: isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              _formatPhoneNumber(simCards[i].phoneNumber),
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: simCards[i].carrierName.isNotEmpty
                                ? Text(
                                    simCards[i].carrierName,
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: isDarkMode
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    if (phoneNumber.length >= 10) {
      String countryCode = phoneNumber.length > 10
          ? phoneNumber.substring(0, phoneNumber.length - 10)
          : '+91';
      String mainNumber = phoneNumber.substring(phoneNumber.length - 10);
      if (!countryCode.startsWith('+')) {
        countryCode = '+$countryCode';
      }
      return '$countryCode $mainNumber';
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      validator: widget.validator,
      onTap: widget.showSimSelector ? () => _fetchSimData(context) : null,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: context.textTheme.bodyLarge?.copyWith(
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingXS + AppSizes.paddingM,
        ),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(
            color: context.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      ),
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurface,
      ),
    );
  }
}
