import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/async_updateactivity.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/OfflineSync/update_activity_sync_result.dart';

class UpdateActivitySyncService {
  UpdateActivitySyncService._();

  static bool isSyncing = false;

  /// Reads all Update Activity records having SyncStatus = Pending.
  static Future<List<Map<String, String>>> _getPendingActivities() async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'LMSLeadActivityTracker',
      columns: ['SrvcReqDtlCode', 'ActivityCode', 'CreateBy'],
      where: 'SyncStatus = ?',
      whereArgs: [CommonUtil.encryptIfNotEmpty('Pending')],
      orderBy: 'RecId ASC',
    );

    return rows
        .map<Map<String, String>>((row) {
          return {
            'leadId': CommonUtil.decryptIfNotEmpty(
              row['SrvcReqDtlCode']?.toString() ?? '',
            ),
            'activityCode': CommonUtil.decryptIfNotEmpty(
              row['ActivityCode']?.toString() ?? '',
            ),
            'sapCode': CommonUtil.decryptIfNotEmpty(
              row['CreateBy']?.toString() ?? '',
            ),
          };
        })
        .where((activity) {
          return (activity['leadId'] ?? '').trim().isNotEmpty;
        })
        .toList();
  }

  static Future<UpdateActivitySyncResult> syncPendingActivities() async {
    // Prevent multiple synchronization processes.
    if (isSyncing) {
      return const UpdateActivitySyncResult(total: 0, success: 0, failed: 0);
    }

    isSyncing = true;

    try {
      final pendingActivities = await _getPendingActivities();

      int successCount = 0;
      int failedCount = 0;

      for (final activity in pendingActivities) {
        final leadId = activity['leadId']?.trim() ?? '';
        final activityCode = activity['activityCode']?.trim() ?? '';
        final sapCode = activity['sapCode']?.trim() ?? '';

        if (leadId.isEmpty || activityCode.isEmpty) {
          failedCount++;
          continue;
        }

        if (leadId.startsWith('T')) {
          failedCount++;
          continue;
        }

        try {
          final response = await UpdateActivityService.call(
            srvcReqDtlCode: leadId,
          );

          if (_isSuccessResponse(response)) {
            await _markActivityAsSuccess(
              leadId: leadId,
              activityCode: activityCode,
              sapCode: sapCode,
            );

            successCount++;
          } else {
            // Keep SyncStatus as Pending so it can be retried.
            failedCount++;
          }
        } catch (error) {
          print('Sync failed for Lead $leadId: $error');

          // Keep SyncStatus as Pending.
          failedCount++;
        }
      }

      return UpdateActivitySyncResult(
        total: pendingActivities.length,
        success: successCount,
        failed: failedCount,
      );
    } catch (error, stackTrace) {
      print('Update Activity sync error: $error');
      print(stackTrace);

      return const UpdateActivitySyncResult(total: 0, success: 0, failed: 1);
    } finally {
      isSyncing = false;
    }
  }

  static bool _isSuccessResponse(Map<String, dynamic> response) {
    final table = response['Table'];

    if (table is! List || table.isEmpty) {
      return false;
    }

    return table.any(
      (item) => item is Map && item['ResponseCode']?.toString().trim() == '0',
    );
  }

  static Future<void> _markActivityAsSuccess({
    required String leadId,
    required String activityCode,
    required String sapCode,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {
      await txn.update(
        'LMSLeadActivityTracker',
        {
          'UpdateBy': CommonUtil.encryptIfNotEmpty(sapCode),
          'SyncStatus': CommonUtil.encryptIfNotEmpty('Success'),
        },
        where: 'SrvcReqDtlCode = ? AND ActivityCode = ?',
        whereArgs: [
          CommonUtil.encryptIfNotEmpty(leadId),
          CommonUtil.encryptIfNotEmpty(activityCode),
        ],
      );

      await txn.update(
        'CalendarData_Mob',
        {'SyncStatus': CommonUtil.encryptIfNotEmpty('Completed')},
        where: 'ReferenceNo = ?',
        whereArgs: [CommonUtil.encryptIfNotEmpty(leadId)],
      );

      await txn.update(
        'DashboardData_Mob',
        {'SyncStatus': CommonUtil.encryptIfNotEmpty('Completed')},
        where: 'ReferenceNo = ?',
        whereArgs: [CommonUtil.encryptIfNotEmpty(leadId)],
      );
    });
  }
}
