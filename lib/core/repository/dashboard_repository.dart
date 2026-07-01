import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/core/apicall/get_dashbaord_data.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/dashboard_summary_model.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DashboardRepository {
  final DatabaseHelper dbHelper;

  DashboardRepository(this.dbHelper);

  String _monthKey(String month) {
    // Converts 2026-06-01 to 2026-06
    if (month.length >= 7) {
      return month.substring(0, 7);
    }
    return month;
  }

  Future<bool> isDataAvailable(String rmCode, String month) async {
    final db = await dbHelper.database;
    final monthValue = _monthKey(month);

    final result = await db.query(
      "DashboardData_Mob",
      where: "UserId = ? AND MothYear = ?",
      whereArgs: [rmCode, monthValue],
    );

    return result.isNotEmpty;
  }

  /// Check if dashboard data exists in DB
  // Future<bool> isDataAvailable(String rmCode, String MothYear) async {
  //   final db = await dbHelper.database;

  //   final result = await db.query(
  //     "DashboardData_Mob",
  //     where: "UserId=? and MothYear=?",
  //     whereArgs: [rmCode, MothYear],
  //   );

  //   return result.isNotEmpty;
  // }

  /// Fetch from DB
  // Future<List<Map<String, dynamic>>> getFromDb(String rmCode) async {
  //   final db = await dbHelper.database;

  //   return await db.query(
  //     "DashboardData_Mob",
  //     where: "UserId = ?",
  //     whereArgs: [rmCode],
  //   );
  // }
  Future<List<Map<String, dynamic>>> getFromDb(
    String rmCode,
    String month,
  ) async {
    final db = await dbHelper.database;
    final monthValue = _monthKey(month);

    return await db.query(
      "DashboardData_Mob",
      where: "UserId = ? AND MothYear = ?",
      whereArgs: [rmCode, monthValue],
    );
  }

  /// Call API and insert into DB
  Future<bool> fetchAndStoreDashboard({
    required String userId,
    required String month,
  }) async {
    try {
      final response = await GetDashbaordData.getdashboarddata(
        UserId: userId,
        CurMonth: month,
      );

      print("Repository Response: $response");

      // 🔥 Correct key according to your API
      final List<dynamic>? tableList = response['Table'];

      if (tableList == null || tableList.isEmpty) {
        return false;
      }

      // Optional: check ResponseCode
      // if (tableList[0]['ResponseCode'] != 0) {
      //   return false;
      // }

      String? lastCreateDTime;
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        final monthValue = _monthKey(month);

        await txn.delete(
          "DashboardData_Mob",
          where: "UserId = ? AND MothYear = ?",
          whereArgs: [userId, monthValue],
        );

        // await txn.delete(
        //   "DashboardData_Mob",
        //   where: "UserId = ?",
        //   whereArgs: [StaticVariables.mSAPCode],
        // );
        final batch = txn.batch();

        for (var item in tableList) {
          final Map<String, dynamic> dbMap = {
            "UserId": item["UserId"],
            "AgentCode": item["AgentCode"],
            "AgentName": item["AgentName"],
            "HNINCode": item["HNINCode"],
            "HNINName": item["HNINName"],
            "LOBCode": item["LOBCode"],
            "ProdCode": item["ProdCode"],
            "NCBFlag": item["NCBFlag"],
            "date": item["date"],
            "DateInLong": item["DateInLong"],
            "TotalLeads": item["TotalLeads"],
            "WIPLeads": item["WIPLeads"],
            "LeadConverted": item["LeadConverted"],
            "LeadLost": item["LeadLost"],
            "Lead_Converted": item["Lead_Converted"],
            "Premium_Collected": item["Premium_Collected"],
            "Policy_Issued": item["Policy_Issued"],
            "Call_Back": item["Call_Back"],
            "Appointment_Fixed": item["Appointment_Fixed"],
            "Non_Contactable": item["Non_Contactable"],
            "Lost_To_Competition": item["Lost_To_Competition"],
            "Customer_Not_Interested": item["Customer_Not_Interested"],
            "Customer_Not_Responding": item["Customer_Not_Responding"],
            "ParkLead": item["ParkLead"],
            "FollowUp": item["FollowUp"],
            "LeadType": item["LeadType"],
            "BizType": item["BizType"],
            "MarcketType": item["MarcketType"],
            "PolicyChanel": item["PolicyChanel"],
            "BMCMCode": item["BMCMCode"],
            "ircCode": item["ircCode"],
            "ircname": item["ircname"],
            "RNType": item["RNType"],
            "NetODPremium": item["NetODPremium"],
            "NetTPPremium": item["NetTPPremium"],
            "RNblockReason": item["RNblockReason"],
            "ProductGroup": item["ProductGroup"],
            "ProductSubCategory": item["ProductSubCategory"],
            "NILDep": item["NILDep"],
            "Category": item["Category"],
            "FuelType": item["FuelType"],
            "VehicleType": item["VehicleType"],
            "SeatingCapacity": item["SeatingCapacity"],
            "AgeGroup": item["AgeGroup"],
            "FamilySize": item["FamilySize"],
            "SumInsuredBand": item["SumInsuredBand"],
            "PreExiting": item["PreExiting"],
            "Occupancy": item["Occupancy"],
            "SumInsured": item["SumInsured"],
            "LifeGroup": item["LifeGroup"],
            "Zone": item["Zone"],
            "Region": item["Region"],
            "RenewalYearCount": item["RenewalYearCount"],
            "Preferred": item["Preferred"],
            "Activity": item["ActivityCode"],
            "SubActivity": item["SubActivityCode"],
            "Amount": item["Amount"],
            "SMName": item["SMName"],
            "SMBranch": item["SMBranch"],
            "SMBranchName": item["SMBranchName"],
            "CreatedBy": item["CreatedBy"],
            "CreateDTime": item["CreateDTime"],
            "UpdatedBy": item["UpdatedBy"],
            "UpdatedDtime": item["UpdatedDtime"],
            "MothYear": item["MothYear"] ?? monthValue,
            "SyncStatus": item["SyncStatus"],
          };

          lastCreateDTime = item["CreateDTime"]?.toString();

          batch.insert(
            "DashboardData_Mob",
            dbMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);

        if (lastCreateDTime != null) {
          await txn.update(
            "iUser",
            {"DashboardUpdatedDate":EncryptionUtil.encrypt(lastCreateDTime!)},// lastCreateDTime},
            where: "UserId = ?",
            whereArgs: [
              EncryptionUtil.encrypt(StaticVariables.mSAPCode.toUpperCase()),
            ],
          );
        }
      });

      return true;
    } catch (e) {
      print("Dashboard Error: $e");
      return false;
    }
  }

  /// Full Logic (DB First → API if empty)
  Future<List<Map<String, dynamic>>> loadDashboard({
    required String rmCode,
    required String month,
  }) async {
    final exists = await isDataAvailable(rmCode, month);

    if (exists) {
      return await getFromDb(rmCode,month);
    } else {
      final success = await fetchAndStoreDashboard(
        userId: rmCode,
        month: month,
      );

      if (success) {
        return await getFromDb(rmCode,month);
      } else {
        return [];
      }
    }
  }

  Future<DashboardSummary> calculateSummary(String rmCode, String month) async {
    final db = await dbHelper.database;

    final monthValue = _monthKey(month);

    final rows = await db.query(
      "DashboardData_Mob",
      where: "UserId = ?  and MothYear=?",
      whereArgs: [rmCode, monthValue],
    );

    int iConvertedCount = 0;
    double iConvertedRS = 0;

    int iLostCount = 0;
    double iLostRS = 0;

    int iOpenCount = 0;
    double iOpenRS = 0;

    int iSalesCloseCount = 0;
    double iSalesCloseRS = 0;

    int totalLeads = 0;
    double totalGwp = 0;

    for (var row in rows) {
      String sActivity = row["Activity"]?.toString() ?? "";
      String sSubActivity = row["SubActivity"]?.toString() ?? "";

      int leadConverted =
          int.tryParse(row["LeadConverted"]?.toString() ?? "0") ?? 0;
      int leadLost = int.tryParse(row["LeadLost"]?.toString() ?? "0") ?? 0;
      int wipLeads = int.tryParse(row["WIPLeads"]?.toString() ?? "0") ?? 0;
      double amount = double.tryParse(row["Amount"]?.toString() ?? "0") ?? 0;

      totalLeads += leadConverted + leadLost + wipLeads;

      totalGwp += amount;

      // Converted
      if (["04", "4", "17", "35"].contains(sActivity)) {
        iConvertedCount += leadConverted;
        iConvertedRS += amount;
      }

      // Lost
      if (["05", "5", "24", "29", "38"].contains(sActivity)) {
        iLostCount += leadLost;
        iLostRS += amount;
      }

      // Sales Closed
      if (sActivity == "36") {
        iSalesCloseCount += wipLeads;
        iSalesCloseRS += amount;
      }

      // Open
      if (![
        "04",
        "4",
        "05",
        "5",
        "17",
        "24",
        "29",
        "35",
        "36",
        "38",
      ].contains(sActivity)) {
        iOpenCount += wipLeads;
        iOpenRS += amount;
      }
    }

    return DashboardSummary(
      totalLeads: totalLeads,
      totalGwp: totalGwp,
      convertedCount: iConvertedCount,
      convertedAmount: iConvertedRS,
      lostCount: iLostCount,
      lostAmount: iLostRS,
      openCount: iOpenCount,
      openAmount: iOpenRS,
      salesCloseCount: iSalesCloseCount,
      salesCloseAmount: iSalesCloseRS,
    );
  }
}
