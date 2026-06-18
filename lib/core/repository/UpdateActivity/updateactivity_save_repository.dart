import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/core/apicall/async_updateactivity.dart';
import 'package:flutter_bottom_nav/core/repository/activity_offline_repository.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_payload.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_save.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class UpdateActivitySaveRepository {
  const UpdateActivitySaveRepository();

  String _encrypt(dynamic value) {
    return EncryptionUtil.encrypt(value?.toString().trim() ?? '');
  }

  String _decrypt(dynamic value) {
    return EncryptionUtil.decrypt(value?.toString() ?? '') ?? '';
  }

  String _formatCurrentDateTime() {
    final now = DateTime.now();

    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();

    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;

    final hour = hour12.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$day-$month-$year $hour:$minute $period';
  }

  /// Supports both possible Flutter table names.
  Future<String> _findExistingTable(
    Database db,
    List<String> possibleNames,
  ) async {
    for (final tableName in possibleNames) {
      final result = await db.rawQuery(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
          AND LOWER(name) = LOWER(?)
        LIMIT 1
        ''',
        [tableName],
      );

      if (result.isNotEmpty) {
        return result.first['name'].toString();
      }
    }

    throw StateError('Table not found. Checked: ${possibleNames.join(', ')}');
  }

  Future<String?> _findOptionalTable(
    Database db,
    List<String> possibleNames,
  ) async {
    for (final tableName in possibleNames) {
      final result = await db.rawQuery(
        '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND LOWER(name) = LOWER(?)
      LIMIT 1
      ''',
        [tableName],
      );

      if (result.isNotEmpty) {
        return result.first['name']?.toString();
      }
    }

    return null;
  }

  Future<bool> _isConnected() async {
    try {
      final result = await Connectivity().checkConnectivity();

      if (result == ConnectivityResult.none) {
        return false;
      }

      return true;
    } catch (_) {
      try {
        final lookup = await InternetAddress.lookup('google.com');

        return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  Future<String> _resolveLeadId({
    required Database db,
    required String leadTable,
    required String leadId,
    required String tempLeadId,
  }) async {
    if (!leadId.startsWith('T')) {
      return leadId;
    }

    // First check whether the temporary lead ID itself exists.
    final directLeadResult = await db.query(
      leadTable,
      columns: ['SrvcReqDtlCode'],
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(leadId)],
      limit: 1,
    );

    if (directLeadResult.isNotEmpty) {
      return leadId;
    }

    if (tempLeadId.isEmpty) {
      return leadId;
    }

    // Android searches by TempSrvcReqDtlCode and uses
    // the actual SrvcReqDtlCode when available.
    final temporaryLeadResult = await db.query(
      leadTable,
      columns: ['SrvcReqDtlCode'],
      where: 'TempSrvcReqDtlCode = ?',
      whereArgs: [_encrypt(tempLeadId)],
    );

    String resolvedLeadId = leadId;

    for (final row in temporaryLeadResult) {
      final actualLeadId = _decrypt(row['SrvcReqDtlCode']).trim();

      if (actualLeadId.isNotEmpty) {
        resolvedLeadId = actualLeadId;
      }
    }

    return resolvedLeadId;
  }

  DateTime? _parseAppointmentDateTime(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), ' ');

    final match = RegExp(
      r'^(\d{1,2})-(\d{1,2})-(\d{4}) '
      r'(\d{1,2}):(\d{2}) (AM|PM)$',
      caseSensitive: false,
    ).firstMatch(cleaned);

    if (match == null) {
      return null;
    }

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    var hour = int.tryParse(match.group(4)!);
    final minute = int.tryParse(match.group(5)!);
    final period = match.group(6)!.toUpperCase();

    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null) {
      return null;
    }

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(year, month, day, hour, minute);
  }

  String _formatDateOnly(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$day-$month-${dateTime.year}';
  }

  String _formatDatabaseDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '${dateTime.year}-$month-$day '
        '$hour:$minute:$second.000';
  }

  String _convertStoredDateToDateOnly(String value) {
    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return '';
    }

    final isoDate = DateTime.tryParse(cleaned);

    if (isoDate != null) {
      return _formatDateOnly(isoDate);
    }

    final match = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})').firstMatch(cleaned);

    if (match == null) {
      return '';
    }

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);

    if (day == null || month == null || year == null) {
      return '';
    }

    return _formatDateOnly(DateTime(year, month, day));
  }

  int _decryptInt(dynamic value) {
    return int.tryParse(_decrypt(value).trim()) ?? 0;
  }

  double _decryptDouble(dynamic value) {
    return double.tryParse(_decrypt(value).trim()) ?? 0.0;
  }

  Future<void> _moveLeadToCalendarDate({
    required DatabaseExecutor executor,
    required String leadTable,
    required String calendarTable,
    required String resolvedLeadId,
    required String loginSapCode,
    required String appointmentDate,
  }) async {
    final selectedDateTime = _parseAppointmentDateTime(appointmentDate);

    if (selectedDateTime == null) {
      throw const FormatException('Invalid Appointment Date format.');
    }

    final leadRows = await executor.query(
      leadTable,
      columns: [
        'ReqChannelId',
        'LOBCode',
        'ProdCode',
        'BusinessType',
        'PolicyEndDate',
        'CreateDTim',
      ],
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
    );

    if (leadRows.isEmpty) {
      return;
    }

    // Android loops all records and effectively keeps
    // values from the last matching row.
    final leadRow = leadRows.last;

    final requestChannelId = _decrypt(leadRow['ReqChannelId']).trim();

    final lobCode = _decrypt(leadRow['LOBCode']).trim();

    final productCode = _decrypt(leadRow['ProdCode']).trim();

    final businessType = _decrypt(leadRow['BusinessType']).trim();

    if (businessType.isEmpty) {
      return;
    }

    // Android does not move renewal RQ17/BizType 3
    // leads through this calendar flow.
    if (businessType == '3') {
      return;
    }

    final oldCreateDate = _decrypt(leadRow['CreateDTim']);

    final oldCalendarDate = _convertStoredDateToDateOnly(oldCreateDate);

    if (oldCalendarDate.isEmpty || lobCode.isEmpty || productCode.isEmpty) {
      return;
    }

    const calendarBizType = 'N';

    final calendarRows = await executor.query(
      calendarTable,
      where:
          'UserId = ? '
          'AND date = ? '
          'AND LOBCode = ? '
          'AND ProdCode = ? '
          'AND BizType = ?',
      whereArgs: [
        _encrypt(loginSapCode),
        _encrypt(oldCalendarDate),
        _encrypt(lobCode),
        _encrypt(productCode),
        _encrypt(calendarBizType),
      ],
      limit: 1,
    );

    if (calendarRows.isEmpty) {
      return;
    }

    final oldCalendarRow = calendarRows.first;
    final recId = oldCalendarRow['RecId'];

    final currentWipLeads = _decryptInt(oldCalendarRow['WIPLeads']);

    final remainingWipLeads = currentWipLeads > 1 ? currentWipLeads - 1 : 0;

    final newCalendarDate = _formatDateOnly(selectedDateTime);

    final newCreateDateTime = _formatDatabaseDateTime(selectedDateTime);

    final monthYear = '${selectedDateTime.month}-${selectedDateTime.year}';

    if (remainingWipLeads > 0) {
      // Keep the old aggregate row and reduce its WIP.
      await executor.update(
        calendarTable,
        {
          'WIPLeads': _encrypt(remainingWipLeads),
          'CreatedBy': _encrypt(loginSapCode),
          'SyncStatus': _encrypt('Completed'),
        },
        where: 'RecId = ?',
        whereArgs: [recId],
      );

      // Remove an older lead-specific calendar row,
      // if one already exists.
      await executor.delete(
        calendarTable,
        where: 'ReferenceNo = ?',
        whereArgs: [_encrypt(resolvedLeadId)],
      );

      // Insert the lead on its newly selected appointment date.
      await executor.insert(calendarTable, {
        'UserId': _encrypt(loginSapCode),
        'date': _encrypt(newCalendarDate),

        'AgentCode': _encrypt(_decrypt(oldCalendarRow['AgentCode'])),
        'AgentName': _encrypt(_decrypt(oldCalendarRow['AgentName'])),
        'HNINCode': _encrypt(_decrypt(oldCalendarRow['HNINCode'])),
        'HNINName': _encrypt(_decrypt(oldCalendarRow['HNINName'])),

        'LOBCode': _encrypt(lobCode),
        'ProdCode': _encrypt(productCode),

        'NCBFlag': _encrypt(_decrypt(oldCalendarRow['NCBFlag'])),

        'TotalLeads': _encrypt('1'),
        'WIPLeads': _encrypt('1'),
        'LeadConverted': _encrypt('0'),
        'LeadLost': _encrypt('0'),
        'LeadType': _encrypt('L'),
        'BizType': _encrypt('N'),

        'CreatedBy': _encrypt(loginSapCode),
        'CreateDTime': _encrypt(newCreateDateTime),
        'mdate': _encrypt(monthYear),
        'ReferenceNo': _encrypt(resolvedLeadId),
        'SyncStatus': _encrypt('Pending'),
      });
    } else {
      // When this is the only lead in the old row,
      // Android moves that row directly to the new date.
      await executor.update(
        calendarTable,
        {
          'date': _encrypt(newCalendarDate),
          'CreatedBy': _encrypt(loginSapCode),
          'ReferenceNo': _encrypt(resolvedLeadId),
          'SyncStatus': _encrypt('Pending'),
        },
        where: 'RecId = ?',
        whereArgs: [recId],
      );
    }

    // Android also changes the lead's working date.
    await executor.update(
      leadTable,
      {'CreateDTim': _encrypt(newCreateDateTime)},
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
    );
  }

  Future<void> _moveLeadToDashboardDate({
    required DatabaseExecutor executor,
    required String leadTable,
    required String dashboardTable,
    required String resolvedLeadId,
    required String loginSapCode,
    required String activityDate,
  }) async {
    final selectedDateTime = _parseAppointmentDateTime(activityDate);

    if (selectedDateTime == null) {
      throw const FormatException('Invalid Activity Date format.');
    }

    final leadRows = await executor.query(
      leadTable,
      columns: ['LOBCode', 'ProdCode', 'BusinessType', 'CreateDTim'],
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
    );

    if (leadRows.isEmpty) {
      return;
    }

    final leadRow = leadRows.last;

    final lobCode = _decrypt(leadRow['LOBCode']).trim();

    final productCode = _decrypt(leadRow['ProdCode']).trim();

    final businessType = _decrypt(leadRow['BusinessType']).trim();

    // Android skips renewal leads for this movement.
    if (businessType.isEmpty || businessType == '3') {
      return;
    }

    final oldDashboardDate = _convertStoredDateToDateOnly(
      _decrypt(leadRow['CreateDTim']),
    );

    if (oldDashboardDate.isEmpty || lobCode.isEmpty || productCode.isEmpty) {
      return;
    }

    final dashboardRows = await executor.query(
      dashboardTable,
      where:
          'UserId = ? '
          'AND date = ? '
          'AND LOBCode = ? '
          'AND ProdCode = ? '
          'AND BizType = ?',
      whereArgs: [
        _encrypt(loginSapCode),
        _encrypt(oldDashboardDate),
        _encrypt(lobCode),
        _encrypt(productCode),
        _encrypt('N'),
      ],
    );

    if (dashboardRows.isEmpty) {
      return;
    }

    // Android cursor behaviour effectively keeps the last row.
    final oldDashboardRow = dashboardRows.last;

    final recId = oldDashboardRow['RecId'];

    final currentWipLeads = _decryptInt(oldDashboardRow['WIPLeads']);

    final newDashboardDate = _formatDateOnly(selectedDateTime);

    final newCreateDateTime = _formatDatabaseDateTime(selectedDateTime);

    final monthYear = '${selectedDateTime.month}-${selectedDateTime.year}';

    if (currentWipLeads > 1) {
      await executor.update(
        dashboardTable,
        {
          'WIPLeads': _encrypt(currentWipLeads - 1),
          'UpdatedBy': _encrypt(loginSapCode),
          'SyncStatus': _encrypt('Completed'),
        },
        where: 'RecId = ?',
        whereArgs: [recId],
      );

      // Remove an older lead-specific moved row.
      await executor.delete(
        dashboardTable,
        where:
            'ReferenceNo = ? '
            'AND RecId != ?',
        whereArgs: [_encrypt(resolvedLeadId), recId],
      );

      await executor.insert(dashboardTable, {
        'UserId': oldDashboardRow['UserId'] ?? _encrypt(loginSapCode),

        'AgentCode': oldDashboardRow['AgentCode'],
        'AgentName': oldDashboardRow['AgentName'],
        'HNINCode': oldDashboardRow['HNINCode'],
        'HNINName': oldDashboardRow['HNINName'],

        'LOBCode': _encrypt(lobCode),
        'ProdCode': _encrypt(productCode),

        'NCBFlag': oldDashboardRow['NCBFlag'],

        'date': _encrypt(newDashboardDate),

        'TotalLeads': _encrypt('1'),
        'WIPLeads': _encrypt('1'),
        'LeadConverted': _encrypt('0'),
        'LeadLost': _encrypt('0'),

        'LeadType': _encrypt('L'),
        'BizType': _encrypt('N'),

        'Activity': _encrypt(''),
        'SubActivity': _encrypt(''),

        'CreatedBy': _encrypt(loginSapCode),
        'CreateDTime': _encrypt(newCreateDateTime),

        'MothYear': _encrypt(monthYear),

        'ReferenceNo': _encrypt(resolvedLeadId),

        'SyncStatus': _encrypt('Pending'),
      });
    } else {
      await executor.update(
        dashboardTable,
        {
          'date': _encrypt(newDashboardDate),
          'CreatedBy': _encrypt(loginSapCode),
          'ReferenceNo': _encrypt(resolvedLeadId),
          'SyncStatus': _encrypt('Pending'),
        },
        where: 'RecId = ?',
        whereArgs: [recId],
      );
    }
  }

  /// Currently saves Activity Code 1 only.
  ///
  ///
  ///
  /// Later the same method will be expanded for the remaining
  /// Android activity codes.

  Future<void> _updateSyncStatusAfterSuccess({
    required Database db,
    required String trackerTable,
    required String calendarTable,
    required String? dashboardTable,
    required String resolvedLeadId,
    required String activityCode,
    required String loginSapCode,
  }) async {
    // Most important update: mark the tracker as synced.
    await db.update(
      trackerTable,
      {'UpdateBy': _encrypt(loginSapCode), 'SyncStatus': _encrypt('Success')},
      where:
          'SrvcReqDtlCode = ? '
          'AND ActivityCode = ?',
      whereArgs: [_encrypt(resolvedLeadId), _encrypt(activityCode)],
    );

    // Calendar failure must not roll back tracker success.
    try {
      await db.update(
        calendarTable,
        {'SyncStatus': _encrypt('Completed')},
        where: 'ReferenceNo = ?',
        whereArgs: [_encrypt(resolvedLeadId)],
      );
    } catch (error) {
      print('Calendar sync-status update skipped: $error');
    }

    // Dashboard is optional.
    if (dashboardTable != null) {
      try {
        await db.update(
          dashboardTable,
          {'SyncStatus': _encrypt('Completed')},
          where: 'ReferenceNo = ?',
          whereArgs: [_encrypt(resolvedLeadId)],
        );
      } catch (error) {
        print('Dashboard sync-status update skipped: $error');
      }
    }
  }

  Future<bool> _syncActivityOnline({
    required Database db,
    required String trackerTable,
    required String calendarTable,
    required String? dashboardTable,
    required String resolvedLeadId,
    required String activityCode,
    required String loginSapCode,
  }) async {
    try {
      // This reads the Pending row from LMSLeadActivityTracker
      // through ActivityRepository.getActivityData().
      final response = await UpdateActivityService.call(
        srvcReqDtlCode: resolvedLeadId,
      );

      print('UPDATE ACTIVITY API RESPONSE: $response');

      final tableData = response['Table'];

      if (tableData is! List || tableData.isEmpty) {
        print(
          'Update Activity API failed: '
          '${response['message'] ?? 'No response table found'}',
        );

        return false;
      }

      for (final item in tableData) {
        if (item is! Map) {
          continue;
        }

        final responseCode = item['ResponseCode']?.toString().trim() ?? '';

        if (responseCode == '0') {
          await _updateSyncStatusAfterSuccess(
            db: db,
            trackerTable: trackerTable,
            calendarTable: calendarTable,
            dashboardTable: dashboardTable,
            resolvedLeadId: resolvedLeadId,
            activityCode: activityCode,
            loginSapCode: loginSapCode,
          );

          return true;
        }

        print(
          'Update Activity API error: '
          '${item['ErrorMessage'] ?? item['ErrorDescription'] ?? ''}',
        );
      }

      return false;
    } catch (error, stackTrace) {
      print('Update Activity online sync error: $error');
      print(stackTrace);

      return false;
    }
  }

  Future<String> _getClientCode({
    required DatabaseExecutor executor,
    required String leadTable,
    required String resolvedLeadId,
  }) async {
    final rows = await executor.query(
      leadTable,
      columns: ['CltCode'],
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
      limit: 1,
    );

    if (rows.isEmpty) {
      return '';
    }

    return _decrypt(rows.first['CltCode']).trim();
  }

  Future<Map<String, dynamic>> _buildTrackerData({
    required DatabaseExecutor executor,
    required String trackerTable,
    required UpdateActivityPayload payload,
    required String resolvedLeadId,
    required String clientCode,
    required String currentDateTime,
  }) async {
    final safeTableName = trackerTable.replaceAll('"', '""');

    final tableInfo = await executor.rawQuery(
      'PRAGMA table_info("$safeTableName")',
    );

    final actualColumns = <String, String>{};

    for (final row in tableInfo) {
      final columnName = row['name']?.toString().trim() ?? '';

      if (columnName.isNotEmpty) {
        actualColumns[columnName.toLowerCase()] = columnName;
      }
    }

    final trackerData = <String, dynamic>{};

    void addEncryptedValue(String requestedColumn, dynamic value) {
      final actualColumn = actualColumns[requestedColumn.toLowerCase()];

      if (actualColumn == null) {
        print('TRACKER COLUMN NOT FOUND: $requestedColumn');
        return;
      }

      trackerData[actualColumn] = _encrypt(value);
    }

    // Common fields used by every Activity Code.
    addEncryptedValue('ActivityCode', payload.activityCode);

    addEncryptedValue('SrvcReqDtlCode', resolvedLeadId);

    addEncryptedValue('CreateBy', payload.createdBy);

    addEncryptedValue('CreateDTim', currentDateTime);

    addEncryptedValue('internalcomment', payload.internalComment);

    addEncryptedValue('SyncStatus', 'Pending');

    addEncryptedValue('TempSrvcReqDtlCode', payload.tempLeadId);

    addEncryptedValue('CltCode', clientCode);

    addEncryptedValue('SubActivityCode', '');

    addEncryptedValue('UpdateBy', '');

    addEncryptedValue('UpdateDTim', '');

    addEncryptedValue('IsActive', 'Y');

    // Activity-specific fields coming from the registry payload.
    for (final entry in payload.activityFields.entries) {
      final columnName = entry.key.trim();

      if (columnName.isEmpty) {
        continue;
      }

      addEncryptedValue(columnName, entry.value);
    }

    return trackerData;
  }

  String _getCalendarMovementDate(UpdateActivityPayload payload) {
    final fields = payload.activityFields;

    switch (payload.normalizedActivityCode) {
      case '1':
      case '20':
      case '27':
        return fields['AppointmentDate']?.toString().trim() ?? '';

      case '2':
      case '28':
        return fields['RescheduleDate']?.toString().trim() ?? '';

      case '19':
      case '21':
        return fields['CallBackDate']?.toString().trim() ?? '';

      case '32':
        return fields['FollowupDt']?.toString().trim() ?? '';

      default:
        return '';
    }
  }

  String? _getTerminalLeadStatus(String activityCode) {
    switch (activityCode) {
      case '3':
      case '5':
      case '18':
      case '24':
      case '29':
      case '31':
      case '38':
        return 'Lead Lost';

      case '4':
      case '17':
      case '30':
      case '35':
        return 'Lead Converted';

      default:
        return null;
    }
  }

  Future<void> _updateTerminalActivityCalendar({
    required DatabaseExecutor executor,
    required String leadTable,
    required String calendarTable,
    required String resolvedLeadId,
    required String loginSapCode,
    required String leadStatus,
  }) async {
    final leadRows = await executor.query(
      leadTable,
      columns: [
        'ReqChannelId',
        'LOBCode',
        'ProdCode',
        'BusinessType',
        'PolicyEndDate',
        'CreateDTim',
      ],
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
    );

    if (leadRows.isEmpty) {
      return;
    }

    final leadRow = leadRows.last;

    final requestChannelId = _decrypt(leadRow['ReqChannelId']).trim();

    final lobCode = _decrypt(leadRow['LOBCode']).trim();

    final productCode = _decrypt(leadRow['ProdCode']).trim();

    final businessType = _decrypt(leadRow['BusinessType']).trim();

    final isRenewalLead =
        requestChannelId.toUpperCase() == 'RQ17' && businessType == '3';

    final storedDate = isRenewalLead
        ? _decrypt(leadRow['PolicyEndDate'])
        : _decrypt(leadRow['CreateDTim']);

    final calendarDate = _convertStoredDateToDateOnly(storedDate);

    final calendarBizType = isRenewalLead ? 'R' : 'N';

    if (calendarDate.isEmpty || lobCode.isEmpty || productCode.isEmpty) {
      return;
    }

    final calendarRows = await executor.query(
      calendarTable,
      where:
          'UserId = ? '
          'AND date = ? '
          'AND LOBCode = ? '
          'AND ProdCode = ? '
          'AND BizType = ? '
          'AND WIPLeads != ?',
      whereArgs: [
        _encrypt(loginSapCode),
        _encrypt(calendarDate),
        _encrypt(lobCode),
        _encrypt(productCode),
        _encrypt(calendarBizType),
        _encrypt('0'),
      ],
      limit: 1,
    );

    if (calendarRows.isEmpty) {
      return;
    }

    final calendarRow = calendarRows.first;

    final recId = calendarRow['RecId'];

    final totalLeads = _decryptInt(calendarRow['TotalLeads']);

    var wipLeads = _decryptInt(calendarRow['WIPLeads']);

    var leadConverted = _decryptInt(calendarRow['LeadConverted']);

    var leadLost = _decryptInt(calendarRow['LeadLost']);

    wipLeads = wipLeads > 1 ? wipLeads - 1 : 0;

    if (leadStatus == 'Lead Lost') {
      leadLost = leadLost > 1 ? leadLost + 1 : 1;
    } else if (leadStatus == 'Lead Converted') {
      leadConverted = leadConverted > 1 ? leadConverted + 1 : 1;
    }

    await executor.update(
      calendarTable,
      {
        'TotalLeads': _encrypt(totalLeads),
        'WIPLeads': _encrypt(wipLeads),
        'LeadConverted': _encrypt(leadConverted),
        'LeadLost': _encrypt(leadLost),
        'CreatedBy': _encrypt(loginSapCode),
        'ReferenceNo': _encrypt(resolvedLeadId),
        'SyncStatus': _encrypt('Pending'),
      },
      where: 'RecId = ?',
      whereArgs: [recId],
    );

    // Android removes terminal leads from the user's active list.
    await executor.update(
      leadTable,
      {'UserId': _encrypt('')},
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
    );
  }

  Future<void> _updateTerminalActivityDashboard({
    required DatabaseExecutor executor,
    required String leadTable,
    required String dashboardTable,
    required String resolvedLeadId,
    required String loginSapCode,
    required String leadStatus,
    required String activityCode,
    required String subActivityCode,
  }) async {
    final leadRows = await executor.query(
      leadTable,
      columns: [
        'ReqChannelId',
        'LOBCode',
        'ProdCode',
        'BusinessType',
        'PolicyEndDate',
        'CreateDTim',
      ],
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
    );

    if (leadRows.isEmpty) {
      return;
    }

    final leadRow = leadRows.last;

    final requestChannelId = _decrypt(leadRow['ReqChannelId']).trim();

    final lobCode = _decrypt(leadRow['LOBCode']).trim();

    final productCode = _decrypt(leadRow['ProdCode']).trim();

    final businessType = _decrypt(leadRow['BusinessType']).trim();

    final isRenewalLead =
        requestChannelId.toUpperCase() == 'RQ17' && businessType == '3';

    final storedDate = isRenewalLead
        ? _decrypt(leadRow['PolicyEndDate'])
        : _decrypt(leadRow['CreateDTim']);

    final dashboardDate = _convertStoredDateToDateOnly(storedDate);

    final dashboardBizType = isRenewalLead ? 'R' : 'N';

    if (dashboardDate.isEmpty || lobCode.isEmpty || productCode.isEmpty) {
      return;
    }

    final rows = await executor.query(
      dashboardTable,
      where:
          'UserId = ? '
          'AND date = ? '
          'AND LOBCode = ? '
          'AND ProdCode = ? '
          'AND BizType = ?',
      whereArgs: [
        _encrypt(loginSapCode),
        _encrypt(dashboardDate),
        _encrypt(lobCode),
        _encrypt(productCode),
        _encrypt(dashboardBizType),
      ],
    );

    Map<String, dynamic>? dashboardRow;

    for (final row in rows) {
      if (_decryptInt(row['WIPLeads']) > 0) {
        dashboardRow = row;
        break;
      }
    }

    if (dashboardRow == null) {
      return;
    }

    final recId = dashboardRow['RecId'];

    final totalLeads = _decryptInt(dashboardRow['TotalLeads']);

    var wipLeads = _decryptInt(dashboardRow['WIPLeads']);

    var leadConverted = _decryptInt(dashboardRow['LeadConverted']);

    var leadLost = _decryptInt(dashboardRow['LeadLost']);

    final previousActivity = _decrypt(dashboardRow['Activity']).trim();

    final previousSubActivity = _decrypt(dashboardRow['SubActivity']).trim();

    var amount = _decryptDouble(dashboardRow['Amount']);

    var nonContactable = _decryptInt(dashboardRow['Non_Contactable']);

    var callBack = _decryptInt(dashboardRow['Call_Back']);

    var appointmentFixed = _decryptInt(dashboardRow['Appointment_Fixed']);

    var lostToCompetition = _decryptInt(dashboardRow['Lost_To_Competition']);

    var customerNotInterested = _decryptInt(
      dashboardRow['Customer_Not_Interested'],
    );

    var customerNotResponding = _decryptInt(
      dashboardRow['Customer_Not_Responding'],
    );

    void reduceAmountUsingCount(int count) {
      if (amount > 0 && count > 0) {
        amount -= amount / count;
      }

      if (amount < 0) {
        amount = 0;
      }
    }

    // Remove the lead from its previous Code 37 bucket.
    if (previousActivity == '37') {
      switch (previousSubActivity) {
        case '4':
          reduceAmountUsingCount(callBack);
          callBack = callBack > 1 ? callBack - 1 : 0;
          break;

        case '5':
          reduceAmountUsingCount(appointmentFixed);
          appointmentFixed = appointmentFixed > 1 ? appointmentFixed - 1 : 0;
          break;

        case '6':
          reduceAmountUsingCount(nonContactable);
          nonContactable = nonContactable > 1 ? nonContactable - 1 : 0;
          break;
      }
    }

    // Remove the lead from its previous Code 38 bucket.
    if (previousActivity == '38') {
      switch (previousSubActivity) {
        case '7':
          reduceAmountUsingCount(lostToCompetition);
          lostToCompetition = lostToCompetition > 1 ? lostToCompetition - 1 : 0;
          break;

        case '8':
          reduceAmountUsingCount(customerNotInterested);
          customerNotInterested = customerNotInterested > 1
              ? customerNotInterested - 1
              : 0;
          break;

        case '9':
          reduceAmountUsingCount(customerNotResponding);
          customerNotResponding = customerNotResponding > 1
              ? customerNotResponding - 1
              : 0;
          break;
      }
    }

    wipLeads = wipLeads > 1 ? wipLeads - 1 : 0;

    // Add the lead to its new Code 38 bucket.
    if (activityCode == '38') {
      switch (subActivityCode) {
        case '7':
          lostToCompetition++;
          break;

        case '8':
          customerNotInterested++;
          break;

        case '9':
          customerNotResponding++;
          break;
      }
    }

    // Android contains this additional Code 35 handling.
    if (activityCode == '35' && subActivityCode == '1') {
      leadConverted++;
    }

    if (leadStatus == 'Lead Lost') {
      leadLost = leadLost > 1 ? leadLost + 1 : 1;
    } else if (leadStatus == 'Lead Converted') {
      leadConverted = leadConverted > 1 ? leadConverted + 1 : 1;
    }

    final updateData = <String, dynamic>{
      'Activity': _encrypt(activityCode),
      'SubActivity': _encrypt(subActivityCode),
      'TotalLeads': _encrypt(totalLeads),
      'WIPLeads': _encrypt(wipLeads),
      'LeadConverted': _encrypt(leadConverted),
      'LeadLost': _encrypt(leadLost),
      'Lead_Converted': _encrypt('0'),
      'CreatedBy': _encrypt(loginSapCode),
      'ReferenceNo': _encrypt(resolvedLeadId),
      'SyncStatus': _encrypt('Pending'),
    };

    if (activityCode == '38') {
      updateData['Amount'] = _encrypt(amount);

      switch (subActivityCode) {
        case '7':
          updateData['Lost_To_Competition'] = _encrypt(lostToCompetition);
          break;

        case '8':
          updateData['Customer_Not_Interested'] = _encrypt(
            customerNotInterested,
          );
          break;

        case '9':
          updateData['Customer_Not_Responding'] = _encrypt(
            customerNotResponding,
          );
          break;
      }
    }

    await executor.update(
      dashboardTable,
      updateData,
      where: 'RecId = ?',
      whereArgs: [recId],
    );
  }

  Future<bool> _wasLeadParked({
    required DatabaseExecutor executor,
    required String trackerTable,
    required String resolvedLeadId,
  }) async {
    try {
      final rows = await executor.query(
        trackerTable,
        columns: ['ParkedLead'],
        where: 'SrvcReqDtlCode = ?',
        whereArgs: [_encrypt(resolvedLeadId)],
        orderBy: 'RecId DESC',
      );

      for (final row in rows) {
        final parkedValue = _decrypt(row['ParkedLead']).trim().toUpperCase();

        if (parkedValue == 'Y' || parkedValue == '1') {
          return true;
        }
      }
    } catch (error) {
      print('Parked Lead check skipped: $error');
    }

    return false;
  }

  Future<String> _getExistingActivityCode({
    required DatabaseExecutor executor,
    required String leadTable,
    required String resolvedLeadId,
  }) async {
    final rows = await executor.query(
      leadTable,
      columns: ['ActivityStatus'],
      where: 'SrvcReqDtlCode = ?',
      whereArgs: [_encrypt(resolvedLeadId)],
      limit: 1,
    );

    if (rows.isEmpty) {
      return '';
    }

    return _decrypt(rows.first['ActivityStatus']).trim();
  }

  Future<UpdateActivitySaveResult> saveActivity(
    UpdateActivityPayload payload,
  ) async {
    if (payload.leadId.trim().isEmpty) {
      return UpdateActivitySaveResult.failure(
        message: 'Lead ID is not available.',
      );
    }

    if (payload.activityCode.trim().isEmpty) {
      return UpdateActivitySaveResult.failure(
        message: 'Activity Code is not available.',
        resolvedLeadId: payload.leadId,
      );
    }

    // if (payload.normalizedActivityCode != '1') {
    //   return UpdateActivitySaveResult.failure(
    //     message: 'This activity save flow is not implemented yet.',
    //     resolvedLeadId: payload.leadId,
    //   );
    // }

    try {
      final db = await DatabaseHelper.instance.database;

      final leadTable = await _findExistingTable(db, [
        'LeadDetails',
        'Tbl_LeadDetails',
      ]);

      final trackerTable = await _findExistingTable(db, [
        'LMSLeadActivityTracker',
        // 'Tbl_LeadActivityTracker',
      ]);
      final calendarTable = await _findExistingTable(db, [
        'CalendarData_Mob',
        'Tbl_CalendarData_Mob',
      ]);
      final dashboardTable = await _findOptionalTable(db, [
        'DashboardData_Mob',
        'Tbl_DashboardData_Mob',
      ]);

      final resolvedLeadId = await _resolveLeadId(
        db: db,
        leadTable: leadTable,
        leadId: payload.leadId.trim(),
        tempLeadId: payload.tempLeadId.trim(),
      );

      final currentDateTime = _formatCurrentDateTime();
      final fields = payload.activityFields;

      final clientCode = await _getClientCode(
        executor: db,
        leadTable: leadTable,
        resolvedLeadId: resolvedLeadId,
      );

      final trackerData = await _buildTrackerData(
        executor: db,
        trackerTable: trackerTable,
        payload: payload,
        resolvedLeadId: resolvedLeadId,
        clientCode: clientCode,
        currentDateTime: currentDateTime,
      );

      final wasLeadParked =
          const {'36', '37'}.contains(payload.normalizedActivityCode)
          ? await _wasLeadParked(
              executor: db,
              trackerTable: trackerTable,
              resolvedLeadId: resolvedLeadId,
            )
          : false;

      final existingActivityCode = payload.normalizedActivityCode == '37'
          ? await _getExistingActivityCode(
              executor: db,
              leadTable: leadTable,
              resolvedLeadId: resolvedLeadId,
            )
          : '';
      // final trackerData = <String, dynamic>{
      //   'ActivityCode': _encrypt(payload.activityCode),
      //   'SrvcReqDtlCode': _encrypt(resolvedLeadId),
      //   'CreateBy': _encrypt(payload.createdBy),
      //   'CreateDTim': _encrypt(currentDateTime),
      //   'internalcomment': _encrypt(payload.internalComment),
      //   'SyncStatus': _encrypt('Pending'),
      //   'TempSrvcReqDtlCode': _encrypt(payload.tempLeadId),
      //   'CltCode': _encrypt(clientCode),
      //   'SubActivityCode': _encrypt(''),
      //   'UpdateBy': _encrypt(''),
      //   'UpdateDTim': _encrypt(''),
      //   'IsActive': _encrypt('Y'),
      //   // Activity Code 1 fields
      //   'AppThrough': _encrypt(fields['AppThrough']),
      //   'AppointmentDate': _encrypt(fields['AppointmentDate']),
      //   'PhoneNumber': _encrypt(fields['PhoneNumber']),
      //   'AppointmentAddrss': _encrypt(fields['AppointmentAddrss']),
      //   'Hour': _encrypt(fields['Hour']),
      //   'Minute': _encrypt(fields['Minute']),
      // };

      await db.transaction((transaction) async {
        // Android deletes the old row for the same
        // lead and activity before inserting.
        await transaction.delete(
          trackerTable,
          where:
              'SrvcReqDtlCode = ? '
              'AND ActivityCode = ?',
          whereArgs: [_encrypt(resolvedLeadId), _encrypt(payload.activityCode)],
        );

        await transaction.insert(trackerTable, trackerData);

        await transaction.update(
          leadTable,
          {
            'ActivityStatus': _encrypt(payload.activityCode),
            'UpdatedBy': _encrypt(payload.createdBy),
            'UpdateDTim': _encrypt(currentDateTime),
          },
          where: 'SrvcReqDtlCode = ?',
          whereArgs: [_encrypt(resolvedLeadId)],
        );

        final calendarMovementDate = _getCalendarMovementDate(payload);

        if (calendarMovementDate.isNotEmpty) {
          // Dashboard must run first because the calendar method
          // updates LeadDetails.CreateDTim.
          if (dashboardTable != null) {
            await _moveLeadToDashboardDate(
              executor: transaction,
              leadTable: leadTable,
              dashboardTable: dashboardTable,
              resolvedLeadId: resolvedLeadId,
              loginSapCode: payload.createdBy,
              activityDate: calendarMovementDate,
            );
          }

          await _moveLeadToCalendarDate(
            executor: transaction,
            leadTable: leadTable,
            calendarTable: calendarTable,
            resolvedLeadId: resolvedLeadId,
            loginSapCode: payload.createdBy,
            appointmentDate: calendarMovementDate,
          );
        }

        final terminalLeadStatus = _getTerminalLeadStatus(
          payload.normalizedActivityCode,
        );

        if (terminalLeadStatus != null) {
          await _updateTerminalActivityCalendar(
            executor: transaction,
            leadTable: leadTable,
            calendarTable: calendarTable,
            resolvedLeadId: resolvedLeadId,
            loginSapCode: payload.createdBy,
            leadStatus: terminalLeadStatus,
          );
        }
        if (terminalLeadStatus != null && dashboardTable != null) {
          await _updateTerminalActivityDashboard(
            executor: transaction,
            leadTable: leadTable,
            dashboardTable: dashboardTable,
            resolvedLeadId: resolvedLeadId,
            loginSapCode: payload.createdBy,
            leadStatus: terminalLeadStatus,
            activityCode: payload.normalizedActivityCode,
            subActivityCode: fields['SubActivityCode']?.toString().trim() ?? '',
          );
        }
      });

      // return UpdateActivitySaveResult.localSuccess(
      //   resolvedLeadId: resolvedLeadId,
      //   message: 'Activity saved locally and calendar updated successfully.',
      // );

      if (payload.normalizedActivityCode == '36' && dashboardTable != null) {
        final subActivityCode =
            fields['SubActivityCode']?.toString().trim() ?? '';

        await SaveActivityOfflineRepository.updateSalesCloseDashboardTbl(
          resolvedLeadId,
          payload.normalizedActivityCode,
          subActivityCode,
          payload.createdBy,
          resolvedLeadId,
          wasLeadParked,
          payload.normalizedActivityCode,
          subActivityCode,
        );
      }

      if (payload.normalizedActivityCode == '37') {
        final expectedClosureDate =
            fields['ExpectedClosureDate']?.toString().trim() ?? '';

        await SaveActivityOfflineRepository.updateLeadDateToCalendarTbl(
          resolvedLeadId,
          payload.createdBy,
          payload.normalizedActivityCode,
        );

        await SaveActivityOfflineRepository.updateLeadDateToDashboardTbl(
          resolvedLeadId,
          payload.normalizedActivityCode,
          resolvedLeadId,
          payload.createdBy,
          isParkedLead: wasLeadParked,
          edtExpectedClosureDate: expectedClosureDate,
          mExistingActivityCode: existingActivityCode,
        );
      }
      final isConnected = await _isConnected();

      // Keep temporary and offline activities Pending.
      if (!isConnected || resolvedLeadId.startsWith('T')) {
        return UpdateActivitySaveResult.localSuccess(
          resolvedLeadId: resolvedLeadId,
          message:
              'Activity saved offline. It will sync when internet is available.',
        );
      }

      // final dashboardTable = await _findOptionalTable(db, [
      //   'DashboardData_Mob',
      //   'Tbl_DashboardData_Mob',
      // ]);

      final syncedOnline = await _syncActivityOnline(
        db: db,
        trackerTable: trackerTable,
        calendarTable: calendarTable,
        dashboardTable: dashboardTable,
        resolvedLeadId: resolvedLeadId,
        activityCode: payload.activityCode,
        loginSapCode: payload.createdBy,
      );

      if (syncedOnline) {
        return UpdateActivitySaveResult.onlineSuccess(
          resolvedLeadId: resolvedLeadId,
          message: 'Activity saved and synchronized successfully.',
        );
      }

      return UpdateActivitySaveResult.localSuccess(
        resolvedLeadId: resolvedLeadId,
        message:
            'Activity saved locally, but server synchronization is pending.',
      );
    } catch (error, stackTrace) {
      print('saveActivity error: $error');
      print(stackTrace);

      return UpdateActivitySaveResult.failure(
        resolvedLeadId: payload.leadId,
        message: 'Unable to save activity locally.',
      );
    }
  }
}
