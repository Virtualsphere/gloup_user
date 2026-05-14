import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/widgets/primary_button.dart';

class EditPersonResult {
  final String fullName;
  final int age;
  final String gender;
  final String? phone;

  EditPersonResult({
    required this.fullName,
    required this.age,
    required this.gender,
    this.phone,
  });
}

Future<void> showEditPersonBottomSheet(
  BuildContext context, {
  required String initialName,
  required int initialAge,
  required String initialGender,
  String? initialPhone,
  required void Function(EditPersonResult result) onSave,
}) async {
  final result = await showModalBottomSheet<EditPersonResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EditPersonBottomSheet(
      initialName: initialName,
      initialAge: initialAge,
      initialGender: initialGender,
      initialPhone: initialPhone,
    ),
  );

  if (result != null) {
    onSave(result);
  }
}

class _EditPersonBottomSheet extends StatefulWidget {
  final String initialName;
  final int initialAge;
  final String initialGender;
  final String? initialPhone;

  const _EditPersonBottomSheet({
    required this.initialName,
    required this.initialAge,
    required this.initialGender,
    this.initialPhone,
  });

  @override
  State<_EditPersonBottomSheet> createState() => _EditPersonBottomSheetState();
}

class _EditPersonBottomSheetState extends State<_EditPersonBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _phoneCtrl;

  late String _gender;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _ageCtrl = TextEditingController(text: widget.initialAge.toString());
    _gender = widget.initialGender;

    // Remove +91 prefix if present for editing
    String phoneNumber = widget.initialPhone ?? '';
    if (phoneNumber.startsWith('+91')) {
      phoneNumber = phoneNumber.substring(3);
    }
    _phoneCtrl = TextEditingController(text: phoneNumber);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _showErrors = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ageText = _ageCtrl.text.trim();
    final int age = int.parse(ageText);

    final phoneText = _phoneCtrl.text.trim();
    final String? phone = phoneText.isEmpty ? null : '+91$phoneText';

    Navigator.of(context).pop(
      EditPersonResult(
        fullName: _nameCtrl.text.trim(),
        age: age,
        gender: _gender,
        phone: phone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top center handle indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Edit profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.spaceL),

                // Form fields
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
                    const SizedBox(height: AppSizes.spaceM),
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
                    const SizedBox(height: AppSizes.spaceM),

                    // Gender selector
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
                        const SizedBox(width: AppSizes.spaceS),
                        Expanded(
                          child: _GenderChip(
                            label: 'Female',
                            selected: _gender == 'Female',
                            onTap: () => setState(() => _gender = 'Female'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceS),
                        Expanded(
                          child: _GenderChip(
                            label: 'Other',
                            selected: _gender == 'Other',
                            onTap: () => setState(() => _gender = 'Other'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.spaceM),

                    // Phone number
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone number (optional)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: AppSizes.spaceS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                            border: Border.all(
                              color: isDarkMode
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingS,
                                  vertical: AppSizes.paddingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDarkMode
                                          ? AppColors.backgroundDark
                                          : AppColors.background)
                                      .withValues(alpha: 0.5),
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusS),
                                ),
                                child: Text(
                                  '+91',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.spaceS),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Phone number',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    errorStyle:
                                        TextStyle(height: 0, fontSize: 0),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  validator: (v) {
                                    final t = (v ?? '').trim();
                                    if (t.isEmpty) return null;
                                    if (t.length < 10 || t.length > 15) {
                                      return 'Enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showErrors)
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _phoneCtrl,
                            builder: (context, value, child) {
                              final t = value.text.trim();
                              if (t.isEmpty) return const SizedBox.shrink();
                              if (t.length < 10 || t.length > 15) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppSizes.spaceXS,
                                      left: AppSizes.paddingS),
                                  child: Text(
                                    'Enter a valid phone number',
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
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.spaceXL),

                PrimaryButton(
                  text: 'Save changes',
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingXS,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isDarkMode ? AppColors.borderDark : AppColors.border,
            ),
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
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              contentPadding: EdgeInsets.zero,
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
    final borderColor = selected
        ? (isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary)
        : (isDarkMode ? AppColors.borderDark : AppColors.border);
    final borderWidth =
        selected ? AppSizes.borderWidthThick : AppSizes.borderWidth;
    final textColor = selected
        ? (isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary)
        : (isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Opacity(
      opacity: selected ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: onTap,
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
