import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_code_mapper.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_form_config.dart';

class UpdateActivityFormRegistry {
  const UpdateActivityFormRegistry._();

  static const Set<String> _allReasonCodes = {
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
  };

  static const List<UpdateActivityFormConfig> configs = [
    // -----------------------------------------------------------------
    // ACTIVITY 1 — FIX APPOINTMENT
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'activity_1_fixed_appointment',
      title: 'Fix Appointment',
      activityCodes: {'1'},
      activityGroup: UpdateActivityGroup.fixedAppointment,
      fields: [
        UpdateActivityFieldConfig(
          key: 'AppThrough',
          label: 'Appointment Through',
          hintText: 'Select Appointment Through',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'AppThrough',
          isRequired: true,
          requiredMessage: 'Please select Appointment Through',
        ),
        UpdateActivityFieldConfig(
          key: 'PhoneNumber',
          label: 'Phone Number',
          hintText: 'Enter Phone Number',
          type: UpdateActivityFieldType.phone,
          isRequired: true,
          requiredMessage: 'Please enter Phone Number',
          digitsOnly: true,
          minimumLength: 10,
          maxLength: 15,
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppThrough': {'1'},
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'AppointmentAddrss',
          label: 'Appointment Address',
          hintText: 'Enter Appointment Address',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Appointment Address',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppThrough': {'2'},
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'AppointmentDate',
          label: 'Appointment Date & Time',
          hintText: 'Select Appointment Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Appointment Date & Time',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppThrough': {'1', '2'},
            },
          ),
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // ACTIVITY 2 — RESCHEDULE APPOINTMENT
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'activity_2_reschedule_appointment',
      title: 'Reschedule Appointment',
      activityCodes: {'2'},
      activityGroup: UpdateActivityGroup.dateMovement,
      fields: [
        UpdateActivityFieldConfig(
          key: 'ResThrough',
          label: 'Reschedule Through',
          hintText: 'Select Reschedule Through',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'RsThrough',
          isRequired: true,
          requiredMessage: 'Please select Reschedule Through',
        ),

        UpdateActivityFieldConfig(
          key: 'RsReason',
          label: 'Reschedule Reason',
          hintText: 'Select Reschedule Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'ddlAppReason',
          isRequired: true,
          requiredMessage: 'Please select Reschedule Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'ResThrough': {'1', '2'},
            },
          ),
        ),

        // Date when ResThrough = 3
        UpdateActivityFieldConfig(
          key: 'RescheduleDate',
          label: 'Reschedule Date & Time',
          hintText: 'Select Reschedule Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Reschedule Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'ResThrough': {'3'},
            },
          ),
        ),

        // Date when ResThrough = 1 or 2 and a reason is selected
        UpdateActivityFieldConfig(
          key: 'RescheduleDate',
          label: 'Reschedule Date & Time',
          hintText: 'Select Reschedule Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Reschedule Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'ResThrough': {'1', '2'},
              'RsReason': _allReasonCodes,
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'PhoneNumber',
          label: 'Phone Number',
          hintText: 'Enter Phone Number',
          type: UpdateActivityFieldType.phone,
          isRequired: true,
          requiredMessage: 'Please enter valid Phone Number',
          digitsOnly: true,
          minimumLength: 10,
          maxLength: 15,
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'ResThrough': {'1'},
              'RsReason': _allReasonCodes,
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'RescheduleAddrss',
          label: 'Reschedule Address',
          hintText: 'Enter Reschedule Address',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Reschedule Address',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'ResThrough': {'2'},
              'RsReason': _allReasonCodes,
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'RescheduleAddrss',
          label: 'Reschedule Address',
          hintText: 'Enter Reschedule Address',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Reschedule Address',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'ResThrough': {'3'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'CallBackDate',
          label: 'Call Back Date & Time',
          hintText: 'Select Call Back Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Call Back Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'ResThrough': {'1', '2'},
              'RsReason': {'5', '19'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'TicketNo',
          label: 'Ticket Number',
          hintText: 'Enter Ticket Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Ticket Number',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'RsReason': {'8'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'MakenModel',
          label: 'Make',
          hintText: 'Select Make',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'MAKE_MASTER',
          isRequired: true,
          requiredMessage: 'Please select Make',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'RsReason': {'8'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'ModelValue',
          label: 'Model',
          hintText: 'Select Model',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'MODEL_MASTER',
          isRequired: true,
          requiredMessage: 'Please select Model',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'RsReason': {'8'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'ExpiryDate',
          label: 'Policy Expiry Date',
          hintText: 'Select Policy Expiry Date',
          type: UpdateActivityFieldType.date,
          isRequired: true,
          requiredMessage: 'Please select Policy Expiry Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'RsReason': {'15'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'InfectionID',
          label: 'Inspection ID',
          hintText: 'Enter Inspection ID',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Inspection ID',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'RsReason': {'16'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'QuoteNo',
          label: 'Quote Number',
          hintText: 'Enter Quote Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Quote Number',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'RsReason': {'17'},
            },
          ),
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // ACTIVITY 3 — PARKED LEAD
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'activity_3_parked_lead',
      title: 'Parked Lead',
      activityCodes: {'3'},
      activityGroup: UpdateActivityGroup.parkedOrLost,
      fields: [
        UpdateActivityFieldConfig(
          key: 'ParkedLead',
          label: 'Parked Lead Reason',
          hintText: 'Select Parked Lead Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'ParkedLead',
          isRequired: true,
          requiredMessage: 'Please select Parked Lead Reason',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // ACTIVITY 4 — CONVERT LEAD
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'activity_4_convert_lead',
      title: 'Convert Lead',
      activityCodes: {'4'},
      activityGroup: UpdateActivityGroup.converted,
      fields: [
        UpdateActivityFieldConfig(
          key: 'LcReason',
          label: 'Lead Converted Reason',
          hintText: 'Select Lead Converted Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'LCReason',
          isRequired: true,
          requiredMessage: 'Please select Lead Converted Reason',
        ),
        UpdateActivityFieldConfig(
          key: 'LcSubReason',
          label: 'Lead Converted Sub Reason',
          hintText: 'Select Lead Converted Sub Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'LCSubReason',
          isRequired: true,
          requiredMessage: 'Please select Lead Converted Sub Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'LcReason': {'5'},
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'ProposalNo',
          label: 'Proposal / Covernote Number',
          hintText: 'Enter Proposal / Covernote Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Proposal / Covernote Number',
        ),
        UpdateActivityFieldConfig(
          key: 'IssuedPolicyNo',
          label: 'Issued Policy Number',
          hintText: 'Enter Issued Policy Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Issued Policy Number',
        ),
        UpdateActivityFieldConfig(
          key: 'PremiumCollected',
          label: 'Premium Collected',
          hintText: 'Enter Premium Collected',
          type: UpdateActivityFieldType.decimal,
          isRequired: true,
          requiredMessage: 'Please enter Premium Collected',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // ACTIVITY 5 — LEAD LOST
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'activity_5_lead_lost',
      title: 'Lead Lost',
      activityCodes: {'5'},
      activityGroup: UpdateActivityGroup.parkedOrLost,
      fields: [
        UpdateActivityFieldConfig(
          key: 'AppReason',
          label: 'Appropriate Reason',
          hintText: 'Select Appropriate Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'AppReason',
          isRequired: true,
          requiredMessage: 'Please select Appropriate Reason',
        ),

        UpdateActivityFieldConfig(
          key: 'SubReason',
          label: 'Appropriate Sub Reason',
          hintText: 'Select Appropriate Sub Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'SubReason',
          isRequired: true,
          requiredMessage: 'Please select Appropriate Sub Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'1'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'SubReason',
          label: 'Appropriate Sub Reason',
          hintText: 'Select Appropriate Sub Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'NCSubreason',
          isRequired: true,
          requiredMessage: 'Please select Appropriate Sub Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'5'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'SubReason',
          label: 'Appropriate Sub Reason',
          hintText: 'Select Appropriate Sub Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'NiSubReason',
          isRequired: true,
          requiredMessage: 'Please select Appropriate Sub Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'SubReason',
          label: 'Appropriate Sub Reason',
          hintText: 'Select Appropriate Sub Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'NESubReason11',
          isRequired: true,
          requiredMessage: 'Please select Appropriate Sub Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'SubReason',
          label: 'Appropriate Sub Reason',
          hintText: 'Select Appropriate Sub Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'PPQSubReason',
          isRequired: true,
          requiredMessage: 'Please select Appropriate Sub Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'17'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'DuplicateLeadId',
          label: 'Duplicate Lead ID',
          hintText: 'Enter Duplicate Lead ID',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Duplicate Lead ID',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'2'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'ComptitorID',
          label: 'Competitor',
          hintText: 'Select Competitor',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'ComptitorID',
          isRequired: true,
          requiredMessage: 'Please select Competitor',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'3'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'LocationDtls',
          label: 'Location Details',
          hintText: 'Enter Location Details',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Location Details',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
            },
          ),
        ),

        // AppReason 6 subreason-specific fields
        UpdateActivityFieldConfig(
          key: 'ComptitorID',
          label: 'Competitor',
          hintText: 'Select Competitor',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'ComptitorID',
          isRequired: true,
          requiredMessage: 'Please select Competitor',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'2', '4', '9', '12'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Reason',
          label: 'Reason',
          hintText: 'Enter Reason',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'2', '4'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Feature',
          label: 'Features',
          hintText: 'Enter Features',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Features',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'9'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Price',
          label: 'Price',
          hintText: 'Enter Price',
          type: UpdateActivityFieldType.decimal,
          isRequired: true,
          requiredMessage: 'Please enter Price',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'12'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'TicketNo',
          label: 'Ticket Number',
          hintText: 'Enter Ticket Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Ticket Number',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'15'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'ProductType',
          label: 'Product Type',
          hintText: 'Enter Product Type',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Product Type',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'16'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'MakenModel',
          label: 'Make',
          hintText: 'Select Make',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'MAKE_MASTER',
          isRequired: true,
          requiredMessage: 'Please select Make',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'18'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'ModelValue',
          label: 'Model',
          hintText: 'Select Model',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'MODEL_MASTER',
          isRequired: true,
          requiredMessage: 'Please select Model',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'18'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Area',
          label: 'Area',
          hintText: 'Enter Area',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Area',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'6'},
              'SubReason': {'18'},
            },
          ),
        ),

        // AppReason 16 subreason-specific fields
        UpdateActivityFieldConfig(
          key: 'Age',
          label: 'Age',
          hintText: 'Enter Age',
          type: UpdateActivityFieldType.integer,
          isRequired: true,
          requiredMessage: 'Please enter Age',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
              'SubReason': {'1'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'YOM',
          label: 'Year of Manufacture',
          hintText: 'Enter Year of Manufacture',
          type: UpdateActivityFieldType.integer,
          isRequired: true,
          requiredMessage: 'Please enter Year of Manufacture',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
              'SubReason': {'3', '4'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Lan',
          label: 'Language',
          hintText: 'Enter Language',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Language',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
              'SubReason': {'8'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'PHC_NO',
          label: 'PHC Number',
          hintText: 'Enter PHC Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter PHC Number',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
              'SubReason': {'9'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'RtoLoc',
          label: 'RTO Location',
          hintText: 'Select RTO Location',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'RTO_LOCATION_STATIC',
          isRequired: true,
          requiredMessage: 'Please select RTO Location',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
              'SubReason': {'11'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'PED',
          label: 'PED',
          hintText: 'Enter PED',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter PED',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
              'SubReason': {'16'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Reason',
          label: 'Reason',
          hintText: 'Enter Reason',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'16'},
              'SubReason': {'13', '14', '18'},
            },
          ),
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // RQ17 + LEAD SOURCE 37 — ACTIVITY 16
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'rq17_source37_activity_16',
      title: 'Non Contactable',
      activityCodes: {'16'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'37'},
      activityGroup: UpdateActivityGroup.specialConditional,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'AppReason',
          label: 'Non Contactable Reason',
          hintText: 'Select Non Contactable Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'CP1',
          isRequired: true,
          requiredMessage: 'Please select Non Contactable Reason',
        ),

        UpdateActivityFieldConfig(
          key: 'SubReason',
          label: 'Non Contactable Sub Reason',
          hintText: 'Select Non Contactable Sub Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'CP2',
          isRequired: true,
          requiredMessage: 'Please select Non Contactable Sub Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'1', '4'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Reason',
          label: 'Appropriate Reason',
          hintText: 'Enter Appropriate Reason',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Appropriate Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'3'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Reason',
          label: 'Appropriate Reason',
          hintText: 'Enter Appropriate Reason',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Appropriate Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'1'},
              'SubReason': {'1'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'Reason',
          label: 'Appropriate Reason',
          hintText: 'Enter Appropriate Reason',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Appropriate Reason',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
              'SubReason': {'2'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'AppointmentDate',
          label: 'Appointment Date & Time',
          hintText: 'Select Appointment Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Appointment Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'2'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'PhoneNumber',
          label: 'Phone Number',
          hintText: 'Enter Phone Number',
          type: UpdateActivityFieldType.phone,
          isRequired: true,
          requiredMessage: 'Please enter valid Phone Number',
          digitsOnly: true,
          minimumLength: 10,
          maxLength: 15,
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'2'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'AppointmentAddrss',
          label: 'Address',
          hintText: 'Enter Address',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Address',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'2'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'PhoneNumber',
          label: 'Phone Number',
          hintText: 'Enter Phone Number',
          type: UpdateActivityFieldType.phone,
          isRequired: true,
          requiredMessage: 'Please enter valid Phone Number',
          digitsOnly: true,
          minimumLength: 10,
          maxLength: 15,
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
              'SubReason': {'3', '5'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'AppointmentAddrss',
          label: 'Address',
          hintText: 'Enter Address',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Address',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
              'SubReason': {'3', '5'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'ExpiryDate',
          label: 'Policy Expiry Date',
          hintText: 'Select Policy Expiry Date',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Policy Expiry Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
              'SubReason': {'3'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'RegistrationNo',
          label: 'Vehicle Registration Number',
          hintText: 'Enter Vehicle Registration Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Vehicle Registration Number',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
              'SubReason': {'3'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'MakenModel',
          label: 'Make',
          hintText: 'Select Make',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'MAKE_MASTER',
          isRequired: true,
          requiredMessage: 'Please select Make',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
              'SubReason': {'3'},
            },
          ),
        ),

        UpdateActivityFieldConfig(
          key: 'ModelValue',
          label: 'Model',
          hintText: 'Select Model',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'MODEL_MASTER',
          isRequired: true,
          requiredMessage: 'Please select Model',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'AppReason': {'4'},
              'SubReason': {'3'},
            },
          ),
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // RQ17 + LEAD SOURCE 37 — ACTIVITY 17
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'rq17_source37_activity_17',
      title: 'Lead Converted',
      activityCodes: {'17'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'37'},
      activityGroup: UpdateActivityGroup.converted,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'LcReason',
          label: 'Lead Converted Reason',
          hintText: 'Select Lead Converted Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'LCCSReason',
          isRequired: true,
          requiredMessage: 'Please select Lead Converted Reason',
        ),
        UpdateActivityFieldConfig(
          key: 'IssuedPolicyNo',
          label: 'Issued Policy Number',
          hintText: 'Enter Issued Policy Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Issued Policy Number',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'LcReason': {'1'},
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'ProposalNo',
          label: 'Proposal / Covernote Number',
          hintText: 'Enter Proposal / Covernote Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Proposal / Covernote Number',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'LcReason': {'1'},
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'PremiumCollected',
          label: 'Premium Collected',
          hintText: 'Enter Premium Collected',
          type: UpdateActivityFieldType.decimal,
          isRequired: true,
          requiredMessage: 'Please enter Premium Collected',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'LcReason': {'1'},
            },
          ),
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // RQ17 + LEAD SOURCE 37 — ACTIVITY 18
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'rq17_source37_activity_18',
      title: 'Lead Lost',
      activityCodes: {'18'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'37'},
      activityGroup: UpdateActivityGroup.parkedOrLost,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'AppReason',
          label: 'Lead Lost Reason',
          hintText: 'Select Lead Lost Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'AppReason18',
          isRequired: true,
          requiredMessage: 'Please select Lead Lost Reason',
        ),
        UpdateActivityFieldConfig(
          key: 'Reason',
          label: 'Lead Lost Reason Details',
          hintText: 'Enter Lead Lost Reason',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Lead Lost Reason',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // RQ17 + LEAD SOURCE 37 — ACTIVITY 19
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'rq17_source37_activity_19',
      title: 'Call Back',
      activityCodes: {'19'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'37'},
      activityGroup: UpdateActivityGroup.dateMovement,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'CallBackDate',
          label: 'Call Back Date & Time',
          hintText: 'Select Call Back Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Call Back Date',
        ),
        UpdateActivityFieldConfig(
          key: 'PhoneNumber',
          label: 'Call Back Phone Number',
          hintText: 'Enter Call Back Phone Number',
          type: UpdateActivityFieldType.phone,
          isRequired: true,
          requiredMessage: 'Please enter Call Back Phone Number',
          digitsOnly: true,
          minimumLength: 10,
          maxLength: 15,
        ),
        UpdateActivityFieldConfig(
          key: 'AppointmentAddrss',
          label: 'Call Back Address',
          hintText: 'Enter Call Back Address',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Call Back Address',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // RQ17 + LEAD SOURCE 29 — ACTIVITIES 20–26
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'rq17_source29_activity_20',
      title: 'Fixed Appointment',
      activityCodes: {'20'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'29'},
      activityGroup: UpdateActivityGroup.dateMovement,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'AppointmentDate',
          label: 'Fixed Appointment Date & Time',
          hintText: 'Select Fixed Appointment Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Fixed Appointment Date',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq17_source29_activity_21',
      title: 'Call Back',
      activityCodes: {'21'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'29'},
      activityGroup: UpdateActivityGroup.dateMovement,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'CallBackDate',
          label: 'Call Back Date & Time',
          hintText: 'Select Call Back Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Call Back Date',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq17_source29_activity_22',
      title: 'Non Contactable',
      activityCodes: {'22'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'29'},
      activityGroup: UpdateActivityGroup.specialConditional,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'NonConRes',
          label: 'Non Contactable Reason',
          hintText: 'Select Non Contactable Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'NCNT',
          isRequired: true,
          requiredMessage: 'Please select Non Contactable Reason',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq17_source29_activity_23',
      title: 'Cheque Collected Awaiting Clearance',
      activityCodes: {'23'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'29'},
      activityGroup: UpdateActivityGroup.specialConditional,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'ChequeNo',
          label: 'Cheque Collected Awaiting Clearance',
          hintText: 'Enter Cheque Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage:
              'Please enter Cheque Collected Awaiting Clearance',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq17_source29_activity_24',
      title: 'Renewal Lead Lost',
      activityCodes: {'24'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'29'},
      activityGroup: UpdateActivityGroup.parkedOrLost,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'RenewalLeadLostReason',
          label: 'Renewal Lead Lost Reason',
          hintText: 'Select Renewal Lead Lost Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'RNWL',
          isRequired: true,
          requiredMessage: 'Please select Renewal Lead Lost Reason',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq17_source29_activity_25',
      title: 'Policy Already Renewed',
      activityCodes: {'25'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'29'},
      activityGroup: UpdateActivityGroup.specialConditional,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'PolicyAlreadyRenewedReason',
          label: 'Policy Already Renewed Reason',
          hintText: 'Select Policy Already Renewed Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'POLA',
          isRequired: true,
          requiredMessage:
              'Please select Policy Already Renewed Reason',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq17_source29_activity_26',
      title: 'Contact Verified',
      activityCodes: {'26'},
      requestChannelIds: {'RQ17'},
      leadSourceIds: {'29'},
      activityGroup: UpdateActivityGroup.specialConditional,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'txtRMSMobileNo',
          label: 'Mobile Number',
          hintText: 'Enter Mobile Number',
          type: UpdateActivityFieldType.phone,
          isRequired: true,
          requiredMessage: 'Please enter valid Mobile Number',
          digitsOnly: true,
          minimumLength: 10,
          maxLength: 10,
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // RQ11 + LEAD SOURCE 40 — ACTIVITIES 27–33
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'rq11_source40_activity_27',
      title: 'Appointment Fixed',
      activityCodes: {'27'},
      requestChannelIds: {'RQ11'},
      leadSourceIds: {'40'},
      activityGroup: UpdateActivityGroup.dateMovement,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'AppointmentDate',
          label: 'Appointment Fixed Date & Time',
          hintText: 'Select Appointment Fixed Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Appointment Fixed Date',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq11_source40_activity_28',
      title: 'Reschedule Appointment',
      activityCodes: {'28'},
      requestChannelIds: {'RQ11'},
      leadSourceIds: {'40'},
      activityGroup: UpdateActivityGroup.dateMovement,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'RescheduleDate',
          label: 'Reschedule Appointment Date & Time',
          hintText: 'Select Reschedule Appointment Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Reschedule Appointment Date',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq11_source40_activity_29',
      title: 'Lead Lost',
      activityCodes: {'29'},
      requestChannelIds: {'RQ11'},
      leadSourceIds: {'40'},
      activityGroup: UpdateActivityGroup.parkedOrLost,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'LcReason',
          label: 'Lead Lost Reason',
          hintText: 'Select Lead Lost Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'AppReason29',
          isRequired: true,
          requiredMessage: 'Please select Lead Lost Reason',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq11_source40_activity_30',
      title: 'Lead Converted',
      activityCodes: {'30'},
      requestChannelIds: {'RQ11'},
      leadSourceIds: {'40'},
      activityGroup: UpdateActivityGroup.converted,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'ProposalNo',
          label: 'Policy Number / Proposal Number',
          hintText: 'Enter Policy Number / Proposal Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage:
              'Please enter Policy Number / Proposal Number',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq11_source40_activity_31',
      title: 'Parked Lead',
      activityCodes: {'31'},
      requestChannelIds: {'RQ11'},
      leadSourceIds: {'40'},
      activityGroup: UpdateActivityGroup.parkedOrLost,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'ParkedLeadDateTime',
          label: 'Parked Date & Time',
          hintText: 'Select Parked Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Parked Date',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq11_source40_activity_32',
      title: 'Follow Up',
      activityCodes: {'32'},
      requestChannelIds: {'RQ11'},
      leadSourceIds: {'40'},
      activityGroup: UpdateActivityGroup.dateMovement,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'FollowupDt',
          label: 'Follow Up Date & Time',
          hintText: 'Select Follow Up Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage: 'Please select Follow Up Date',
        ),
      ],
    ),

    UpdateActivityFormConfig(
      id: 'rq11_source40_activity_33',
      title: 'Quotation Given - Follow Up',
      activityCodes: {'33'},
      requestChannelIds: {'RQ11'},
      leadSourceIds: {'40'},
      activityGroup: UpdateActivityGroup.specialConditional,
      priority: 100,
      fields: [
        UpdateActivityFieldConfig(
          key: 'QutationDt',
          label: 'Quotation Given - Follow Up Date & Time',
          hintText: 'Select Quotation Given - Follow Up Date & Time',
          type: UpdateActivityFieldType.dateTime,
          isRequired: true,
          requiredMessage:
              'Please select Quotation Given - Follow Up Date',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // DYNAMIC ACTIVITY 35 — LEAD CONVERTED
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'dynamic_activity_35_lead_converted',
      title: 'Lead Converted',
      activityCodes: {'35'},
      activityGroup: UpdateActivityGroup.converted,
      requiresSubActivity: true,
      priority: 200,
      fields: [
        UpdateActivityFieldConfig(
          key: 'IssuedPolicyNo',
          label: 'Issued Policy Number',
          hintText: 'Enter Issued Policy Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Issued Policy Number',
        ),
        UpdateActivityFieldConfig(
          key: 'Remark',
          label: 'Remark',
          hintText: 'Enter Remark',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Remark',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // DYNAMIC ACTIVITY 36 — SALE CLOSED
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'dynamic_activity_36_sale_closed',
      title: 'Sale Closed',
      activityCodes: {'36'},
      activityGroup: UpdateActivityGroup.saleClosed,
      requiresSubActivity: true,
      priority: 200,
      fields: [
        UpdateActivityFieldConfig(
          key: 'IssuedPolicyNo',
          label: 'Policy Number',
          hintText: 'Enter Policy Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Policy Number',
        ),
        UpdateActivityFieldConfig(
          key: 'InstType',
          label: 'Instrument Type',
          hintText: 'Select Instrument Type',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'INTTYP',
          isRequired: true,
          requiredMessage: 'Please select Instrument Type',
        ),
        UpdateActivityFieldConfig(
          key: 'ChequeNo',
          label: 'Instrument Number',
          hintText: 'Enter Instrument Number',
          type: UpdateActivityFieldType.text,
          isRequired: true,
          requiredMessage: 'Please enter Instrument Number',
        ),
        UpdateActivityFieldConfig(
          key: 'PremiumCollected',
          label: 'Instrument Amount',
          hintText: 'Enter Instrument Amount',
          type: UpdateActivityFieldType.decimal,
          isRequired: true,
          requiredMessage: 'Please enter Instrument Amount',
        ),
        UpdateActivityFieldConfig(
          key: 'Remark',
          label: 'Remark',
          hintText: 'Enter Remark',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Remark',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // DYNAMIC ACTIVITY 37 — LEAD OPEN
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'dynamic_activity_37_lead_open',
      title: 'Lead Open',
      activityCodes: {'37'},
      activityGroup: UpdateActivityGroup.leadOpen,
      requiresSubActivity: true,
      priority: 200,
      fields: [
        UpdateActivityFieldConfig(
          key: 'CallBackDate',
          label: 'Call Back Date',
          hintText: 'Select Call Back Date',
          type: UpdateActivityFieldType.date,
          isRequired: true,
          requiredMessage: 'Please select Call Back Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'SubActivityDescription': {'Call Back'},
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'AppointmentDate',
          label: 'Appointment Date',
          hintText: 'Select Appointment Date',
          type: UpdateActivityFieldType.date,
          isRequired: true,
          requiredMessage: 'Please select Appointment Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'SubActivityDescription': {'Appointment Fixed'},
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'ExpectedClosureDate',
          label: 'Expected Closure Date',
          hintText: 'Select Expected Closure Date',
          type: UpdateActivityFieldType.date,
          isRequired: true,
          requiredMessage: 'Please select Expected Closure Date',
          visibilityCondition: UpdateActivityFieldCondition(
            allowedValuesByField: {
              'SubActivityDescription': {
                'Call Back',
                'Appointment Fixed',
              },
            },
          ),
        ),
        UpdateActivityFieldConfig(
          key: 'Remark',
          label: 'Remark',
          hintText: 'Enter Remark',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Remark',
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // DYNAMIC ACTIVITY 38 — LEAD LOST
    // -----------------------------------------------------------------
    UpdateActivityFormConfig(
      id: 'dynamic_activity_38_lead_lost',
      title: 'Lead Lost',
      activityCodes: {'38'},
      activityGroup: UpdateActivityGroup.leadLost,
      requiresSubActivity: true,
      priority: 200,
      fields: [
        UpdateActivityFieldConfig(
          key: 'LstComDueTo',
          label: 'Lost Due To',
          hintText: 'Select Lost Reason',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'LTCOM',
          isRequired: true,
          requiredMessage: 'Please select Lost Reason',
        ),
        UpdateActivityFieldConfig(
          key: 'ComptitorID',
          label: 'Company Name of Competitor',
          hintText: 'Select Competitor',
          type: UpdateActivityFieldType.dropdown,
          lookupCode: 'ComptitorID',
          isRequired: true,
          requiredMessage: 'Please select Competitor',
        ),
        UpdateActivityFieldConfig(
          key: 'NewPolEndDate',
          label: 'New Policy End Date',
          hintText: 'Select New Policy End Date',
          type: UpdateActivityFieldType.date,
          isRequired: true,
          requiredMessage: 'Please select New Policy End Date',
        ),
        UpdateActivityFieldConfig(
          key: 'Remark',
          label: 'Remark',
          hintText: 'Enter Remark',
          type: UpdateActivityFieldType.multilineText,
          isRequired: true,
          requiredMessage: 'Please enter Remark',
        ),
      ],
    ),
  ];

  static UpdateActivityFormConfig? find(
    UpdateActivityFormContext context,
  ) {
    final matchedConfigs = configs
        .where((config) => config.matches(context))
        .toList()
      ..sort(
        (first, second) =>
            second.priority.compareTo(first.priority),
      );

    if (matchedConfigs.isEmpty) {
      return null;
    }

    return matchedConfigs.first;
  }

  static UpdateActivityFormConfig? findByValues({
    required String activityCode,
    String requestChannelId = '',
    String leadSourceId = '',
    String leadType = '',
    String businessType = '',
  }) {
    return find(
      UpdateActivityFormContext(
        activityCode: activityCode,
        requestChannelId: requestChannelId,
        leadSourceId: leadSourceId,
        leadType: leadType,
        businessType: businessType,
      ),
    );
  }

  static bool supportsActivity(
    UpdateActivityFormContext context,
  ) {
    return find(context) != null;
  }
}