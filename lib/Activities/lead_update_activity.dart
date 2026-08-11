import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bottom_nav/UI%20Helper/UpdateActivity/update_activity_form_builder.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/repository/UpdateActivity/updateactivity_repository.dart';
import 'package:flutter_bottom_nav/core/repository/UpdateActivity/updateactivity_save_repository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_code_mapper.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_form_config.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_form_registry.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_model.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_payload.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/updateactivity_loockup_model.dart';

class LeadUpdate extends StatefulWidget {
  final Map<String, dynamic> lead;

  const LeadUpdate({super.key, required this.lead});

  @override
  State<LeadUpdate> createState() => _LeadUpdateState();
}

class _LeadUpdateState extends State<LeadUpdate> {
  final UpdateActivityRepository _repository = const UpdateActivityRepository();
  final UpdateActivitySaveRepository _saveRepository =
      const UpdateActivitySaveRepository();

  final TextEditingController internalCommentController =
      TextEditingController();

  final TextEditingController appointmentPhoneController =
      TextEditingController();

  final TextEditingController appointmentAddressController =
      TextEditingController();

  final TextEditingController appointmentDateTimeController =
      TextEditingController();
  final TextEditingController issuedPolicyNumberController =
      TextEditingController();

  final TextEditingController leadConvertedRemarkController =
      TextEditingController();

  UpdateActivityFormConfig? selectedFormConfig;

  final Map<String, dynamic> configuredFormValues = {};

  final Map<String, TextEditingController> configuredFormControllers = {};

  final Map<String, List<UpdateActivityLookupOption>>
  configuredDropdownOptions = {};

  final Set<String> loadingConfiguredDropdownFields = {};

  final Map<String, String> _loadedConfiguredLookupCodes = {};

  List<UpdateActivityOption> activityOptions = [];

  UpdateActivityOption? selectedActivity;
  // Reusable for Activity Codes 35–38
  List<UpdateActivityOption> subActivityOptions = [];
  UpdateActivityOption? selectedSubActivity;

  String _pendingCurrentSubActivityCode = '';

  bool isLoadingSubActivities = false;
  String? subActivityLoadError;
  // Activity Code 1 — Fix Appointment
  List<UpdateActivityLookupOption> appointmentThroughOptions = [];

  UpdateActivityLookupOption? selectedAppointmentThrough;

  bool isLoadingAppointmentThrough = false;
  DateTime? selectedAppointmentDateTime;

  bool isLoadingActivities = true;
  bool isSaving = false;
  String? activityLoadError;
  bool isCheckingBlockedStatus = true;

  String? blockedLeadStatus;

  void _clearConfiguredForm() {
    for (final controller in configuredFormControllers.values) {
      controller.dispose();
    }

    configuredFormControllers.clear();
    configuredFormValues.clear();
    configuredDropdownOptions.clear();
    loadingConfiguredDropdownFields.clear();
    _loadedConfiguredLookupCodes.clear();
    selectedFormConfig = null;
  }

  Future<void> _prepareConfiguredForm(UpdateActivityOption activity) async {
    final config = UpdateActivityFormRegistry.findByValues(
      activityCode: activity.normalizedCode,
      requestChannelId: _decryptSafely(widget.lead['ReqChannelId']),
      leadSourceId: _decryptSafely(
        widget.lead['LeadSource'] ?? widget.lead['LeadSourceId'],
      ),
      leadType: _getLeadType(),
      businessType: _decryptSafely(widget.lead['BizType']),
    );

    if (!mounted) return;

    if (config == null) {
      setState(() {
        selectedFormConfig = null;
      });

      debugPrint(
        'FORM CONFIG NOT FOUND FOR '
        '${activity.normalizedCode}',
      );

      return;
    }

    final createdFieldKeys = <String>{};

    for (final field in config.fields) {
      if (!createdFieldKeys.add(field.key)) {
        continue;
      }

      configuredFormValues[field.key] = '';

      if (field.type != UpdateActivityFieldType.dropdown) {
        configuredFormControllers[field.key] = TextEditingController();
      }
    }

    if (config.requiresSubActivity) {
      configuredFormValues['SubActivityCode'] = '';
      configuredFormValues['SubActivityDescription'] = '';
    }

    setState(() {
      selectedFormConfig = config;
    });

    debugPrint('FORM CONFIG SELECTED: ${config.id}');

    await _loadVisibleConfiguredDropdowns();
  }

  Future<void> _loadVisibleConfiguredDropdowns() async {
    final config = selectedFormConfig;

    if (config == null) {
      return;
    }

    final visibleDropdownFields = <String, UpdateActivityFieldConfig>{};

    for (final field in config.fields) {
      if (field.type != UpdateActivityFieldType.dropdown) {
        continue;
      }

      if (!field.isVisible(configuredFormValues)) {
        continue;
      }

      final lookupCode = field.lookupCode?.trim() ?? '';

      if (lookupCode.isEmpty) {
        continue;
      }

      // Only one currently visible configuration per field key.
      visibleDropdownFields.putIfAbsent(field.key, () => field);
    }

    for (final entry in visibleDropdownFields.entries) {
      final fieldKey = entry.key;
      final field = entry.value;
      final lookupCode = field.lookupCode!.trim();

      final alreadyLoaded =
          _loadedConfiguredLookupCodes[fieldKey] == lookupCode &&
          configuredDropdownOptions.containsKey(fieldKey);

      if (alreadyLoaded) {
        continue;
      }

      if (!mounted) return;

      setState(() {
        configuredFormValues[fieldKey] = '';
        configuredDropdownOptions.remove(fieldKey);
        loadingConfiguredDropdownFields.add(fieldKey);
      });

      try {
        final options = await _repository.getLookupOptions(
          lookupCode: lookupCode,
        );

       if (!mounted) return;

        // Ignore a response belonging to an older activity.
        if (selectedFormConfig?.id != config.id) {
          return;
        }

        setState(() {
          configuredDropdownOptions[fieldKey] = options;
          _loadedConfiguredLookupCodes[fieldKey] = lookupCode;
          loadingConfiguredDropdownFields.remove(fieldKey);
        });

        debugPrint(
          'LOOKUP LOADED: '
          '$fieldKey / $lookupCode / ${options.length}',
        );
      } catch (error, stackTrace) {
        debugPrint(
          'LOOKUP LOADING FAILED: '
          '$fieldKey / $lookupCode / $error',
        );
        debugPrintStack(stackTrace: stackTrace);

        if (!mounted) return;

        setState(() {
          configuredDropdownOptions[fieldKey] = [];
          loadingConfiguredDropdownFields.remove(fieldKey);
        });
      }
    }
  }

  void _clearHiddenConfiguredValues() {
    final config = selectedFormConfig;

    if (config == null) {
      return;
    }

    final visibleFieldKeys = config.fields
        .where((field) => field.isVisible(configuredFormValues))
        .map((field) => field.key)
        .toSet();

    for (final key in configuredFormValues.keys.toList()) {
      if (key == 'SubActivityCode' || key == 'SubActivityDescription') {
        continue;
      }

      if (!visibleFieldKeys.contains(key)) {
        configuredFormValues[key] = '';
        configuredFormControllers[key]?.clear();
        configuredDropdownOptions.remove(key);
        _loadedConfiguredLookupCodes.remove(key);
        loadingConfiguredDropdownFields.remove(key);
      }
    }
  }

  Future<void> _onConfiguredValueChanged(
    UpdateActivityFieldConfig field,
    String value,
  ) async {
    if (!mounted) return;

    setState(() {
      configuredFormValues[field.key] = value;
      _clearHiddenConfiguredValues();
    });

    await _loadVisibleConfiguredDropdowns();
  }

  Future<void> _onConfiguredDateFieldTap(
    UpdateActivityFieldConfig field,
  ) async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      // firstDate: DateTime(2000),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    DateTime finalDateTime = selectedDate;

    if (field.type == UpdateActivityFieldType.dateTime) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime == null || !mounted) {
        return;
      }

      finalDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    }

    final formattedValue = field.type == UpdateActivityFieldType.dateTime
        ? _formatAppointmentDateTime(finalDateTime)
        : '${finalDateTime.day.toString().padLeft(2, '0')}-'
              '${finalDateTime.month.toString().padLeft(2, '0')}-'
              '${finalDateTime.year}';

    setState(() {
      configuredFormValues[field.key] = formattedValue;

      configuredFormControllers[field.key]?.text = formattedValue;
    });
  }

  @override
  void initState() {
    super.initState();
    //_loadActivities();
    _initializeLeadUpdate();
  }

  Future<void> _initializeLeadUpdate() async {
    final leadId = _decryptSafely(widget.lead['SrvcReqDtlCode']);

    final tempLeadId = _decryptSafely(widget.lead['TempSrvcReqDtlCode']);

    // Refresh the latest server activity for a valid server lead.
    if (leadId.isNotEmpty && !leadId.toUpperCase().startsWith('T')) {
      await _saveRepository.refreshLatestActivityForLead(
        leadId: leadId,
        tempLeadId: tempLeadId,
        sapCode: StaticVariables.mSAPCode,
      );
    } else {
      debugPrint(
        'LATEST ACTIVITY API SKIPPED: '
        'Temporary or empty Lead ID: $leadId',
      );
    }

    // Check terminal status after refreshing local data.
    final blockedStatus = await _saveRepository.getBlockedLeadStatusForLead(
      leadId: leadId,
      tempLeadId: tempLeadId,
    );

    if (!mounted) {
      return;
    }

    if (blockedStatus != null) {
      setState(() {
        blockedLeadStatus = blockedStatus;
        isCheckingBlockedStatus = false;
        isLoadingActivities = false;
        activityOptions = [];
        selectedActivity = null;
      });

      return;
    }

    // Read latest ActivityCode and SubActivityCode from local DB.
    final currentSelection = await _saveRepository
        .getCurrentActivitySelectionForLead(
          leadId: leadId,
          tempLeadId: tempLeadId,
        );

    final currentActivityCode = currentSelection['activityCode']?.trim() ?? '';

    final currentSubActivityCode =
        currentSelection['subActivityCode']?.trim() ?? '';

    if (!mounted) {
      return;
    }

    setState(() {
      blockedLeadStatus = null;
      isCheckingBlockedStatus = false;
    });

    await _loadActivities(
      currentActivityCode: currentActivityCode,
      currentSubActivityCode: currentSubActivityCode,
    );
  }
  // Future<void> _initializeLeadUpdate() async {
  //   final leadId = _decryptSafely(widget.lead['SrvcReqDtlCode']);

  //   final tempLeadId = _decryptSafely(widget.lead['TempSrvcReqDtlCode']);

  //   // Android flow:
  //   // Refresh latest server activity only for a valid server lead.
  //   if (leadId.isNotEmpty && !leadId.toUpperCase().startsWith('T')) {
  //     await _saveRepository.refreshLatestActivityForLead(
  //       leadId: leadId,
  //       tempLeadId: tempLeadId,
  //       sapCode: StaticVariables.mSAPCode,
  //     );
  //   } else {
  //     debugPrint(
  //       'LATEST ACTIVITY API SKIPPED: '
  //       'Temporary or empty Lead ID: $leadId',
  //     );
  //   }

  //   // Check terminal status after refreshing local data.
  //   final blockedStatus = await _saveRepository.getBlockedLeadStatusForLead(
  //     leadId: leadId,
  //     tempLeadId: tempLeadId,
  //   );

  //   if (!mounted) {
  //     return;
  //   }

  //   if (blockedStatus != null) {
  //     setState(() {
  //       blockedLeadStatus = blockedStatus;
  //       isCheckingBlockedStatus = false;
  //       isLoadingActivities = false;
  //       activityOptions = [];
  //       selectedActivity = null;
  //     });

  //     return;
  //   }

  //   setState(() {
  //     blockedLeadStatus = null;
  //     isCheckingBlockedStatus = false;
  //   });

  //   await _loadActivities();
  // }

  /// Safely decrypts a value.
  ///
  /// If the supplied value is already plain text, the original value
  /// is returned when decryption fails.
  String _decryptSafely(dynamic value) {
    final rawValue = value?.toString().trim() ?? '';

    if (rawValue.isEmpty) {
      return '';
    }

    try {
      final decryptedValue = CommonUtil.decryptIfNotEmpty(rawValue).trim();

      return decryptedValue.isNotEmpty ? decryptedValue : rawValue;
    } catch (_) {
      return rawValue;
    }
  }

  String _getLeadType() {
    final leadTypeDescription = _decryptSafely(widget.lead['LeadTypeDesc']);

    final rawLeadType = _decryptSafely(widget.lead['LeadType']);

    if (leadTypeDescription.toLowerCase() == 'lead') {
      return 'L';
    }

    if (rawLeadType.toUpperCase() == 'L' || rawLeadType.toUpperCase() == 'P') {
      return rawLeadType.toUpperCase();
    }

    return 'P';
  }

  bool get _isRq17LeadSource29 {
    final reqChannelId = _decryptSafely(widget.lead['ReqChannelId']);

    final leadSourceId = _decryptSafely(
      widget.lead['LeadSource'] ?? widget.lead['LeadSourceId'],
    );

    return reqChannelId.toUpperCase() == 'RQ17' && leadSourceId == '29';
  }

  UpdateActivityGroup get _selectedActivityGroup {
    return UpdateActivityCodeMapper.getGroup(
      selectedActivity?.normalizedCode ?? '',
    );
  }

  Future<void> _loadActivities({
    String currentActivityCode = '',
    String currentSubActivityCode = '',
  }) async {
    _pendingCurrentSubActivityCode = currentSubActivityCode.trim();

    if (mounted) {
      setState(() {
        isLoadingActivities = true;
        activityLoadError = null;
      });
    }

    try {
      final reqChannelId = _decryptSafely(widget.lead['ReqChannelId']);

      final leadSourceId = _decryptSafely(
        widget.lead['LeadSource'] ?? widget.lead['LeadSourceId'],
      );

      final bizType = _decryptSafely(widget.lead['BizType']);

      final leadType = _getLeadType();

      debugPrint('UPDATE ACTIVITY INPUT');
      debugPrint('ReqChannelId: $reqChannelId');
      debugPrint('LeadSourceId: $leadSourceId');
      debugPrint('LeadType: $leadType');
      debugPrint('BizType: $bizType');

      final result = await _repository.getActivities(
        reqChannelId: reqChannelId,
        leadSourceId: leadSourceId,
        leadType: leadType,
        bizType: bizType,
      );

      if (!mounted) return;

      final normalizedCurrentActivityCode =
          int.tryParse(currentActivityCode.trim())?.toString() ??
          currentActivityCode.trim();

      UpdateActivityOption? currentActivity;

      for (final activity in result) {
        if (activity.normalizedCode == normalizedCurrentActivityCode) {
          currentActivity = activity;
          break;
        }
      }

      setState(() {
        activityOptions = result;
        selectedActivity = null;
        isLoadingActivities = false;

        if (result.isEmpty) {
          activityLoadError = 'Lead disposition not available.';
        }
      });

      if (currentActivity != null) {
        debugPrint(
          'PRESELECTING ACTIVITY: '
          '${currentActivity.code} - ${currentActivity.description}',
        );

        await _onActivityChanged(currentActivity);
      } else if (normalizedCurrentActivityCode.isNotEmpty) {
        debugPrint(
          'CURRENT ACTIVITY NOT FOUND IN DROPDOWN: '
          '$normalizedCurrentActivityCode',
        );
      }

      // setState(() {
      //   activityOptions = result;
      //   selectedActivity = null;
      //   isLoadingActivities = false;

      //   if (result.isEmpty) {
      //     activityLoadError = 'Lead disposition not available.';
      //   }
      // });

      debugPrint('ACTIVITIES RECEIVED: ${result.length}');

      for (final activity in result) {
        debugPrint('Activity: ${activity.code} - ${activity.description}');
      }
    } catch (e, stackTrace) {
      debugPrint('Activity loading failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        activityOptions = [];
        selectedActivity = null;
        isLoadingActivities = false;
        activityLoadError = 'Unable to load activities.';
      });
    }
  }

  Future<void> _onActivityChanged(UpdateActivityOption? activity) async {
    // Clear controllers and values of the previously
    // selected configuration-based activity.
    _clearConfiguredForm();

    setState(() {
      selectedActivity = activity;

      selectedSubActivity = null;
      subActivityOptions = [];
      subActivityLoadError = null;
      isLoadingSubActivities = false;

      selectedAppointmentThrough = null;
      appointmentThroughOptions = [];
      isLoadingAppointmentThrough = false;

      appointmentPhoneController.clear();
      appointmentAddressController.clear();
      appointmentDateTimeController.clear();

      issuedPolicyNumberController.clear();
      leadConvertedRemarkController.clear();

      selectedAppointmentDateTime = null;
    });

    if (activity == null) {
      return;
    }

    debugPrint('SELECTED ACTIVITY');
    debugPrint('Original code: ${activity.code}');
    debugPrint('Normalized code: ${activity.normalizedCode}');
    debugPrint('Description: ${activity.description}');

    // Existing custom Code 1 form.
    if (activity.normalizedCode == '1' && !_isRq17LeadSource29) {
      await _loadAppointmentThrough();
    }

    // // Codes 35–38 require Sub Activity.
    // if (UpdateActivityCodeMapper.requiresSubActivity(activity.normalizedCode)) {
    //   await _loadSubActivities(activity);
    // }

    // // Codes 1 and 35 still use their existing custom UI.
    // // Other activities use the new shared form builder.
    // if (activity.normalizedCode != '1' && activity.normalizedCode != '35') {
    //   await _prepareConfiguredForm(activity);
    // }

    // Prepare the configured form first.
    if (activity.normalizedCode != '1' && activity.normalizedCode != '35') {
      await _prepareConfiguredForm(activity);
    }

    // Load and preselect Sub Activity after the form is ready.
    if (UpdateActivityCodeMapper.requiresSubActivity(activity.normalizedCode)) {
      await _loadSubActivities(activity);
    }
  }

  Future<void> _loadAppointmentThrough() async {
    if (!mounted) return;

    setState(() {
      isLoadingAppointmentThrough = true;
    });

    try {
      final result = await _repository.getLookupOptions(
        lookupCode: 'AppThrough',
      );

      if (!mounted) return;

      // Prevent old lookup results from appearing if the user
      // changed the activity while the query was running.
      if (selectedActivity?.normalizedCode != '1') {
        return;
      }

      setState(() {
        appointmentThroughOptions = result;
        selectedAppointmentThrough = null;
        isLoadingAppointmentThrough = false;
      });

      debugPrint('APPOINTMENT THROUGH OPTIONS: ${result.length}');

      for (final option in result) {
        debugPrint('AppThrough: ${option.code} - ${option.description}');
      }
    } catch (e, stackTrace) {
      debugPrint('Appointment Through loading failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        appointmentThroughOptions = [];
        selectedAppointmentThrough = null;
        isLoadingAppointmentThrough = false;
      });
    }
  }

  Future<void> _loadSubActivities(UpdateActivityOption activity) async {
    if (!mounted) return;

    setState(() {
      isLoadingSubActivities = true;
      subActivityLoadError = null;
    });

    try {
      final reqChannelId = _decryptSafely(widget.lead['ReqChannelId']);

      final leadSourceId = _decryptSafely(
        widget.lead['LeadSource'] ?? widget.lead['LeadSourceId'],
      );

      final leadType = _getLeadType();

      final bizType = _decryptSafely(widget.lead['BizType']);

      final result = await _repository.getSubActivities(
        reqChannelId: reqChannelId,
        leadSourceId: leadSourceId,
        leadType: leadType,
        bizType: bizType,
        activityCode: activity.code,
      );

      if (!mounted) return;

      // Ignore the result if another Activity was selected
      // while the query was running.
      if (selectedActivity?.code != activity.code) {
        return;
      }

      final normalizedSubActivityCode =
          int.tryParse(_pendingCurrentSubActivityCode.trim())?.toString() ??
          _pendingCurrentSubActivityCode.trim();

      UpdateActivityOption? currentSubActivity;

      for (final option in result) {
        if (option.normalizedCode == normalizedSubActivityCode) {
          currentSubActivity = option;
          break;
        }
      }

      setState(() {
        subActivityOptions = result;
        selectedSubActivity = currentSubActivity;
        isLoadingSubActivities = false;

        if (currentSubActivity != null) {
          configuredFormValues['SubActivityCode'] = currentSubActivity.code;

          configuredFormValues['SubActivityDescription'] =
              currentSubActivity.description;
        }

        if (result.isEmpty) {
          subActivityLoadError = 'Sub Activity data not available.';
        }
      });

      if (currentSubActivity != null) {
        debugPrint(
          'PRESELECTING SUB ACTIVITY: '
          '${currentSubActivity.code} - '
          '${currentSubActivity.description}',
        );

        _pendingCurrentSubActivityCode = '';

        await _loadVisibleConfiguredDropdowns();
      } else if (normalizedSubActivityCode.isNotEmpty) {
        debugPrint(
          'CURRENT SUB ACTIVITY NOT FOUND: '
          '$normalizedSubActivityCode',
        );
      }

      debugPrint('SUB ACTIVITIES RECEIVED: ${result.length}');

      for (final option in result) {
        debugPrint(
          'Sub Activity: '
          '${option.code} - ${option.description}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Sub Activity loading failed: $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        subActivityOptions = [];
        selectedSubActivity = null;
        isLoadingSubActivities = false;
        subActivityLoadError = 'Unable to load Sub Activities.';
      });
    }
  }

  // Future<void> _loadSubActivities(UpdateActivityOption activity) async {
  //   if (!mounted) return;

  //   setState(() {
  //     isLoadingSubActivities = true;
  //     subActivityLoadError = null;
  //   });

  //   try {
  //     final reqChannelId = _decryptSafely(widget.lead['ReqChannelId']);

  //     final leadSourceId = _decryptSafely(
  //       widget.lead['LeadSource'] ?? widget.lead['LeadSourceId'],
  //     );

  //     final leadType = _getLeadType();

  //     final bizType = _decryptSafely(widget.lead['BizType']);

  //     final result = await _repository.getSubActivities(
  //       reqChannelId: reqChannelId,
  //       leadSourceId: leadSourceId,
  //       leadType: leadType,
  //       bizType: bizType,
  //       activityCode: activity.code,
  //     );

  //     if (!mounted) return;

  //     // Prevent an old query result from appearing after
  //     // the user has selected another activity.
  //     if (selectedActivity?.code != activity.code) {
  //       return;
  //     }

  //     setState(() {
  //       subActivityOptions = result;
  //       selectedSubActivity = null;
  //       isLoadingSubActivities = false;

  //       if (result.isEmpty) {
  //         subActivityLoadError = 'Sub Activity data not available.';
  //       }
  //     });

  //     debugPrint('SUB ACTIVITIES RECEIVED: ${result.length}');

  //     for (final option in result) {
  //       debugPrint(
  //         'Sub Activity: '
  //         '${option.code} - ${option.description}',
  //       );
  //     }
  //   } catch (error, stackTrace) {
  //     debugPrint('Sub Activity loading failed: $error');
  //     debugPrintStack(stackTrace: stackTrace);

  //     if (!mounted) return;

  //     setState(() {
  //       subActivityOptions = [];
  //       selectedSubActivity = null;
  //       isLoadingSubActivities = false;
  //       subActivityLoadError = 'Unable to load Sub Activities.';
  //     });
  //   }
  // }

  void _onAppointmentThroughChanged(UpdateActivityLookupOption? option) {
    setState(() {
      selectedAppointmentThrough = option;

      // Clear values belonging to the previous option.
      appointmentPhoneController.clear();
      appointmentAddressController.clear();
      appointmentDateTimeController.clear();
      selectedAppointmentDateTime = null;
    });

    if (option != null) {
      debugPrint(
        'Selected AppThrough: '
        '${option.code} - ${option.description}',
      );
    }
  }

  Future<void> _selectAppointmentDateTime() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) {
      return;
    }

    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // appointmentDateTimeController.text = _formatAppointmentDateTime(
    //   selectedDateTime,
    // );

    setState(() {
      selectedAppointmentDateTime = selectedDateTime;

      appointmentDateTimeController.text = _formatAppointmentDateTime(
        selectedDateTime,
      );
    });
  }

  String _formatAppointmentDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    var hour = dateTime.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    final formattedHour = hour.toString().padLeft(2, '0');

    return '$day-$month-$year $formattedHour:$minute $period';
  }

  @override
  void dispose() {
    internalCommentController.dispose();
    appointmentPhoneController.dispose();
    appointmentAddressController.dispose();
    appointmentDateTimeController.dispose();
    issuedPolicyNumberController.dispose();
    leadConvertedRemarkController.dispose();
    _clearConfiguredForm();
    super.dispose();
  }

  Widget _buildBlockedLeadView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 52, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lead Already ${blockedLeadStatus ?? 'Closed'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Another activity cannot be updated for this lead.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldHeight = MediaQuery.sizeOf(context).height * 0.055;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Update Leads'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF090979), Color(0xFF00D4FF)],
            ),
          ),
        ),
      ),

      body: isCheckingBlockedStatus
          ? const Center(child: CircularProgressIndicator())
          : blockedLeadStatus != null
          ? _buildBlockedLeadView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Activity *'),
                  _buildActivityDropdown(fieldHeight),

                  if (activityLoadError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        activityLoadError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),

                  const SizedBox(height: 8),
                  _buildActivitySpecificSection(fieldHeight),

                  _buildLabel('Internal Comment'),
                  _buildTextField(
                    controller: internalCommentController,
                    hintText: 'Internal Comment',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),
                  _buildSaveButton(),
                ],
              ),
            ),

      // body: SingleChildScrollView(
      //   padding: const EdgeInsets.all(16),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       _buildLabel('Activity *'),
      //       _buildActivityDropdown(fieldHeight),

      //       if (activityLoadError != null)
      //         Padding(
      //           padding: const EdgeInsets.only(bottom: 12),
      //           child: Text(
      //             activityLoadError!,
      //             style: const TextStyle(color: Colors.red, fontSize: 13),
      //           ),
      //         ),

      //       const SizedBox(height: 8),
      //       _buildActivitySpecificSection(fieldHeight),

      //       _buildLabel('Internal Comment'),
      //       _buildTextField(
      //         controller: internalCommentController,
      //         hintText: 'Internal Comment',
      //         maxLines: 3,
      //       ),

      //       const SizedBox(height: 16),

      //       _buildSaveButton(),
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildActivityDropdown(double height) {
    if (isLoadingActivities) {
      return Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: SizedBox(
          height: height,
          child: DropdownButtonFormField<UpdateActivityOption>(
            value: selectedActivity,
            isExpanded: true,
            isDense: true,
            items: activityOptions.map((activity) {
              return DropdownMenuItem<UpdateActivityOption>(
                value: activity,
                child: Text(
                  activity.description,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: activityOptions.isEmpty ? null : _onActivityChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10),
              hintText: 'Activity',
              hintStyle: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: TextField(
          controller: controller,
          minLines: maxLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }

  // Widget _buildActivitySpecificSection(double fieldHeight) {
  //   switch (selectedActivity?.normalizedCode) {
  //     case '1':
  //       return _buildFixedAppointmentSection(fieldHeight);

  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }

  Widget _buildActivitySpecificSection(double fieldHeight) {
    switch (selectedActivity?.normalizedCode) {
      case '1':
        return _buildFixedAppointmentSection(fieldHeight);

      case '35':
        return _buildLeadConvertedSection(fieldHeight);

      default:
        return _buildConfiguredActivitySection(fieldHeight);
    }
  }

  Widget _buildConfiguredActivitySection(double fieldHeight) {
    final config = selectedFormConfig;

    if (selectedActivity == null) {
      return const SizedBox.shrink();
    }

    if (config == null) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text(
          'Activity form configuration not available.',
          style: TextStyle(color: Colors.red, fontSize: 13),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.requiresSubActivity) _buildSubActivityDropdown(fieldHeight),

        if (config.requiresSubActivity && subActivityLoadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              subActivityLoadError!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),

        UpdateActivityFormBuilder(
          config: config,
          values: configuredFormValues,
          controllers: configuredFormControllers,
          dropdownOptions: configuredDropdownOptions,
          loadingDropdownFields: loadingConfiguredDropdownFields,
          onValueChanged: _onConfiguredValueChanged,
          onDateFieldTap: _onConfiguredDateFieldTap,
        ),
      ],
    );
  }

  Widget _buildLeadConvertedSection(double fieldHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubActivityDropdown(fieldHeight),

        if (subActivityLoadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              subActivityLoadError!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),

        _buildLabel('Issued Policy Number *'),
        _buildTextField(
          controller: issuedPolicyNumberController,
          hintText: 'Issued Policy Number',
        ),

        _buildLabel('Remark *'),
        _buildTextField(
          controller: leadConvertedRemarkController,
          hintText: 'Remark',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSubActivityDropdown(double fieldHeight) {
    // _buildLabel('Sub Activity *');

    if (isLoadingSubActivities) {
      return Container(
        height: fieldHeight,
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Sub Activity *'),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            child: SizedBox(
              height: fieldHeight,
              child: DropdownButtonFormField<UpdateActivityOption>(
                value: selectedSubActivity,
                isExpanded: true,
                isDense: true,
                items: subActivityOptions.map((option) {
                  return DropdownMenuItem<UpdateActivityOption>(
                    value: option,
                    child: Text(
                      option.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: subActivityOptions.isEmpty
                    ? null
                    : (option) async {
                        setState(() {
                          selectedSubActivity = option;

                          configuredFormValues['SubActivityCode'] =
                              option?.code ?? '';

                          configuredFormValues['SubActivityDescription'] =
                              option?.description ?? '';

                          _clearHiddenConfiguredValues();
                        });

                        await _loadVisibleConfiguredDropdowns();

                        if (option != null) {
                          debugPrint(
                            'Selected Sub Activity: '
                            '${option.code} - ${option.description}',
                          );
                        }
                      },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                  hintText: 'Sub Activity',
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedAppointmentSection(double fieldHeight) {
    if (_isRq17LeadSource29) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Appointment Date & Time *'),
          _buildDateTimeField(
            controller: appointmentDateTimeController,
            hintText: 'Appointment Date & Time',
            onTap: _selectAppointmentDateTime,
          ),
        ],
      );
    }

    if (isLoadingAppointmentThrough) {
      return Container(
        height: fieldHeight,
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Appointment Through *'),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            child: SizedBox(
              height: fieldHeight,
              child: DropdownButtonFormField<UpdateActivityLookupOption>(
                value: selectedAppointmentThrough,
                isExpanded: true,
                isDense: true,
                items: appointmentThroughOptions.map((option) {
                  return DropdownMenuItem<UpdateActivityLookupOption>(
                    value: option,
                    child: Text(
                      option.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),

                // onChanged: appointmentThroughOptions.isEmpty
                //     ? null
                //     : (option) {
                //         setState(() {
                //           selectedAppointmentThrough = option;
                //         });

                //         if (option != null) {
                //           debugPrint(
                //             'Selected AppThrough: '
                //             '${option.code} - '
                //             '${option.description}',
                //           );
                //         }
                //       },
                onChanged: appointmentThroughOptions.isEmpty
                    ? null
                    : _onAppointmentThroughChanged,

                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10),
                  hintText: 'Appointment Through',
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        if (appointmentThroughOptions.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Appointment Through data not available.',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),

        if (selectedAppointmentThrough?.code == '1') ...[
          _buildLabel('Phone Number *'),
          _buildPhoneField(
            controller: appointmentPhoneController,
            hintText: 'Phone Number',
          ),
        ],

        if (selectedAppointmentThrough?.code == '2') ...[
          _buildLabel('Appointment Address *'),
          _buildTextField(
            controller: appointmentAddressController,
            hintText: 'Appointment Address',
          ),
        ],

        if (selectedAppointmentThrough?.code == '1' ||
            selectedAppointmentThrough?.code == '2') ...[
          _buildLabel('Appointment Date & Time *'),
          _buildDateTimeField(
            controller: appointmentDateTimeController,
            hintText: 'Appointment Date & Time',
            onTap: _selectAppointmentDateTime,
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          maxLength: 15,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hintText,
            counterText: '',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
            suffixIcon: const Icon(Icons.calendar_month),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateFixedAppointment() {
    final appointmentDate = appointmentDateTimeController.text.trim();

    // Android special condition:
    // RQ17 + Lead Source 29 only requires appointment date.
    if (_isRq17LeadSource29) {
      if (appointmentDate.isEmpty) {
        return 'Please select appointment date';
      }

      return null;
    }

    if (selectedAppointmentThrough == null) {
      return 'Please select Appointment Through';
    }

    if (selectedAppointmentThrough!.description.trim().toLowerCase() ==
        '-----select-----') {
      return 'Please select Appointment Through';
    }

    final throughCode = selectedAppointmentThrough!.code.trim();

    if (throughCode == '1') {
      final phone = appointmentPhoneController.text.trim();

      if (phone.isEmpty) {
        return 'Please enter Phone Number';
      }

      // The field already accepts digits only and has maxLength 15.
      if (phone.length < 10 || !RegExp(r'^\d{10,15}$').hasMatch(phone)) {
        return 'Please enter a valid Phone Number';
      }
    }

    if (appointmentDate.isEmpty) {
      return 'Please select Appointment Date & Time';
    }

    if (throughCode == '2' &&
        appointmentAddressController.text.trim().isEmpty) {
      return 'Please enter Appointment Address';
    }

    return null;
  }

  String? _validateLeadConverted() {
    if (selectedSubActivity == null) {
      return 'Please select Sub Activity';
    }

    final subActivityDescription = selectedSubActivity!.description
        .trim()
        .toLowerCase();

    if (subActivityDescription == '-----select-----' ||
        subActivityDescription == 'select') {
      return 'Please select Sub Activity';
    }

    final policyNumber = issuedPolicyNumberController.text.trim();

    if (policyNumber.isEmpty) {
      return 'Please enter Issued Policy Number';
    }

    final remark = leadConvertedRemarkController.text.trim();

    if (remark.isEmpty) {
      return 'Please enter Remark';
    }

    return null;
  }

  String? _validateConfiguredActivity() {
    final config = selectedFormConfig;

    if (config == null) {
      return 'Activity form configuration not available.';
    }

    if (config.requiresSubActivity) {
      final description =
          selectedSubActivity?.description.trim().toLowerCase() ?? '';

      if (selectedSubActivity == null ||
          description.isEmpty ||
          description == 'select' ||
          description.contains('-----select')) {
        return 'Please select Sub Activity';
      }
    }

    final validatedFieldKeys = <String>{};

    for (final field in config.fields) {
      if (!field.isVisible(configuredFormValues)) {
        continue;
      }

      // Some conditional configurations use the same field key.
      if (!validatedFieldKeys.add(field.key)) {
        continue;
      }

      final value = configuredFormValues[field.key]?.toString().trim() ?? '';

      final isEmptyDropdown =
          field.type == UpdateActivityFieldType.dropdown &&
          _isEmptyConfiguredDropdownValue(value);

      if (field.isRequired && (value.isEmpty || isEmptyDropdown)) {
        return field.requiredMessage ?? 'Please enter ${field.label}';
      }

      if (value.isEmpty) {
        continue;
      }

      if (field.digitsOnly && !RegExp(r'^\d+$').hasMatch(value)) {
        return 'Please enter a valid ${field.label}';
      }

      if (field.minimumLength != null && value.length < field.minimumLength!) {
        return 'Please enter a valid ${field.label}';
      }

      if (field.maxLength != null && value.length > field.maxLength!) {
        return '${field.label} cannot exceed '
            '${field.maxLength} characters';
      }

      if (field.type == UpdateActivityFieldType.integer &&
          int.tryParse(value) == null) {
        return 'Please enter a valid ${field.label}';
      }

      if (field.type == UpdateActivityFieldType.decimal &&
          double.tryParse(value) == null) {
        return 'Please enter a valid ${field.label}';
      }
    }

    return null;
  }

  bool _isEmptyConfiguredDropdownValue(String value) {
    final normalizedValue = value.trim().toLowerCase();

    return normalizedValue.isEmpty ||
        normalizedValue == '0' ||
        normalizedValue == '-1' ||
        normalizedValue == 'select' ||
        normalizedValue.contains('-----select');
  }

  //new added after 14th june2026
  String _getConfiguredDropdownDescription(String fieldKey) {
    final selectedCode =
        configuredFormValues[fieldKey]?.toString().trim() ?? '';

    if (selectedCode.isEmpty) {
      return '';
    }

    final options =
        configuredDropdownOptions[fieldKey] ??
        const <UpdateActivityLookupOption>[];

    for (final option in options) {
      if (option.code.trim() == selectedCode) {
        return option.description.trim();
      }
    }

    return '';
  }

  UpdateActivityPayload? _buildConfiguredActivityPayload() {
    final activity = selectedActivity;
    final config = selectedFormConfig;

    if (activity == null || config == null) {
      return null;
    }

    final activityFields = <String, dynamic>{};
    final addedFieldKeys = <String>{};

    for (final field in config.fields) {
      if (!field.isVisible(configuredFormValues)) {
        continue;
      }

      // Some conditional fields use the same key.
      if (!addedFieldKeys.add(field.key)) {
        continue;
      }

      // activityFields[field.databaseColumn] =
      //     configuredFormValues[field.key]?.toString().trim() ?? '';

      final fieldValue =
          configuredFormValues[field.key]?.toString().trim() ?? '';

      activityFields[field.databaseColumn] = fieldValue;

      // Some Android legacy columns require the displayed
      // dropdown description instead of the selected code.
      if (field.type == UpdateActivityFieldType.dropdown) {
        activityFields['__${field.key}Description'] =
            _getConfiguredDropdownDescription(field.key);
      }
    }

    if (config.requiresSubActivity) {
      activityFields['SubActivityCode'] =
          selectedSubActivity?.code.trim() ?? '';
    }

    return UpdateActivityPayload(
      leadId: _decryptSafely(widget.lead['SrvcReqDtlCode']),
      tempLeadId: _decryptSafely(widget.lead['TempSrvcReqDtlCode']),
      activityCode: activity.code,
      normalizedActivityCode: activity.normalizedCode,
      createdBy: StaticVariables.mSAPCode,
      internalComment: internalCommentController.text.trim(),
      activityFields: activityFields,
    );
  }

  Future<void> _onSavePressed() async {
    if (blockedLeadStatus != null) {
      _showMessage(
        'This lead is already $blockedLeadStatus. '
        'Another activity cannot be updated.',
      );
      return;
    }
    final activity = selectedActivity;

    if (activity == null) {
      _showMessage('Please select Activity');
      return;
    }

    if (isSaving) {
      return;
    }

    switch (activity.normalizedCode) {
      case '1':
        final fixedAppointmentError = _validateFixedAppointment();

        if (fixedAppointmentError != null) {
          _showMessage(fixedAppointmentError);
          return;
        }

        await _saveFixedAppointment();
        break;

      case '35':
        final leadConvertedError = _validateLeadConverted();

        if (leadConvertedError != null) {
          _showMessage(leadConvertedError);
          return;
        }

        await _saveLeadConverted();
        break;

      default:
        final validationError = _validateConfiguredActivity();

        if (validationError != null) {
          _showMessage(validationError);
          return;
        }

        await _saveConfiguredActivity();
        break;
    }
  }

  Future<void> _saveActivityPayload(UpdateActivityPayload payload) async {
    if (!mounted) return;

    setState(() {
      isSaving = true;
    });

    try {
      final result = await _saveRepository.saveActivity(payload);

      if (!mounted) return;

      _showMessage(result.message);

      if (result.savedLocally) {
        debugPrint(
          'ACTIVITY SAVED: '
          '${payload.normalizedActivityCode} / '
          '${result.resolvedLeadId}',
        );

        Navigator.pop(context, true);
      }
    } catch (error, stackTrace) {
      debugPrint('Activity save failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('Unable to save Activity.');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> _saveFixedAppointment() async {
    final dateTime = selectedAppointmentDateTime;

    final leadId = _decryptSafely(widget.lead['SrvcReqDtlCode']);

    final tempLeadId = _decryptSafely(widget.lead['TempSrvcReqDtlCode']);

    final payload = UpdateActivityPayload(
      leadId: leadId,
      tempLeadId: tempLeadId,
      activityCode: selectedActivity?.code ?? '',
      normalizedActivityCode: selectedActivity?.normalizedCode ?? '',
      createdBy: StaticVariables.mSAPCode,
      internalComment: internalCommentController.text.trim(),
      activityFields: {
        'AppThrough': selectedAppointmentThrough?.code ?? '',
        'AppointmentDate': appointmentDateTimeController.text.trim(),
        'PhoneNumber': appointmentPhoneController.text.trim(),
        'AppointmentAddrss': appointmentAddressController.text.trim(),
        'Hour': dateTime == null
            ? ''
            : dateTime.hour.toString().padLeft(2, '0'),
        'Minute': dateTime == null
            ? ''
            : dateTime.minute.toString().padLeft(2, '0'),
      },
    );

    debugPrint('ACTIVITY 1 PAYLOAD: ${payload.toMap()}');

    setState(() {
      isSaving = true;
    });

    try {
      final result = await _saveRepository.saveActivity(payload);

      if (!mounted) return;

      _showMessage(result.message);

      if (result.savedLocally) {
        debugPrint(
          'ACTIVITY SAVED FOR LEAD: '
          '${result.resolvedLeadId}',
        );

        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('Activity save failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('Unable to save Activity.');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _printFixedAppointmentPayload() {
    final dateTime = selectedAppointmentDateTime;

    final leadId = widget.lead['SrvcReqDtlCode']?.toString().trim() ?? '';

    final tempLeadId =
        widget.lead['TempSrvcReqDtlCode']?.toString().trim() ?? '';

    final payload = UpdateActivityPayload(
      leadId: leadId,
      tempLeadId: tempLeadId,
      activityCode: selectedActivity?.code ?? '',
      normalizedActivityCode: selectedActivity?.normalizedCode ?? '',
      createdBy: StaticVariables.mSAPCode,
      internalComment: internalCommentController.text.trim(),
      activityFields: {
        'AppThrough': selectedAppointmentThrough?.code ?? '',
        'AppointmentDate': appointmentDateTimeController.text.trim(),
        'PhoneNumber': appointmentPhoneController.text.trim(),
        'AppointmentAddrss': appointmentAddressController.text.trim(),
        'Hour': dateTime == null
            ? ''
            : dateTime.hour.toString().padLeft(2, '0'),
        'Minute': dateTime == null
            ? ''
            : dateTime.minute.toString().padLeft(2, '0'),
      },
    );

    debugPrint('ACTIVITY 1 VALIDATION PASSED');
    debugPrint('ACTIVITY 1 PAYLOAD: ${payload.toMap()}');

    _showMessage('Validation passed. Payload created successfully.');
  }

  Future<void> _saveConfiguredActivity() async {
    final payload = _buildConfiguredActivityPayload();

    if (payload == null) {
      _showMessage('Unable to create Activity payload.');
      return;
    }

    debugPrint(
      'CONFIGURED ACTIVITY PAYLOAD: '
      '${payload.toMap()}',
    );

    await _saveActivityPayload(payload);
  }

  Future<void> _saveLeadConverted() async {
    final leadId = _decryptSafely(widget.lead['SrvcReqDtlCode']);

    final tempLeadId = _decryptSafely(widget.lead['TempSrvcReqDtlCode']);

    final payload = UpdateActivityPayload(
      leadId: leadId,
      tempLeadId: tempLeadId,
      activityCode: selectedActivity?.code ?? '',
      normalizedActivityCode: selectedActivity?.normalizedCode ?? '',
      createdBy: StaticVariables.mSAPCode,
      internalComment: internalCommentController.text.trim(),
      activityFields: {
        'SubActivityCode': selectedSubActivity?.code ?? '',
        'IssuedPolicyNo': issuedPolicyNumberController.text.trim(),
        'Remark': leadConvertedRemarkController.text.trim(),
      },
    );

    debugPrint('ACTIVITY 35 PAYLOAD: ${payload.toMap()}');

    await _saveActivityPayload(payload);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF17479E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: isLoadingActivities || isSaving ? null : _onSavePressed,
        child: isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
