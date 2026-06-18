import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_code_mapper.dart';

enum UpdateActivityFieldType {
  text,
  multilineText,
  phone,
  integer,
  decimal,
  date,
  dateTime,
  dropdown,
}

class UpdateActivityFieldCondition {
 
  final Map<String, Set<String>> allowedValuesByField;

  const UpdateActivityFieldCondition({required this.allowedValuesByField});

  bool isSatisfied(Map<String, dynamic> currentValues) {
    for (final entry in allowedValuesByField.entries) {
      final currentValue = currentValues[entry.key]?.toString().trim() ?? '';

      if (!entry.value.contains(currentValue)) {
        return false;
      }
    }

    return true;
  }
}

class UpdateActivityFieldConfig {
  final String key;
  final String label;
  final String hintText;
  final UpdateActivityFieldType type;

  final bool isRequired;
  final String? requiredMessage;

  final String? lookupCode;
  final int? maxLength;
  final int? minimumLength;
  final bool digitsOnly;

  final String? trackerColumn;

  final UpdateActivityFieldCondition? visibilityCondition;

  const UpdateActivityFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.hintText = '',
    this.isRequired = false,
    this.requiredMessage,
    this.lookupCode,
    this.maxLength,
    this.minimumLength,
    this.digitsOnly = false,
    this.trackerColumn,
    this.visibilityCondition,
  });

  String get databaseColumn => trackerColumn ?? key;

  bool isVisible(Map<String, dynamic> currentValues) {
    final condition = visibilityCondition;

    if (condition == null) {
      return true;
    }

    return condition.isSatisfied(currentValues);
  }
}

/// Lead information used to select the correct Android form.
class UpdateActivityFormContext {
  final String activityCode;
  final String requestChannelId;
  final String leadSourceId;
  final String leadType;
  final String businessType;

  const UpdateActivityFormContext({
    required this.activityCode,
    this.requestChannelId = '',
    this.leadSourceId = '',
    this.leadType = '',
    this.businessType = '',
  });

  String get normalizedActivityCode {
    return UpdateActivityCodeMapper.normalizeCode(activityCode);
  }
}

/// Defines the fields and conditions for one Android activity form.
class UpdateActivityFormConfig {
  final String id;
  final String title;

  final Set<String> activityCodes;

  final Set<String> requestChannelIds;
  final Set<String> leadSourceIds;
  final Set<String> leadTypes;
  final Set<String> businessTypes;

  final UpdateActivityGroup activityGroup;

  final bool requiresSubActivity;

  final List<UpdateActivityFieldConfig> fields;

  /// Higher priority wins when more than one config matches.
  final int priority;

  const UpdateActivityFormConfig({
    required this.id,
    required this.title,
    required this.activityCodes,
    required this.activityGroup,
    required this.fields,
    this.requestChannelIds = const {},
    this.leadSourceIds = const {},
    this.leadTypes = const {},
    this.businessTypes = const {},
    this.requiresSubActivity = false,
    this.priority = 0,
  });

  bool matches(UpdateActivityFormContext context) {
    final activityMatches = activityCodes.contains(
      context.normalizedActivityCode,
    );

    if (!activityMatches) {
      return false;
    }

    if (!_matchesOptionalSet(requestChannelIds, context.requestChannelId)) {
      return false;
    }

    if (!_matchesOptionalSet(leadSourceIds, context.leadSourceId)) {
      return false;
    }

    if (!_matchesOptionalSet(leadTypes, context.leadType)) {
      return false;
    }

    if (!_matchesOptionalSet(businessTypes, context.businessType)) {
      return false;
    }

    return true;
  }

  bool _matchesOptionalSet(Set<String> allowedValues, String actualValue) {
    if (allowedValues.isEmpty) {
      return true;
    }

    final normalizedActual = actualValue.trim().toUpperCase();

    return allowedValues.any(
      (value) => value.trim().toUpperCase() == normalizedActual,
    );
  }
}
