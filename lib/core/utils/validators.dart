/// Common input validators
/// Use these in form fields for consistent validation
class Validators {
  /// Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// Password validation (min 6 characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  /// Strong password validation
  /// Requires: min 8 chars, uppercase, lowercase, number
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung huruf besar';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf kecil';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung angka';
    }

    return null;
  }

  /// Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName tidak boleh kosong'
          : 'Field ini wajib diisi';
    }
    return null;
  }

  /// Name validation (min 3 characters)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }

    return null;
  }

  /// Phone number validation (Indonesian format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if starts with valid prefixes
    if (!RegExp(r'^(08|628|\+628)').hasMatch(cleaned)) {
      return 'Format nomor tidak valid (contoh: 08123456789)';
    }

    // Check length (10-13 digits after cleaning)
    if (cleaned.length < 10 || cleaned.length > 14) {
      return 'Panjang nomor tidak valid';
    }

    return null;
  }

  /// Employee ID validation
  static String? employeeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Employee ID tidak boleh kosong';
    }

    if (value.trim().length < 3) {
      return 'Employee ID minimal 3 karakter';
    }

    return null;
  }

  /// Numeric validation
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName tidak boleh kosong'
          : 'Field ini wajib diisi';
    }

    if (int.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName harus berupa angka'
          : 'Hanya boleh berisi angka';
    }

    return null;
  }

  /// Min length validation
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName tidak boleh kosong'
          : 'Field ini wajib diisi';
    }

    if (value.length < minLength) {
      return fieldName != null
          ? '$fieldName minimal $minLength karakter'
          : 'Minimal $minLength karakter';
    }

    return null;
  }

  /// Max length validation
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (value.length > maxLength) {
      return fieldName != null
          ? '$fieldName maksimal $maxLength karakter'
          : 'Maksimal $maxLength karakter';
    }

    return null;
  }

  /// Match validation (for password confirmation)
  static String? match(String? value, String? otherValue, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }

    if (value != otherValue) {
      return '$fieldName tidak cocok';
    }

    return null;
  }

  /// Compose multiple validators
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// Extension for easy validator composition
extension ValidatorExtension on String? Function(String?) {
  /// Combine with another validator
  String? Function(String?) and(String? Function(String?) other) {
    return (value) {
      final error = this(value);
      if (error != null) return error;
      return other(value);
    };
  }
}

