import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/core/apicall/get_dashbaord_data.dart';
import 'package:flutter_bottom_nav/core/apicall/getdata_fordashboard.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/Dashboard/dashboard_detail_model.dart';
import 'package:flutter_bottom_nav/models/Dashboard/dashboard_summary_model.dart';
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

  String _dashboardDetailApiMonth(String month) {
    // converts 2026-07-01 to 01-07-2026 for GetDataForDashboard
    final parts = month.split("-");

    if (parts.length == 3 && parts[0].length == 4) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
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
            {
              "DashboardUpdatedDate": EncryptionUtil.encrypt(lastCreateDTime!),
            }, // lastCreateDTime},
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
  // Future<List<Map<String, dynamic>>> loadDashboard({
  //   required String rmCode,
  //   required String month,
  // }) async {
  //   final exists = await isDataAvailable(rmCode, month);

  //   if (exists) {
  //     return await getFromDb(rmCode,month);
  //   } else {
  //     final success = await fetchAndStoreDashboard(
  //       userId: rmCode,
  //       month: month,
  //     );

  //     if (success) {
  //       return await getFromDb(rmCode,month);
  //     } else {
  //       return [];
  //     }
  //   }
  // }

  //changed method added by Rahul on 30June2026

  Future<List<Map<String, dynamic>>> loadDashboard({
    required String rmCode,
    required String month,
    bool forceRefresh = false,
  }) async {
    final exists = await isDataAvailable(rmCode, month);

    if (exists && !forceRefresh) {
      return await getFromDb(rmCode, month);
    }

    final success = await fetchAndStoreDashboard(userId: rmCode, month: month);

    if (success) {
      return await getFromDb(rmCode, month);
    }

    return [];
  }

  Future<DashboardSummary> calculateSummary(
    String rmCode,
    String month, {
    int leadType = 1,
  }) async {
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

    int lostToCompetitionCount = 0;
    int notRespondingCount = 0;
    int notInterestedCount = 0;

    double lostToCompetitionAmount = 0;
    double notRespondingAmount = 0;
    double notInterestedAmount = 0;

    int parkedCount = 0;
    int followUpCount = 0;
    double parkedAmount = 0;
    double followUpAmount = 0;

    int premiumCollectedCount = 0;
    int policyIssuedCount = 0;
    double premiumCollectedAmount = 0;
    double policyIssuedAmount = 0;

    for (var row in rows) {
      String sActivity = row["Activity"]?.toString() ?? "";
      String sSubActivity = row["SubActivity"]?.toString() ?? "";

      final rowLeadType = (row["LeadType"] ?? "")
          .toString()
          .trim()
          .toUpperCase();

      // Contact selected: Android logic = LeadType != "L"
      if (leadType == 2 && rowLeadType == "L") {
        continue;
      }

      // Lead selected: Android logic = LeadType == "L"
      if (leadType == 3 && rowLeadType != "L") {
        continue;
      }

      int leadConverted =
          int.tryParse(row["LeadConverted"]?.toString() ?? "0") ?? 0;
      int leadLost = int.tryParse(row["LeadLost"]?.toString() ?? "0") ?? 0;
      int wipLeads = int.tryParse(row["WIPLeads"]?.toString() ?? "0") ?? 0;
      double amount = double.tryParse(row["Amount"]?.toString() ?? "0") ?? 0;

      // lostToCompetitionCount +=
      //     int.tryParse(row["Lost_To_Competition"]?.toString() ?? "0") ?? 0;

      // notRespondingCount +=
      //     int.tryParse(row["Customer_Not_Responding"]?.toString() ?? "0") ?? 0;

      // notInterestedCount +=
      //     int.tryParse(row["Customer_Not_Interested"]?.toString() ?? "0") ?? 0;

      final lostToCompetition =
          int.tryParse(row["Lost_To_Competition"]?.toString() ?? "0") ?? 0;

      final notResponding =
          int.tryParse(row["Customer_Not_Responding"]?.toString() ?? "0") ?? 0;

      final notInterested =
          int.tryParse(row["Customer_Not_Interested"]?.toString() ?? "0") ?? 0;

      lostToCompetitionCount += lostToCompetition;
      notRespondingCount += notResponding;
      notInterestedCount += notInterested;

      if (lostToCompetition > 0) {
        lostToCompetitionAmount += amount;
      }

      if (notResponding > 0) {
        notRespondingAmount += amount;
      }

      if (notInterested > 0) {
        notInterestedAmount += amount;
      }
      // parkedCount += int.tryParse(row["ParkLead"]?.toString() ?? "0") ?? 0;

      // followUpCount += int.tryParse(row["FollowUp"]?.toString() ?? "0") ?? 0;

      final parkLead = int.tryParse(row["ParkLead"]?.toString() ?? "0") ?? 0;

      final followUp = int.tryParse(row["FollowUp"]?.toString() ?? "0") ?? 0;

      parkedCount += parkLead;
      followUpCount += followUp;

      if (parkLead > 0) {
        parkedAmount += amount;
      }

      if (followUp > 0) {
        followUpAmount += amount;
      }
      //new added

      // premiumCollectedCount +=
      //     int.tryParse(row["Premium_Collected"]?.toString() ?? "0") ?? 0;

      // policyIssuedCount +=
      //     int.tryParse(row["Policy_Issued"]?.toString() ?? "0") ?? 0;
      final premiumCollected =
          int.tryParse(row["Premium_Collected"]?.toString() ?? "0") ?? 0;

      final policyIssued =
          int.tryParse(row["Policy_Issued"]?.toString() ?? "0") ?? 0;

      premiumCollectedCount += premiumCollected;
      policyIssuedCount += policyIssued;

      if (premiumCollected > 0) {
        premiumCollectedAmount += amount;
      }

      if (policyIssued > 0) {
        policyIssuedAmount += amount;
      }

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
      lostToCompetitionCount: lostToCompetitionCount,
      notRespondingCount: notRespondingCount,
      notInterestedCount: notInterestedCount,
      lostToCompetitionAmount: lostToCompetitionAmount,
      notRespondingAmount: notRespondingAmount,
      notInterestedAmount: notInterestedAmount,
      parkedCount: parkedCount,
      followUpCount: followUpCount,
      parkedAmount: parkedAmount,
      followUpAmount: followUpAmount,
      premiumCollectedCount: premiumCollectedCount,
      policyIssuedCount: policyIssuedCount,
      premiumCollectedAmount: premiumCollectedAmount,
      policyIssuedAmount: policyIssuedAmount,
    );
  }

  Future<List<DashboardDetailModel>> getDashboardDetailsFromDb({
    required String rmCode,
    required String month,
    required String status,
    int leadType = 1,
  }) async {
    final db = await dbHelper.database;
    final monthValue = _monthKey(month);

    final whereParts = <String>["UserId = ?", "MothYear = ?"];

    final whereArgs = <Object?>[rmCode, monthValue];

    // 1 = All
    // 2 = Contact => LeadType != L
    // 3 = Lead => LeadType == L
    if (leadType == 2) {
      whereParts.add("(LeadType IS NULL OR UPPER(TRIM(LeadType)) != ?)");
      whereArgs.add("L");
    } else if (leadType == 3) {
      whereParts.add("UPPER(TRIM(LeadType)) = ?");
      whereArgs.add("L");
    }

    final normalizedStatus = status.trim().toLowerCase();

    if (normalizedStatus == "converted") {
      whereParts.add("Activity IN (?, ?, ?, ?)");
      whereArgs.addAll(["04", "4", "17", "35"]);
    } else if (normalizedStatus == "lost") {
      whereParts.add("Activity IN (?, ?, ?, ?, ?)");
      whereArgs.addAll(["05", "5", "24", "29", "38"]);
    } else if (normalizedStatus == "sale closed") {
      whereParts.add("Activity = ?");
      whereArgs.add("36");
    } else if (normalizedStatus == "open") {
      whereParts.add("Activity NOT IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
      whereArgs.addAll([
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
      ]);
    }

    final rows = await db.query(
      "LeadDetails",
      where: whereParts.join(" AND "),
      whereArgs: whereArgs,
      orderBy: "RecId DESC",
    );

    return rows.map((row) => DashboardDetailModel.fromDb(row)).toList();
  }

  //dashboard lost lead saving for grid data
  Future<bool> savegriddashboarddata({
    required String rmCode,
    required String month,
    required String activityCode,
    required String subActivityCode,
    required String statusFlag,
  }) async {
    try {
      final response = await GetDataForDashboard.getDataForDashboard(
        UserId: rmCode,
        CurMonth: _dashboardDetailApiMonth(month),
        //CurMonth: month,
        ActivityCode: activityCode,
        SubActivityCode: subActivityCode,
        Status: statusFlag,
      );

      final table = response["Table"];

      if (table == null || table is! List || table.isEmpty) {
        print("GetDataForDashboard Table empty");
        return false;
      }

      final db = await dbHelper.database;
      final batch = db.batch();

      final monthValue = month.length >= 7 ? month.substring(0, 7) : month;

      String encryptValue(dynamic value) {
        return CommonUtil.encryptIfNotEmpty(value?.toString() ?? "");
      }

      for (final row in table) {
        if (row is! Map) continue;

        final item = Map<String, dynamic>.from(row);

        final srvcReqDtlCode = item["SrvcReqDtlCode"]?.toString() ?? "";

        if (srvcReqDtlCode.trim().isEmpty) {
          continue;
        }

        final leadMap = <String, dynamic>{
          // Keep these plain because they are used in query/filter/navigation
          "SrvcReqDtlCode": srvcReqDtlCode,
          "UserId":
              item["UserId"]?.toString().toUpperCase() ?? rmCode.toUpperCase(),
          "SMCode": item["SMCode"]?.toString() ?? rmCode,
          "MothYear": item["MothYear"]?.toString().isNotEmpty == true
              ? item["MothYear"].toString()
              : monthValue,
          "Activity": item["ActivityCode"]?.toString().isNotEmpty == true
              ? item["ActivityCode"].toString()
              : activityCode,
          "SubActivity": item["SubActivityCode"]?.toString().isNotEmpty == true
              ? item["SubActivityCode"].toString()
              : subActivityCode,
          "LeadType": item["LeadType"]?.toString() ?? "",

          // Dashboard grid fields
          "PolicyNo": encryptValue(item["PolicyNo"]),
          "ProdName": encryptValue(item["ProdName"]),
          "leadAmt": encryptValue(item["leadAmt"]),
          "Amount": encryptValue(item["Amount"]),
          "Name": encryptValue(item["Name"]),

          // View Details fields
          "MobileTel": encryptValue(item["MobileTel"]),
          "Email": encryptValue(item["Email"]),
          "InstallmentPrem": encryptValue(item["InstallmentPrem"]),
          "Make": encryptValue(item["Make"]),
          "Model": encryptValue(item["Model"]),
          "PolNCB": encryptValue(item["PolNCB"]),
          "ActivityStatus": encryptValue(item["ActivityStatus"]),
          "WFStatus": encryptValue(item["WFStatus"]),
          "WFStatDesc": encryptValue(item["WFStatDesc"]),

          // Telesales fields
          "TelesaleActivity": encryptValue(item["TelesaleActivity"]),
          "TelesaleActivityDoneBy": encryptValue(
            item["TelesaleActivityDoneBy"],
          ),
          "TelesaleActivityDate": encryptValue(item["TelesaleActivityDate"]),
          "TelesaleRemark": encryptValue(item["TelesaleRemark"]),

          // Lead Summary fields
          "CustTypeDesc": encryptValue(item["CustTypeDesc"]),
          "CustPriorityDesc": encryptValue(item["CustPriorityDesc"]),
          "LOB": encryptValue(item["LOB"]),
          "LeadTypeDesc": encryptValue(item["LeadTypeDesc"]),
          "SaleTypeDesc": encryptValue(item["SaleTypeDesc"]),
          "isOwner": encryptValue(item["isOwner"]),
          "OwnerName": encryptValue(item["OwnerName"]),
          "AssignedTo": encryptValue(item["AssignedTo"]),
          "AssignedToName": encryptValue(item["AssignedToName"]),
          "ReqChannel": encryptValue(item["ReqChannel"]),
          "ReqChannelId": encryptValue(item["ReqChannelId"]),
          "LeadSource": encryptValue(item["LeadSource"]),
          "LeadSourceDesc": encryptValue(item["LeadSourceDesc"]),
          "LeadSubSource": encryptValue(item["LeadSubSource"]),
          "LeadSubSourceDesc": encryptValue(item["LeadSubSourceDesc"]),
          "LeadAging": encryptValue(item["LeadAging"]),
          "BusinessType": encryptValue(item["BusinessType"]),
          "BusinessTypeDesc": encryptValue(item["BusinessTypeDesc"]),
          "LeadRating": encryptValue(item["LeadRating"]),
          "Breaking": encryptValue(item["Breaking"]),
          "PrevPolicyNo": encryptValue(item["PrevPolicyNo"]),

          // Useful extra fields for cards / renewals / future use
          "PolicyEndDate": encryptValue(item["PolicyEndDate"]),
          "SrvcFromDTim": encryptValue(item["SrvcFromDTim"]),
          "SrvcComments": encryptValue(item["SrvcComments"]),
          "RenewalPaymentLink": encryptValue(item["RenewalPaymentLink"]),
          "LOBCode": encryptValue(item["LOBCode"]),
          "ProdCode": encryptValue(item["ProdCode"]),
          "AgentCode": encryptValue(item["AgentCode"]),
          "AgentName": encryptValue(item["AgentName"]),
          "CreatedBy": encryptValue(item["CreatedBy"]),
          "CreateDTim": encryptValue(item["CreateDTim"]),
          "UpdatedBy": encryptValue(item["UpdatedBy"]),
          "UpdateDTim": encryptValue(item["UpdateDTim"]),
          "Remark": encryptValue(item["Remark"]),

          // Local status
          "SyncStatus": CommonUtil.encryptIfNotEmpty("Complete"),
        };

        batch.delete(
          "LeadDetails",
          where: "SrvcReqDtlCode = ?",
          whereArgs: [srvcReqDtlCode],
        );

        batch.insert(
          "LeadDetails",
          leadMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);

      final count = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM LeadDetails"),
      );

      print("LeadDetails total after savegriddashboarddata = $count");

      return true;
    } catch (e, st) {
      print("savegriddashboarddata error: $e");
      print(st);
      return false;
    }
  }
}
