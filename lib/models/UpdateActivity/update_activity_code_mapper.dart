enum UpdateActivityGroup {
  fixedAppointment,
  dateMovement,
  parkedOrLost,
  converted,
  specialConditional,
  saleClosed,
  leadOpen,
  leadLost,
  unsupported,
}

/// Maps every Android/dynamic Activity Code 
/// It only identifies which shared flow an Activity Code belongs to.
class UpdateActivityCodeMapper {
  const UpdateActivityCodeMapper._();

  /// Converts values such as "01" into "1".
  static String normalizeCode(String code) {
    final trimmedCode = code.trim();

    if (trimmedCode.isEmpty) {
      return '';
    }

    final numericCode = int.tryParse(trimmedCode);

    return numericCode?.toString() ?? trimmedCode;
  }

  /// Returns the reusable activity group for the supplied Activity Code.
  static UpdateActivityGroup getGroup(String code) {
    switch (normalizeCode(code)) {
      // Android Code 1 — Fix Appointment
      case '1':
        return UpdateActivityGroup.fixedAppointment;

      // Date, appointment, callback, reschedule and follow-up flows
      case '2':
      case '19':
      case '20':
      case '21':
      case '27':
      case '28':
      case '32':
        return UpdateActivityGroup.dateMovement;

      // Parked and lost-related flows
      case '3':
      case '5':
      case '18':
      case '24':
      case '29':
      case '31':
        return UpdateActivityGroup.parkedOrLost;

      // Converted flows
      case '4':
      case '17':
      case '30':
      case '35':
        return UpdateActivityGroup.converted;

      // Android activities with their own conditional field rules
      case '16':
      case '22':
      case '23':
      case '25':
      case '26':
      case '33':
        return UpdateActivityGroup.specialConditional;

      // New dynamic Sale Closed flow
      case '36':
        return UpdateActivityGroup.saleClosed;

      // New dynamic Lead Open flow
      case '37':
        return UpdateActivityGroup.leadOpen;

      // New dynamic Lead Lost flow
      case '38':
        return UpdateActivityGroup.leadLost;

      default:
        return UpdateActivityGroup.unsupported;
    }
  }

  /// Dynamic Activity Codes 35–38 require the Sub Activity dropdown.
  static bool requiresSubActivity(String code) {
    final normalizedCode = normalizeCode(code);

    return const {
      '35',
      '36',
      '37',
      '38',
    }.contains(normalizedCode);
  }

  /// Returns true when the Activity Code is supported by the
  /// Android or newer dynamic activity flow.
  static bool isSupported(String code) {
    return getGroup(code) != UpdateActivityGroup.unsupported;
  }

  static bool isConverted(String code) {
    return getGroup(code) == UpdateActivityGroup.converted;
  }

  static bool isDateMovement(String code) {
    final group = getGroup(code);

    return group == UpdateActivityGroup.fixedAppointment ||
        group == UpdateActivityGroup.dateMovement ||
        group == UpdateActivityGroup.leadOpen;
  }

  static bool isLostOrParked(String code) {
    final group = getGroup(code);

    return group == UpdateActivityGroup.parkedOrLost ||
        group == UpdateActivityGroup.leadLost;
  }
}
