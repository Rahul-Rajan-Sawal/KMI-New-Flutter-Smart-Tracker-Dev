class UpdateActivityLookupOption {
  /// Actual lookup code used for conditions, database saves and API payloads.
  ///
  /// Example:
  /// code = "1"
  final String code;

  /// Text displayed to the user in the dropdown.
  ///
  /// Example:
  /// description = "Phone"
  final String description;

  const UpdateActivityLookupOption({
    required this.code,
    required this.description,
  });

  factory UpdateActivityLookupOption.fromMap(
    Map<String, dynamic> map,
  ) {
    return UpdateActivityLookupOption(
      code: map['ParamValue']?.toString().trim() ?? '',
      description: map['ParamDesc1']?.toString().trim() ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UpdateActivityLookupOption &&
            other.code == code &&
            other.description == description;
  }

  @override
  int get hashCode => Object.hash(code, description);

  @override
  String toString() {
    return 'UpdateActivityLookupOption('
        'code: $code, '
        'description: $description'
        ')';
  }
}