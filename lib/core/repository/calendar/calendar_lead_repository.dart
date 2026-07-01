import 'package:flutter/foundation.dart';
import 'package:flutter_bottom_nav/core/apicall/async_get_LeadDataForUser.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/database/offline_db_helper.dart';
import 'package:flutter_bottom_nav/models/Calendar/calendar_lead_args.dart';
import 'package:flutter_bottom_nav/models/Calendar/lead_card_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class CalendarLeadRepository {
  final DatabaseHelper _databaseHelper;

  CalendarLeadRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  static final Map<String, String> _activityDescriptionCache = {};

  //new add
  Future<void> syncLeadsFromApi({
    required CalendarLeadArgs args,
    required String userId,
  }) async {
    // Remove "All" and empty Sales Manager selections.
    final selectedSalesManagers = args.filters.salesManager
        .map((value) => value.trim())
        .where(
          (value) =>
              value.isNotEmpty &&
              value.toLowerCase() != 'all' &&
              value.toLowerCase() != 'null',
        )
        .toList();

    // Android uses selected Sales Manager SAP code when available.
    // Otherwise, it uses the logged-in user's SAP code.
    final apiSapCode = selectedSalesManagers.isNotEmpty
        ? selectedSalesManagers.first
        : userId.trim();

    // Android passes strTitle, which is the clicked calendar date.
    final selectedDate = DateFormat('dd-MM-yyyy').format(args.selectedDate);

    final response = await GetLeadDataForUser(
      sapCode: apiSapCode,
      CurrentMonth: selectedDate,
      callerId: StaticVariables.callerId,
      callerPass: StaticVariables.callerPass!,
      tokenId: StaticVariables.TokenId,
    );

    if (response.isEmpty) {
      throw Exception('GetLeadDataForUser returned an empty response.');
    }

    final leadRows = _extractLeadRows(response);

    debugPrint('GetLeadDataForUser returned ${leadRows.length} records.');

    if (leadRows.isEmpty) {
      debugPrint('No lead records received for $selectedDate.');
      return;
    }

    await _saveLeadDetails(leadRows);

    // Next step:
    // Parse response["Table"] and save records into:
    // 1. LeadDetails
    // 2. LMSLeadActivityTracker
  }

  List<Map<String, dynamic>> _extractLeadRows(Map<String, dynamic> response) {
    final dynamic tableData = response['Table'];

    if (tableData == null) {
      return [];
    }

    if (tableData is List) {
      return tableData
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }

    return [];
  }

  // Map<String, dynamic> _buildLeadDetailsMap(Map<String, dynamic> row) {
  //   return {
  //     'SrvcReqDtlCode': row['SrvcReqDtlCode'],
  //     'UserId': row['UserId'],
  //     'BusinessType': row['BusinessType'],
  //     'Name': row['Name'],
  //     'ProdName': row['ProdName'],
  //     'PolicyNo': row['PolicyNo'],
  //     'InstallmentPrem': row['InstallmentPrem'],
  //     'PolNCB': row['PolNCB'],
  //     'Make': row['Make'],
  //     'Model': row['Model'],
  //     'ActivityStatus': row['ActivityStatus'],
  //     'SrvcFromDTim': row['SrvcFromDTim'],
  //     'PolicyEndDate': row['PolicyEndDate'],
  //     'CreateDTim': row['CreateDTim'],
  //     'RenewalPaymentLink': row['RenewalPaymentLink'],
  //     'SumInsured': row['SumInsured'],
  //     'BMCMCode': row['BMCMCode'],
  //     'SMBranch': row['SMBranch'],
  //     'LOBCode': row['LOBCode'],
  //     'Zone': row['Zone'],
  //     'Region': row['Region'],
  //     'AgentCode': row['AgentCode'],
  //     'HNINCode': row['HNINCode'],
  //     'ProductGroup': row['ProductGroup'],
  //     'ProductSubCategory': row['ProductSubCategory'],
  //     'RenewalYearCount': row['RenewalYearCount'],
  //     'NCBFlag': row['NCBFlag'],
  //     'Preferred': row['Preferred'],
  //     'NILDep': row['NILDep'],
  //     'Category': row['Category'],
  //     'FuelType': row['FuelType'],
  //     'VehicleType': row['VehicleType'],
  //     'SeatingCapacity': row['SeatingCapacity'],
  //     'AgeGroup': row['AgeGroup'],
  //     'FamilySize': row['FamilySize'],
  //     'SumInsuredBand': row['SumInsuredBand'],
  //     'PreExiting': row['PreExiting'],
  //     'Occupancy': row['Occupancy'],
  //     'LifeGroup': row['LifeGroup'],
  //     'ProdCode': row['ProdCode'],
  //     'LeadTypeDesc': row['LeadTypeDesc'],
  //     'LeadSource': row['LeadSource'],
  //     'ReqChannelId': row['ReqChannelId'],
  //   };
  // }

  Map<String, dynamic> _buildLeadDetailsMap(Map<String, dynamic> row) {
    return {
      'SrvcReqDtlCode': row['SrvcReqDtlCode'],
      'SrvcGrpCode': row['SrvcGrpCode'],
      'ActivityStatus': row['ActivityStatus'],
      'CltCode': row['CltCode'],
      'AgentCode': row['AgentCode'],
      'UserId': row['UserId']?.toString().toUpperCase(),

      'ReqChannel': row['ReqChannel'],
      'ReqChannelId': row['ReqChannelId'],

      'LOBCode': row['LOBCode'],
      'LOB': row['LOB'],

      'ProdCode': row['ProdCode'],

      'CRMStatus': row['CRMStatus'],
      'LMSStatusDesc': row['LMSStatusDesc'],

      'WFStatus': row['WFStatus'],
      'WFStatDesc': row['WFStatDesc'],

      'LeadSource': row['LeadSource'],
      'LeadSourceDesc': row['LeadSourceDesc'],

      'LeadSubSource': row['LeadSubSource'],
      'LeadSubSourceDesc': row['LeadSubSourceDesc'],

      'BusinessType': row['BusinessType'],
      'BusinessTypeDesc': row['BusinessTypeDesc'],

      'LeadQueue': row['LeadQueue'],
      'LeadQueueDesc': row['LeadQueueDesc'],

      'leadAmt': row['leadAmt'],

      'TypeFlag': row['TypeFlag'],
      'LeadTypeDesc': row['LeadTypeDesc'],
      'LeadStatusCode': row['LeadStatusCode'],

      'CustPriority': row['CustPriority'],
      'CustPriorityDesc': row['CustPriorityDesc'],

      'SaleType': row['SaleType'],
      'SaleTypeDesc': row['SaleTypeDesc'],

      'CreatedBy': row['CreatedBy'],
      'CreateDTim': row['CreateDTim'],
      'UpdatedBy': row['UpdatedBy'],
      'UpdateDTim': row['UpdateDTim'],

      'Remark': row['Remark'],

      'ProposalNo': row['ProposalNo'],
      'PolicyNo': row['PolicyNo'],

      'ProdName': row['ProdName'],

      'SumInsured': row['SumInsured'],

      'PolicyStatus': row['PolicyStatus'],
      'PolicyStartDate': row['PolicyStartDate'],
      'PolicyEndDate': row['PolicyEndDate'],

      'IssBranchCode': row['IssBranchCode'],
      'IssBranchName': row['IssBranchName'],

      'InstallmentPrem': row['InstallmentPrem'],

      'PrevPolicyNo': row['PrevPolicyNo'],
      'PrevPolicyInsCompName': row['PrevPolicyInsCompName'],

      'ProdClassCode': row['ProdClassCode'],
      'ProdClassName': row['ProdClassName'],

      'ChassisNo': row['ChassisNo'],
      'EngineNo': row['EngineNo'],
      'RegistrationNo': row['RegistrationNo'],

      'Make': row['Make'],
      'Model': row['Model'],

      'PlanName': row['PlanName'],

      'AgentName': row['AgentName'],

      'HNINCode': row['HNINCode'],
      'HNINName': row['HNINName'],

      'PolNCB': row['PolNCB'],

      'Name': row['Name'],

      'MobileTel': row['MobileTel'],
      'WorkTel': row['WorkTel'],
      'Email': row['Email'],

      'AddrType': row['AddrType'],
      'Addr1': row['Addr1'],
      'Addr2': row['Addr2'],
      'Addr3': row['Addr3'],

      'CityCode': row['CityCode'],
      'DistrictCode': row['DistrictCode'],
      'StateCode': row['StateCode'],
      'PinCode': row['PinCode'],
      'CountryCode': row['CountryCode'],

      'Area': row['Area'],

      'isWarmTransfer': row['isWarmTransfer'],

      'SrvcCommentType': row['SrvcCommentType'],
      'SrvcComments': row['SrvcComments'],
      'SrvcFromDTim': row['SrvcFromDTim'],

      'Breaking': row['Breaking'],

      'LeadRating': row['LeadRating'],

      'CustTypeDesc': row['CustTypeDesc'],

      'isOwner': row['isOwner'],
      'OwnerName': row['OwnerName'],

      'AssignedTo': row['AssignedTo'],
      'AssignedToName': row['AssignedToName'],

      'SyncStatus': 'Complete',

      // Filter fields
      'LeadType': row['LeadType'],
      'BizType': row['BizType'],
      'MarcketType': row['MarcketType'],
      'PolicyChanel': row['PolicyChanel'],

      'BMCMCode': row['BMCMCode'],

      'ircCode': row['ircCode'],
      'ircname': row['ircname'],

      'RNType': row['RNType'],

      'NetODPremium': row['NetODPremium'],
      'NetTPPremium': row['NetTPPremium'],

      'RNblockReason': row['RNblockReason'],

      'ProductGroup': row['ProductGroup'],
      'ProductSubCategory': row['ProductSubCategory'],

      'NCBFlag': row['NCBFlag'],
      'NILDep': row['NILDep'],

      'Category': row['Category'],
      'FuelType': row['FuelType'],
      'VehicleType': row['VehicleType'],

      'SeatingCapacity': row['SeatingCapacity'],

      'AgeGroup': row['AgeGroup'],
      'FamilySize': row['FamilySize'],

      'SumInsuredBand': row['SumInsuredBand'],

      'PreExiting': row['PreExiting'],

      'Occupancy': row['Occupancy'],

      'LifeGroup': row['LifeGroup'],

      'Zone': row['Zone'],
      'Region': row['Region'],

      'RenewalYearCount': row['RenewalYearCount'],

      'Preferred': row['Preferred'],

      'Activity': row['ActivityCode'],
      'SubActivity': row['SubActivityCode'],

      'Amount': row['Amount'],

      'SMName': row['SMName'],
      'SMBranch': row['SMBranch'],
      'SMBranchName': row['SMBranchName'],

      'TelesaleActivity': row['TelesaleActivity'],
      'TelesaleActivityDoneBy': row['TelesaleActivityDoneBy'],
      'TelesaleActivityDate': row['TelesaleActivityDate'],
      'TelesaleRemark': row['TelesaleRemark'],

      'LeadAging': row['LeadAging'],

      'RenewalPaymentLink': row['RenewalPaymentLink'],
    };
  }

  Map<String, dynamic> _buildLeadTrackerMap(Map<String, dynamic> row) {
    return {
      'CltCode': row['CltCode'],
      'SrvcReqDtlCode': row['SrvcReqDtlCode'],
      'ActivityCode': row['ActivityCode'],

      'AppointmentDate': row['AppointmentDate'],
      'Hour': row['Hour'],
      'Minute': row['Minute'],

      'AppointmentAddrss': row['AppointmentAddrss'],

      'AppThrough': row['AppThrough'],
      'ResThrough': row['ResThrough'],

      'RescheduleDate': row['RescheduleDate'],
      'RescheduleAddrss': row['RescheduleAddrss'],

      'ParkedLead': row['ParkedLead'],

      'ProposalNo': row['ProposalNo'],

      'IssuedPolicyNo': row['IssuedPolicyNo'],
      'PremiumCollected': row['PremiumCollected'],

      'AppReason': row['AppReason'],
      'SubReason': row['SubReason'],

      'DuplicateLeadId': row['DuplicateLeadId'],
      'ComptitorID': row['ComptitorID'],

      'LocationDtls': row['LocationDtls'],

      'NonContble': row['NonContble'],
      'NotIntrest': row['NotIntrest'],

      'PhoneNumber': row['PhoneNumber'],

      'CreateBy': row['CreateBy'],
      'CreateDTim': row['CreateDTim'],

      'UpdateBy': row['UpdateBy'],
      'UpdateDTim': row['UpdateDTim'],

      // Android always saves blank values
      'IsActive': '',
      'oriPREMCOL': '',

      'MakenModel': row['MakenModel'],

      'ExpiryDate': row['ExpiryDate'],
      'CallBackDate': row['CallBackDate'],

      'InfectionID': row['InfectionID'],

      'TicketNo': row['TicketNo'],
      'QuoteNo': row['QuoteNo'],

      'LcReason': row['LcReason'],
      'LcSubReason': row['LcSubReason'],

      'Age': row['Age'],

      'RtoLoc': row['RtoLoc'],

      'Price': row['Price'],

      'YOM': row['YOM'],

      'PED': row['PED'],

      'Feature': row['Feature'],

      'Area': row['Area'],

      'PHC_NO': row['PHC_NO'],

      'ProductType': row['ProductType'],

      'Lan': row['Lan'],

      'PostPQuery': row['PostPQuery'],

      'NotEligible': row['NotEligible'],

      'Reason': row['Reason'],
      'RsReason': row['RsReason'],

      'ModelValue': row['ModelValue'],

      'NonContactableDtm': row['NonContactableDtm'],

      'CallBackDateRenewal': row['CallBackDateRenewal'],

      'NonConRes': row['NonConRes'],

      'ChequeNo': row['ChequeNo'],
      'ChequeDate': row['ChequeDate'],
      'ChequeBankName': row['ChequeBankName'],

      'RegistrationNo': row['RegistrationNo'],

      'RenewalLeadLostReason': row['RenewalLeadLostReason'],

      'PolicyAlreadyRenewedReason': row['PolicyAlreadyRenewedReason'],

      'ParkedLeadDateTime': row['ParkedLeadDateTime'],

      'FollowupDt': row['FollowupDt'],

      'QutationDt': row['QutationDt'],

      'InstType': row['InstType'],

      'LstComDueTo': row['LstComDueTo'],

      'NewPolEndDate': row['NewPolEndDate'],

      'SubActivityCode': row['SubActivityCode'],

      // Android:
      // cv.put("Remark", leadModel.get(i).getTrackerRemark());
      'Remark': row['TrackerRemark'],
    };
  }

  Future<void> _saveLeadDetails(List<Map<String, dynamic>> leadRows) async {
    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final row in leadRows) {
        final leadMap = _buildLeadDetailsMap(row);
        final trackerMap = _buildLeadTrackerMap(row);

        batch.insert(
          'LeadDetails',
          leadMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        batch.insert(
          'LMSLeadActivityTracker',
          trackerMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }
  //add end
  // Future<void> _saveLeadDetails(List<Map<String, dynamic>> leadRows) async {
  //   final db = await DatabaseHelper.instance.database;

  //   debugPrint('Saving ${leadRows.length} leads into LeadDetails');
  //   await db.transaction((txn) async {
  //     final batch = txn.batch();

  //     for (final row in leadRows) {
  //       final leadMap = _buildLeadDetailsMap(row);

  //       batch.insert(
  //         'LeadDetails',
  //         leadMap,
  //         conflictAlgorithm: ConflictAlgorithm.replace,
  //       );
  //     }

  //     await batch.commit(noResult: true);
  //     debugPrint('LeadDetails save completed');
  //   });
  // }

  Future<List<LeadCardModel>> getLocalLeads({
    required CalendarLeadArgs args,
    required String userId,
  }) async {
    try {
      final db = await _databaseHelper.database;
      final filters = args.filters;

      final businessType = args.businessType.trim().toUpperCase();

      final bool isRenewal =
          businessType == 'R' ||
          businessType == 'RENEWAL' ||
          businessType == '3';

      final whereParts = <String>['UPPER(TRIM(UserId)) = ?'];

      final whereArgs = <Object?>[userId.trim().toUpperCase()];

      // Renewal/Fresh conditions matching Android.
      if (isRenewal) {
        whereParts.addAll([
          'ReqChannelId = ?',
          'LeadSource = ?',
          'BusinessType = ?',
        ]);

        whereArgs.addAll(['RQ17', '29', '3']);
      } else {
        whereParts.add('BusinessType != ?');
        whereArgs.add('3');
      }

      // Lead type:
      // 0 = All
      // 1 = Contact
      // 2 = Lead
      final int selectedLeadType = filters.leadType;

      if (selectedLeadType == 2) {
        whereParts.add('LeadTypeDesc = ?');
        whereArgs.add('Lead');
      } else if (selectedLeadType == 1) {
        whereParts.add('''
          (
            LeadTypeDesc IS NULL
            OR TRIM(LeadTypeDesc) = ''
            OR LeadTypeDesc != ?
          )
          ''');

        whereArgs.add('Lead');
      }

      // Main calendar filters.
      _addInCondition(
        column: 'BMCMCode',
        values: filters.reportingManager,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'SMBranch',
        values: filters.branch,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'LOBCode',
        values: filters.lob,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'Zone',
        values: filters.zone,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'Region',
        values: filters.region,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'AgentCode',
        values: filters.agent,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'HNINCode',
        values: filters.reference,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'ProductGroup',
        values: filters.productGroup,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'ProdCode',
        values: filters.product,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'ProductSubCategory',
        values: filters.productSubCategory,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'RenewalYearCount',
        values: filters.renewalYearCount,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'NCBFlag',
        values: filters.ncb,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addInCondition(
        column: 'Preferred',
        values: filters.preferred,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      // Product-specific filters.
      _addSingleCondition(
        column: 'NILDep',
        value: filters.nilDep,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'Category',
        value: filters.categoryName,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'FuelType',
        value: filters.fuelType,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'Make',
        value: filters.make,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'AgeGroup',
        value: filters.vehicleAgeGrp,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'VehicleType',
        value: filters.vehicleType,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'SeatingCapacity',
        value: filters.seatingCapacity,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'AgeGroup',
        value: filters.ageGroup,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'FamilySize',
        value: filters.familySize,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'SumInsuredBand',
        value: filters.sumInsuredBand,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'PreExiting',
        value: filters.preExisting,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'Occupancy',
        value: filters.occupancy,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'SumInsured',
        value: filters.sumInsured,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      _addSingleCondition(
        column: 'LifeGroup',
        value: filters.lifeGroup,
        whereParts: whereParts,
        whereArgs: whereArgs,
      );

      final rows = await db.query(
        'LeadDetails',
        columns: [
          'SrvcReqDtlCode',
          'Name',
          'ProdName',
          'InstallmentPrem',
          'PolicyNo',
          'PolNCB',
          'Make',
          'Model',
          'ActivityStatus',
          'SrvcFromDTim',
          'RenewalPaymentLink',
          'PolicyEndDate',
          'CreateDTim',
        ],
        where: whereParts.join(' AND '),
        whereArgs: whereArgs,
      );

      // Match records with the selected calendar date.
      final matchingRows = rows.where((row) {
        final dynamic rawDate = isRenewal
            ? row['PolicyEndDate']
            : row['CreateDTim'];

        final leadDate = _parseDatabaseDate(rawDate);

        if (leadDate == null) {
          return false;
        }

        return _isSameDay(leadDate, args.selectedDate);
      }).toList();

      // Collect all unique activity codes.
      final activityCodes = matchingRows
          .map((row) => row['ActivityStatus']?.toString().trim() ?? '')
          .where(
            (code) =>
                code.isNotEmpty &&
                code.toLowerCase() != 'null' &&
                code.toLowerCase() != 'not available',
          )
          .toSet()
          .toList();

      final activityDescriptions = await getActivityDescriptions(activityCodes);

      // Convert DB rows into card models.
      return matchingRows.map((row) {
        final activityCode = row['ActivityStatus']?.toString().trim() ?? '';

        final activityDescription = activityDescriptions[activityCode];

        return LeadCardModel.fromMap(
          Map<String, dynamic>.from(row),
          activityDescription:
              activityDescription == null ||
                  activityDescription == 'Not Available'
              ? null
              : activityDescription,
        );
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error loading local calendar leads: $e');

      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  Future<Map<String, String>> getActivityDescriptions(
    List<String> activityCodes,
  ) async {
    final codes = activityCodes
        .map((code) => code.trim())
        .where(
          (code) =>
              code.isNotEmpty &&
              code.toLowerCase() != 'null' &&
              code.toLowerCase() != 'not available',
        )
        .toSet()
        .toList();

    if (codes.isEmpty) {
      return {};
    }

    final descriptions = <String, String>{};
    final missingCodes = <String>[];

    // Read previously loaded activity descriptions.
    for (final code in codes) {
      final cachedDescription = _activityDescriptionCache[code];

      if (cachedDescription != null) {
        descriptions[code] = cachedDescription;
      } else {
        missingCodes.add(code);
      }
    }

    if (missingCodes.isEmpty) {
      return descriptions;
    }

    try {
      final db = await OfflineDBHelper.getDatabase();

      final placeholders = List.filled(missingCodes.length, '?').join(',');

      final rows = await db.rawQuery('''
        SELECT ActivityCode, ActivityDesc1
        FROM CBLMSMSTActivity
        WHERE ActivityCode IN ($placeholders)
        ''', missingCodes);

      for (final row in rows) {
        final code = row['ActivityCode']?.toString().trim() ?? '';

        final description = row['ActivityDesc1']?.toString().trim() ?? '';

        if (code.isEmpty || description.isEmpty) {
          continue;
        }

        descriptions[code] = description;
        _activityDescriptionCache[code] = description;
      }

      // Cache codes that were not found.
      for (final code in missingCodes) {
        if (!descriptions.containsKey(code)) {
          descriptions[code] = 'Not Available';
          _activityDescriptionCache[code] = 'Not Available';
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading activity descriptions: $e');

      debugPrintStack(stackTrace: stackTrace);
    }

    return descriptions;
  }

  void _addInCondition({
    required String column,
    required Iterable<Object?>? values,
    required List<String> whereParts,
    required List<Object?> whereArgs,
  }) {
    if (values == null) {
      return;
    }

    final cleanedValues = values
        .map((value) => value?.toString().trim() ?? '')
        .where(
          (value) =>
              value.isNotEmpty &&
              value.toLowerCase() != 'all' &&
              value.toLowerCase() != 'null' &&
              value.toLowerCase() != 'not available',
        )
        .toSet()
        .toList();

    if (cleanedValues.isEmpty) {
      return;
    }

    final placeholders = List.filled(cleanedValues.length, '?').join(',');

    whereParts.add('$column IN ($placeholders)');

    whereArgs.addAll(cleanedValues);
  }

  void _addSingleCondition({
    required String column,
    required Object? value,
    required List<String> whereParts,
    required List<Object?> whereArgs,
  }) {
    final cleanedValue = value?.toString().trim() ?? '';

    if (cleanedValue.isEmpty ||
        cleanedValue.toLowerCase() == 'all' ||
        cleanedValue.toLowerCase() == 'null' ||
        cleanedValue.toLowerCase() == 'not available') {
      return;
    }

    whereParts.add('$column = ?');
    whereArgs.add(cleanedValue);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  DateTime? _parseDatabaseDate(dynamic rawValue) {
    final value = rawValue?.toString().trim() ?? '';

    if (value.isEmpty || value.toLowerCase() == 'null') {
      return null;
    }

    final directDate = DateTime.tryParse(value);

    if (directDate != null) {
      return directDate;
    }

    final formats = <String>[
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'dd-MM-yyyy HH:mm:ss',
      'dd/MM/yyyy HH:mm:ss',
      'dd-MM-yyyy hh:mm:ss a',
      'dd/MM/yyyy hh:mm:ss a',
      'yyyy-MM-dd',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-ddTHH:mm:ss',
      'yyyy-MM-ddTHH:mm:ss.SSS',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parseStrict(value);
      } catch (_) {
        // Continue with the next supported format.
      }
    }

    debugPrint('Unable to parse LeadDetails date: $value');

    return null;
  }
}
