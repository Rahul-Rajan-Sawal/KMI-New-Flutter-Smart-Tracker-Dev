class UpdateActivityOption {
  /// Original activity code from the database.
  ///
  /// Examples:
  /// 01, 02, 1, 2, 17
  final String code;

  /// Activity name displayed in the dropdown.
  final String description;

  const UpdateActivityOption({required this.code, required this.description});

  /// Normalized code used only for Flutter UI conditions.
  ///
  /// Examples:
  /// 01 -> 1
  /// 02 -> 2
  /// 05 -> 5
  ///
  /// The original [code] remains unchanged for database and API operations.
  String get normalizedCode {
    final trimmedCode = code.trim();
    final numericCode = int.tryParse(trimmedCode);

    return numericCode?.toString() ?? trimmedCode;
  }

  factory UpdateActivityOption.fromMap(Map<String, dynamic> map) {
    return UpdateActivityOption(
      code: map['ActivityCode']?.toString().trim() ?? '',
      description: map['ActivityDesc1']?.toString().trim() ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UpdateActivityOption && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() {
    return 'UpdateActivityOption(code: $code, description: $description)';
  }
}
