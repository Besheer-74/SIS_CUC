class AppFormValidators {
  const AppFormValidators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredResult = required(value, fieldName: 'Email');
    if (requiredResult != null) {
      return requiredResult;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? optionalEmail(String? value, {String fieldName = 'Email'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid $fieldName.';
    }

    return null;
  }

  static String? phone(String? value, {String fieldName = 'Phone number'}) {
    final requiredResult = required(value, fieldName: fieldName);
    if (requiredResult != null) {
      return requiredResult;
    }

    final phonePattern = RegExp(r'^[0-9+\-\s()]{8,20}$');
    if (!phonePattern.hasMatch(value!.trim())) {
      return 'Enter a valid $fieldName.';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredResult = required(value, fieldName: 'Password');
    if (requiredResult != null) {
      return requiredResult;
    }

    if (value!.trim().length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String originalValue) {
    final requiredResult = required(value, fieldName: 'Confirm password');
    if (requiredResult != null) {
      return requiredResult;
    }

    if (value != originalValue) {
      return 'Passwords do not match.';
    }

    return null;
  }
}
