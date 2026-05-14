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

  /// Validate Indian phone number (10 digits)
  static String? indianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.validationRequired;
    }

    final phoneRegex = RegExp(r'^\d{10}$');

    if (!phoneRegex.hasMatch(value)) {
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
}
