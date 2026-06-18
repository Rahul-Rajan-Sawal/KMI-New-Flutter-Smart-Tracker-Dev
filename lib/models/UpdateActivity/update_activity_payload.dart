class UpdateActivityPayload {
  /// Actual lead number.
  final String leadId;

  /// Temporary lead number, used for locally created leads.
  final String tempLeadId;

  /// Original activity code from the database.
  ///
  /// Examples: 01, 1, 17
  final String activityCode;

  /// Normalized code used for Flutter conditions.
  ///
  /// Examples: 01 -> 1
  final String normalizedActivityCode;

  final String createdBy;
  final String internalComment;

  /// Values that change depending on the selected activity.
  ///
  /// Activity 1 example:
  /// {
  ///   'AppThrough': '1',
  ///   'AppointmentDate': '12-06-2026 03:30 PM',
  ///   'PhoneNumber': '9876543210',
  ///   'AppointmentAddrss': '',
  ///   'Hour': '15',
  ///   'Minute': '30',
  /// }
  final Map<String, dynamic> activityFields;

  const UpdateActivityPayload({
    required this.leadId,
    required this.tempLeadId,
    required this.activityCode,
    required this.normalizedActivityCode,
    required this.createdBy,
    required this.internalComment,
    required this.activityFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'SrvcReqDtlCode': leadId,
      'TempSrvcReqDtlCode': tempLeadId,
      'ActivityCode': activityCode,
      'NormalizedActivityCode': normalizedActivityCode,
      'CreateBy': createdBy,
      'internalcomment': internalComment,
      ...activityFields,
    };
  }

  @override
  String toString() {
    return 'UpdateActivityPayload(${toMap()})';
  }
}