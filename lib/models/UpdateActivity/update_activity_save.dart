class UpdateActivitySaveResult {
  /// True when the activity was inserted successfully
  /// into the local database.
  final bool savedLocally;

  /// True when the local activity was also synchronized
  /// successfully with the server.
  final bool syncedOnline;

  /// Actual lead ID used while saving.
  ///
  /// For temporary leads, this may differ from the ID
  /// originally received by the page.
  final String resolvedLeadId;

  /// Message displayed to the user.
  final String message;

  const UpdateActivitySaveResult({
    required this.savedLocally,
    required this.syncedOnline,
    required this.resolvedLeadId,
    required this.message,
  });

  /// Complete success: saved locally and synced online.
  bool get isFullySuccessful {
    return savedLocally && syncedOnline;
  }

  /// Saved locally but waiting for online synchronization.
  bool get isSavedOffline {
    return savedLocally && !syncedOnline;
  }

  /// Local database save failed.
  bool get hasFailed {
    return !savedLocally;
  }

  factory UpdateActivitySaveResult.localSuccess({
    required String resolvedLeadId,
    required String message,
  }) {
    return UpdateActivitySaveResult(
      savedLocally: true,
      syncedOnline: false,
      resolvedLeadId: resolvedLeadId,
      message: message,
    );
  }

  factory UpdateActivitySaveResult.onlineSuccess({
    required String resolvedLeadId,
    required String message,
  }) {
    return UpdateActivitySaveResult(
      savedLocally: true,
      syncedOnline: true,
      resolvedLeadId: resolvedLeadId,
      message: message,
    );
  }

  factory UpdateActivitySaveResult.failure({
    required String message,
    String resolvedLeadId = '',
  }) {
    return UpdateActivitySaveResult(
      savedLocally: false,
      syncedOnline: false,
      resolvedLeadId: resolvedLeadId,
      message: message,
    );
  }

  @override
  String toString() {
    return 'UpdateActivitySaveResult('
        'savedLocally: $savedLocally, '
        'syncedOnline: $syncedOnline, '
        'resolvedLeadId: $resolvedLeadId, '
        'message: $message'
        ')';
  }
}
