import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_model.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/updateactivity_loockup_model.dart';

class UpdateActivityRepository {
  const UpdateActivityRepository();

  /// Fetches the activities allowed for the current lead.
  ///
  /// Flow:
  /// CBLMSLeadActivityMapping
  ///          ↓
  /// CBLMSMSTActivity
  Future<List<UpdateActivityOption>> getActivities({
    required String reqChannelId,
    required String leadSourceId,
    required String leadType,
    required String bizType,
  }) async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      final requestChannel = reqChannelId.trim();
      final sourceId = leadSourceId.trim();
      final type = leadType.trim();
      final businessType = bizType.trim();

      if (requestChannel.isEmpty || sourceId.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> mappingResult = [];

      /*
       * Same activity-mapping condition used by Android.
       *
       * When BizType is available:
       * ReqChannelId + LeadType + LeadSourceId + Biztype + IssActivity
       *
       * Otherwise:
       * ReqChannelId + LeadSourceId + IssActivity
       */
      if (businessType.isNotEmpty) {
        mappingResult = await db.query(
          'CBLMSLeadActivityMapping',
          columns: ['Actvitycode'],
          where:
              'ReqChannelId = ? '
              'AND LeadType = ? '
              'AND LeadSourceId = ? '
              'AND Biztype = ? '
              'AND IssActivity = ?',
          whereArgs: [requestChannel, type, sourceId, businessType, 'Y'],
        );
      } else {
        mappingResult = await db.query(
          'CBLMSLeadActivityMapping',
          columns: ['Actvitycode'],
          where:
              'ReqChannelId = ? '
              'AND LeadSourceId = ? '
              'AND IssActivity = ?',
          whereArgs: [requestChannel, sourceId, 'Y'],
        );
      }

      final activityCodes = <String>[];

      for (final row in mappingResult) {
        final code = row['Actvitycode']?.toString().trim() ?? '';

        if (code.isNotEmpty && !activityCodes.contains(code)) {
          activityCodes.add(code);
        }
      }

      if (activityCodes.isEmpty) {
        return [];
      }

      final placeholders = List.filled(activityCodes.length, '?').join(',');

      final activityMasterResult = await db.query(
        'CBLMSMSTActivity',
        columns: ['ActivityCode', 'ActivityDesc1'],
        where: 'ActivityCode IN ($placeholders)',
        whereArgs: activityCodes,
        orderBy: 'CAST(ActivityCode AS INTEGER) ASC',
      );

      final activities = activityMasterResult
          .map(UpdateActivityOption.fromMap)
          .where(
            (activity) =>
                activity.code.isNotEmpty && activity.description.isNotEmpty,
          )
          .toList();

      return activities;
    } catch (e, stackTrace) {
      print('getActivities error: $e');
      print(stackTrace);

      return [];
    }
  }

  Future<List<UpdateActivityLookupOption>> getLookupOptions({
    required String lookupCode,
  }) async {
    try {
      final cleanLookupCode = lookupCode.trim();

      if (cleanLookupCode.isEmpty) {
        return [];
      }

      final db = await OfflineDBHelper.getDatabase();

      final result = await db.query(
        'LookUpSU',
        columns: ['ParamValue', 'ParamDesc1', 'SortOrder'],
        where:
            'LookUpCode = ? '
            'AND ParamValue IS NOT NULL '
            'AND TRIM(ParamValue) != ? '
            'AND ParamDesc1 IS NOT NULL '
            'AND TRIM(ParamDesc1) != ?',
        whereArgs: [cleanLookupCode, '', ''],
        orderBy: 'CAST(SortOrder AS INTEGER) ASC',
      );

      return result
          .map(UpdateActivityLookupOption.fromMap)
          .where(
            (option) => option.code.isNotEmpty && option.description.isNotEmpty,
          )
          .toList();
    } catch (e, stackTrace) {
      print('getLookupOptions error for lookupCode $lookupCode: $e');
      print(stackTrace);

      return [];
    }
  }

  Future<List<UpdateActivityOption>> getSubActivities({
    required String reqChannelId,
    required String leadSourceId,
    required String leadType,
    required String bizType,
    required String activityCode,
  }) async {
    if (reqChannelId.trim().isEmpty ||
        leadSourceId.trim().isEmpty ||
        activityCode.trim().isEmpty) {
      return [];
    }

    final db = await OfflineDBHelper.getDatabase();

    final whereParts = <String>[
      'ReqChannelId = ?',
      'LeadSourceId = ?',
      'IssActivity = ?',
      'Actvitycode = ?',
    ];

    final whereArgs = <dynamic>[
      reqChannelId.trim(),
      leadSourceId.trim(),
      'Y',
      activityCode.trim(),
    ];

    if (leadType.trim().isNotEmpty) {
      whereParts.add('LeadType = ?');
      whereArgs.add(leadType.trim());
    }

    if (bizType.trim().isNotEmpty) {
      whereParts.add('Biztype = ?');
      whereArgs.add(bizType.trim());
    }

    final mappingRows = await db.query(
      'CBLMSLeadActivityMapping',
      columns: ['ActivitySubCode'],
      where: whereParts.join(' AND '),
      whereArgs: whereArgs,
    );

    final subActivityCodes = mappingRows
        .map((row) => row['ActivitySubCode']?.toString().trim() ?? '')
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList();

    if (subActivityCodes.isEmpty) {
      return [];
    }

    final placeholders = List.filled(subActivityCodes.length, '?').join(',');

    final masterRows = await db.rawQuery('''
    SELECT DISTINCT
      ActivitySubCode,
      ActivityCodeDesc1
    FROM CBLMSMSTSubActivity
    WHERE ActivitySubCode IN ($placeholders)
    ORDER BY CAST(ActivitySubCode AS INTEGER)
    ''', subActivityCodes);

    return masterRows
        .map((row) {
          return UpdateActivityOption(
            code: row['ActivitySubCode']?.toString().trim() ?? '',
            description: row['ActivityCodeDesc1']?.toString().trim() ?? '',
          );
        })
        .where((option) {
          return option.code.isNotEmpty && option.description.isNotEmpty;
        })
        .toList();
  }
}
