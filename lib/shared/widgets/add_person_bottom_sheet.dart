import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_bloc.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_event.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/shared/widgets/primary_button.dart';

class AddPersonResult {
  final String fullName;
  final int age;
  final String gender; // 'Male' | 'Female' | 'Other'
  final String? phone; // will include +91 prefix if provided

  AddPersonResult({
    required this.fullName,
    required this.age,
    required this.gender,
    this.phone,
  });
}

Future<void> showAddPersonBottomSheet(
  BuildContext context,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final viewInsets = MediaQuery.of(ctx).viewInsets;
      return BlocProvider.value(
        value: context.read<GuestBloc>(),
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: const _AddPersonBottomSheet(),
        ),
      );
    },
  );
}

class _AddPersonBottomSheet extends StatefulWidget {
  const _AddPersonBottomSheet();

  @override
  State<_AddPersonBottomSheet> createState() => _AddPersonBottomSheetState();
}

class _AddPersonBottomSheetState extends State<_AddPersonBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _gender = 'Male'; // default
  bool _showErrors = false; // Only show errors after submit attempt

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _showErrors = true; // Enable error display on submit
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ageText = _ageCtrl.text.trim();
    final int age = int.parse(ageText); // Now required, so safe to parse

    final phoneText = _phoneCtrl.text.trim();
    final String phone = phoneText.isEmpty ? '' : phoneText;
    final String name = _nameCtrl.text.trim();

    // Trigger API call via BLoC
    context.read<GuestBloc>().add(
          AddGuestEvent(
            name: name,
            gender: _gender,
            age: age,
            phone: phone,
          ),
        );

    // Close the bottom sheet
    Navigator.of(context).pop();

    // Show loading message
    CustomToast.showInfo(context, 'Adding $name...');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXL),
          topRight: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingL,
            AppSizes.paddingL,
            AppSizes.paddingL,
            AppSizes.paddingXL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // grab handle
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceL),

                // title
                Text(
                  'Add a new person',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSizes.spaceL),

                // card-style inputs
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledTextField(
                      label: 'Full name',
                      controller: _nameCtrl,
                      hintText: 'Enter full name',
                      textInputAction: TextInputAction.next,
                      showErrors: _showErrors,
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.space),

                    _LabeledTextField(
                      label: 'Age',
                      controller: _ageCtrl,
                      hintText: 'Enter age',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      showErrors: _showErrors,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) {
                          return 'Age is required';
                        }
                        final parsed = int.tryParse(t);
                        if (parsed == null || parsed <= 0 || parsed > 120) {
                          return 'Enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.space),

                    // gender selector
                    Text(
                      'Gender',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Row(
                      children: [
                        Expanded(
                          child: _GenderChip(
                            label: 'Male',
                            selected: _gender == 'Male',
                            onTap: () => setState(() => _gender = 'Male'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceM),
                        Expanded(
                          child: _GenderChip(
                            label: 'Female',
                            selected: _gender == 'Female',
                            onTap: () => setState(() => _gender = 'Female'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceM),
                        Expanded(
                          child: _GenderChip(
                            label: 'Other',
                            selected: _gender == 'Other',
                            onTap: () => setState(() => _gender = 'Other'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space),

                    // phone with +91 prefix (optional)
                    Text(
                      'Phone (optional)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.borderDark
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingM,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingS,
                              vertical: AppSizes.paddingS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusS),
                            ),
                            child: Text(
                              '+91',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _phoneCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Phone number',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    errorStyle: TextStyle(
                                        height: 0,
                                        fontSize: 0), // Hide error inside
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  validator: (v) {
                                    final t = (v ?? '').trim();
                                    if (t.isEmpty) return null; // optional
                                    final isNumeric =
                                        RegExp(r'^[0-9]+$').hasMatch(t);
                                    if (!isNumeric ||
                                        t.length < 6 ||
                                        t.length > 15) {
                                      return 'Enter a valid phone';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show phone error message outside border
                    if (_showErrors)
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _phoneCtrl,
                        builder: (context, value, child) {
                          final t = value.text.trim();
                          if (t.isNotEmpty) {
                            final isNumeric = RegExp(r'^[0-9]+$').hasMatch(t);
                            if (!isNumeric || t.length < 6 || t.length > 15) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    top: AppSizes.spaceXS,
                                    left: AppSizes.paddingS),
                                child: Text(
                                  'Enter a valid phone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                ),

                const SizedBox(height: AppSizes.spaceXL),

                PrimaryButton(
                  text: 'Add a person',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool showErrors;

  const _LabeledTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.showErrors = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isDarkMode ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingM,
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              errorStyle:
                  const TextStyle(height: 0, fontSize: 0), // Hide error inside
            ),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
          ),
        ),
        // Show error message outside border
        if (showErrors)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final error = validator?.call(value.text);
              if (error != null && error.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: AppSizes.spaceXS, left: AppSizes.paddingS),
                  child: Text(
                    error,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color activeColor =
        isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary;
    final Color textColor = selected
        ? activeColor
        : (isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary);
    final Color borderColor = selected
        ? activeColor
        : (isDarkMode ? AppColors.borderDark : AppColors.border);
    final double borderWidth =
        selected ? AppSizes.borderWidthThick : AppSizes.borderWidth;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: selected ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
