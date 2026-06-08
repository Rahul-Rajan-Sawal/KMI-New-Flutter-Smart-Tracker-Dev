import 'package:flutter/foundation.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
// change CommonUtil import path according to your project

class CommonRepo {
  final dbHelper = DatabaseHelper.instance;

  Future<void> saveZoneRegionBranch({
    required Map<String, dynamic> response,
    required String year,
    required String month,
  }) async {
    try {
      final db = await dbHelper.database;

      final table = response["Table"];

      if (table == null || table is! List) {
        debugPrint("No Table found in GetDashboardParam response");
        return;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final item in table) {
          if (item is Map<String, dynamic>) {
            final Map<String, dynamic> zoneRegionBranchData = {
              "RMCode": CommonUtil.encryptIfNotEmpty(
                item["RMCode"]?.toString() ?? "",
              ),
              "Zone": CommonUtil.encryptIfNotEmpty(
                item["Zone"]?.toString() ?? "",
              ),
              "Region": CommonUtil.encryptIfNotEmpty(
                item["Region"]?.toString() ?? "",
              ),
              "BranchCode": CommonUtil.encryptIfNotEmpty(
                item["BranchCode"]?.toString() ?? "",
              ),
              "BranchName": CommonUtil.encryptIfNotEmpty(
                item["BranchName"]?.toString() ?? "",
              ),
              "UserId": CommonUtil.encryptIfNotEmpty(StaticVariables.mSAPCode),
              "SyncDate": CommonUtil.encryptIfNotEmpty(
                DateTime.now().toIso8601String(),
              ),
              "Month": CommonUtil.encryptIfNotEmpty(month),
              "Year": CommonUtil.encryptIfNotEmpty(year),
            };

            batch.insert("Tbl_ZoneRegionBranch", zoneRegionBranchData);

            print("inserted dashboardparam");
          }
        }

        await batch.commit(noResult: true);
      });

      debugPrint("Tbl_ZoneRegionBranch batch insert completed");
    } catch (e) {
      debugPrint("saveZoneRegionBranchListBatch Error: $e");
    }
  }

  Future<void> saveSalesManager({
    required Map<String, dynamic> response,
  }) async {
    try {
      final db = await dbHelper.database;

      final table = response["Table"];

      if (table == null || table is! List) {
        debugPrint("No Table found in SalesManager response");
        return;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final item in table) {
          if (item is Map<String, dynamic>) {
            final Map<String, dynamic> salesManagerData = {
              "RMCode": CommonUtil.encryptIfNotEmpty(
                item["RMCode"]?.toString() ?? "",
              ),
              "BranchCode": CommonUtil.encryptIfNotEmpty(
                item["BranchCode"]?.toString() ?? "",
              ),
              "SMCode": CommonUtil.encryptIfNotEmpty(
                item["SMCode"]?.toString() ?? "",
              ),
              "SMName": CommonUtil.encryptIfNotEmpty(
                item["SMName"]?.toString() ?? "",
              ),
              "UserId": CommonUtil.encryptIfNotEmpty(StaticVariables.mSAPCode),
              "SyncDate": CommonUtil.encryptIfNotEmpty(
                DateTime.now().toIso8601String(),
              ),
            };

            batch.insert("Tbl_SalesManager", salesManagerData);

            print("inserted salesmanager");
          }
        }

        await batch.commit(noResult: true);
      });

      debugPrint("Tbl_SalesManager batch insert completed");
    } catch (e) {
      debugPrint("saveSalesManagerListBatch Error: $e");
    }
  }

  Future<void> saveAgents({required Map<String, dynamic> response}) async {
    try {
      final db = await dbHelper.database;

      final table = response["Table"];

      if (table == null || table is! List) {
        debugPrint("No Table found in Agent response");
        return;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final item in table) {
          if (item is Map<String, dynamic>) {
            final Map<String, dynamic> agentData = {
              "SMCode": CommonUtil.encryptIfNotEmpty(
                item["SMCode"]?.toString() ?? "",
              ),
              "AgentCode": CommonUtil.encryptIfNotEmpty(
                item["AgentCode"]?.toString() ?? "",
              ),
              "AgentName": CommonUtil.encryptIfNotEmpty(
                item["AgentName"]?.toString() ?? "",
              ),
              "UserId": CommonUtil.encryptIfNotEmpty(StaticVariables.mSAPCode),
              "SyncDate": CommonUtil.encryptIfNotEmpty(
                DateTime.now().toIso8601String(),
              ),
            };

            batch.insert("Tbl_Agent", agentData);

            print("inserted agent");
          }
        }

        await batch.commit(noResult: true);
      });

      debugPrint("Tbl_Agent batch insert completed");
    } catch (e) {
      debugPrint("saveAgentListBatch Error: $e");
    }
  }

  //reference save
  Future<void> saveReference({
    required Map<String, dynamic> response,
  }) async {
    try {
      final db = await dbHelper.database;

      final table = response["Table"];

      if (table == null || table is! List) {
        debugPrint("No Table found in Reference response");
        return;
      }

      await db.transaction((txn) async {
        final batch = txn.batch();

        for (final item in table) {
          if (item is Map<String, dynamic>) {
            final Map<String, dynamic> referenceData = {
              "AgentCode": CommonUtil.encryptIfNotEmpty(
                item["AgentCode"]?.toString() ?? "",
              ),
              "ReferenceCode": CommonUtil.encryptIfNotEmpty(
                item["RefCode"]?.toString() ?? "",
              ),
              "ReferenceName": CommonUtil.encryptIfNotEmpty(
                item["RefName"]?.toString() ?? "",
              ),
              "UserId": CommonUtil.encryptIfNotEmpty(StaticVariables.mSAPCode),
              "SyncDate": CommonUtil.encryptIfNotEmpty(
                DateTime.now().toIso8601String(),
              ),
            };

            batch.insert("Tbl_Reference", referenceData);

            print("inserted reference");
          }
        }

        await batch.commit(noResult: true);
      });

      debugPrint("Tbl_Reference batch insert completed");
    } catch (e) {
      debugPrint("saveReferenceListBatch Error: $e");
    }
  }
}
