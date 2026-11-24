import 'package:tressy/core/constants/app_strings.dart';

/// Common validation utilities
class Validators {
  Validators._();

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppStrings.validationEmail;
    }

    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');

    if (!phoneRegex.hasMatch(value)) {
      return AppStrings.validationPhone;
    }

    return null;
  }

  static final RegExp _indianMobileRegex = RegExp(r'^[6-9]\d{9}$');

  /// Normalizes an Indian mobile number to 10 digits starting with 6-9.
  /// Handles prefixes like "+91", "91", leading "0", and ignores formatting.
  /// Returns null if [value] cannot be parsed to a valid 10-digit Indian mobile.
  static String? normalizeIndianMobile(String? value) {
    if (value == null) return null;
    String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    } else if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }

    if (digits.length == 10 && _indianMobileRegex.hasMatch(digits)) {
      return digits;
    }
    return null;
  }

  /// True when [value] is a valid 10-digit Indian mobile number.
  static bool isValidIndianMobile(String? value) =>
      normalizeIndianMobile(value) != null;

  /// Validate Indian phone number (10 digits starting with 6-9)
  static String? indianPhone(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return AppStrings.validationRequired;
    }

    if (!isValidIndianMobile(trimmed)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  /// Check if input is email
  static bool isEmail(String value) {
    return value.contains('@');
  }

  /// Check if input is phone
  static bool isPhone(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }

  /// Validate phone or email
  static String? phoneOrEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    if (isEmail(value)) {
      return email(value);
    } else {
      return indianPhone(value);
    }
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    if (value.length < 6) {
      return AppStrings.validationPassword;
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    if (value.length < length) {
      return 'Must be at least $length characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    if (value.length > length) {
      return 'Must be at most $length characters';
    }

    return null;
  }

  /// Validate password match
  static String? passwordMatch(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    if (value != password) {
      return AppStrings.validationPasswordMatch;
    }

    return null;
  }

  /// Validate number
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Allowed user / guest genders for booking.
  static const List<String> genders = ['Male', 'Female'];

  /// Returns `Male` or `Female` when [value] is a valid gender; otherwise null.
  /// Rejects empty, "Not Selected", "Other", and unknown values.
  static String? normalizeGender(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();
    if (lower == 'male' || lower == 'm' || lower == 'men') return 'Male';
    if (lower == 'female' || lower == 'f' || lower == 'women') {
      return 'Female';
    }
    return null;
  }

  /// True when [value] is Male or Female (any common casing).
  static bool isValidGender(String? value) => normalizeGender(value) != null;

  /// Form validator for required Male / Female gender.
  static String? gender(String? value) {
    if (!isValidGender(value)) {
      return 'Please select Male or Female';
    }
    return null;
  }
}
