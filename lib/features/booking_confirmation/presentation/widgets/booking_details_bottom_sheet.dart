import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/widgets/primary_button.dart';

/// Contact details collected from the user right before an order is created.
class BookingContactDetails {
  final String name;
  final String phone;
  final String email;

  const BookingContactDetails({
    required this.name,
    required this.phone,
    required this.email,
  });
}

/// Bottom sheet that collects the booker's name, phone number, and email
/// before creating an order. Returns null when dismissed without confirming.
Future<BookingContactDetails?> showBookingDetailsBottomSheet(
  BuildContext context, {
  String? initialName,
  String? initialPhone,
  String? initialEmail,
}) {
  return showModalBottomSheet<BookingContactDetails>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final viewInsets = MediaQuery.of(ctx).viewInsets;
      return Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: _BookingDetailsBottomSheet(
          initialName: initialName,
          initialPhone: initialPhone,
          initialEmail: initialEmail,
        ),
      );
    },
  );
}

class _BookingDetailsBottomSheet extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialEmail;

  const _BookingDetailsBottomSheet({
    this.initialName,
    this.initialPhone,
    this.initialEmail,
  });

  @override
  State<_BookingDetailsBottomSheet> createState() =>
      _BookingDetailsBottomSheetState();
}

class _BookingDetailsBottomSheetState
    extends State<_BookingDetailsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  bool _showErrors = false;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _phoneRegex = RegExp(r'^[6-9]\d{9}$');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialPhone ?? '');
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Name is required';
    if (t.length > 100) return 'Name is too long';
    return null;
  }

  String? _validatePhone(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Phone number is required';
    if (!_phoneRegex.hasMatch(t)) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  String? _validateEmail(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(t)) return 'Enter a valid email address';
    return null;
  }

  void _submit() {
    setState(() => _showErrors = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      BookingContactDetails(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().toLowerCase(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXL),
          topRight: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
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
                SizedBox(height: AppSizes.spaceL),
                Text(
                  'Confirm your details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                ),
                SizedBox(height: AppSizes.spaceS),
                Text(
                  'We use these details for booking updates and receipts.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                ),
                SizedBox(height: AppSizes.spaceL),
                _LabeledTextField(
                  label: 'Full name',
                  controller: _nameCtrl,
                  hintText: 'Enter your full name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  showErrors: _showErrors,
                  validator: _validateName,
                ),
                SizedBox(height: AppSizes.space),
                _LabeledTextField(
                  label: 'Phone number',
                  controller: _phoneCtrl,
                  hintText: '10-digit mobile number',
                  prefixText: '+91  ',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  showErrors: _showErrors,
                  validator: _validatePhone,
                ),
                SizedBox(height: AppSizes.space),
                _LabeledTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  showErrors: _showErrors,
                  validator: _validateEmail,
                ),
                SizedBox(height: AppSizes.spaceXL),
                PrimaryButton(
                  text: 'Continue to Payment',
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
  final String? prefixText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool showErrors;

  const _LabeledTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
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
        SizedBox(height: AppSizes.spaceS),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isDarkMode ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingM,
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              prefixText: prefixText,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              // Errors render below the field container instead.
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            validator: validator,
          ),
        ),
        if (showErrors)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final error = validator?.call(value.text);
              if (error == null || error.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(
                  top: AppSizes.spaceXS,
                  left: AppSizes.paddingS,
                ),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                ),
              );
            },
          ),
      ],
    );
  }
}
