import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/common/common_singltbtn_popup.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/async_updateactivity.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/repository/activityrepository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:path/path.dart';

class SaveActivityOfflineRepository {
  // ENCRYPTION HELPERS
  static String _enc(dynamic val) =>
      EncryptionUtil.encrypt(val?.toString() ?? "");

  static String? _dec(dynamic val) =>
      EncryptionUtil.decrypt(val?.toString() ?? "");

  // ================= DATE FORMATTING =================
  static String convertFormatDate(String? inputDate) {
    try {
      if (inputDate == null || inputDate.isEmpty) return "";
      final parsedDate = DateTime.parse(inputDate);
      final day = parsedDate.day.toString().padLeft(2, '0');
      final month = parsedDate.month.toString().padLeft(2, '0');
      final year = parsedDate.year.toString();
      return "$day-$month-$year";
    } catch (e) {
      return "";
    }
  }

  // static String _formatAndroidDateTime(DateTime dt) {
  //   final ms = dt.millisecond.toString().padLeft(3, '0');
  //   return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
  //       "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}.$ms";
  // }

  static String _formatAndroidDateTime(DateTime dt) {
  String day = dt.day.toString().padLeft(2, '0');
  String month = dt.month.toString().padLeft(2, '0');
  String year = dt.year.toString();

  int hour = dt.hour;
  String minute = dt.minute.toString().padLeft(2, '0');

  String amPm = hour >= 12 ? "pm" : "am";

  return "$day-$month-$year ${hour.toString().padLeft(2, '0')}:$minute $amPm";
}

  // ================= SAFE PARSING =================
  static int _parseIntSafe(String? value) {
    if (value == null) return 0;
    return int.tryParse(value.trim()) ?? 0;
  }

  static double _parseDoubleSafe(String? value) {
    if (value == null) return 0.0;
    return double.tryParse(value.trim()) ?? 0.0;
  }

  // ================= ✅ FIX #2: equalsIgnoreCase parity - use compareTo =================
  static bool _eq(String? a, String b) {
    if (a == null) return false;
    return a.toLowerCase().compareTo(b.toLowerCase()) == 0; // ✅ FIX #2
  }

  // ================= CONNECTIVITY CHECK =================
  static Future<bool> _isConnected() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      try {
        final lookup = await InternetAddress.lookup('google.com');
        return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  // getMSTActivityDesc 
  static Future<String> getActivityDesc(String actCode) async {
    String desc = "Not Available";
    final db = await DatabaseHelper.instance.database;
    try {
      final cursor = await db.query(
        "CBLMSMSTActivity",
        where: "ActivityCode = ?",
        whereArgs: [actCode],
      );

      
      Map<String, dynamic>? lastRow;
      for (var row in cursor) {
        lastRow = row;
      }

      if (lastRow != null &&
          lastRow.containsKey("ActivityDesc1") &&
          lastRow["ActivityDesc1"] != null) {
        desc = lastRow["ActivityDesc1"].toString();
      }
    } catch (_) {}
    return desc;
  }

  //  NOTIFICATION/ALERT
  static Future<void> _showAlert(String title, String message) async {
    print("🔔 [$title] $message");
  }

  static Future<void> _insertNotification({
    required String title,
    required String message,
    required String dateTime,
    required String createdBy,
    //required String type,
  }) async {
    
    try{final db = await DatabaseHelper.instance.database;
    await db.insert("NotificationDetails", {
      "Title": _enc(title),
      "Message": _enc(message),
      "DateTime": _enc(dateTime),
      "CreatedBy": _enc(createdBy),
      //"Type": _enc(type),
      "SyncStatus": _enc("Pending"),
    });}catch(e){
      print(" Exception caught of Notification insert : $e");
    }
  }

  //  SYNC STATUS UPDATES 
  static Future<void> _updateSyncStatusAfterSuccess({
    required String leadID,
    required String activityCode,
    required String loginSAPCode,
  }) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      "LMSLeadActivityTracker",
      {"UpdateBy": _enc(loginSAPCode), "SyncStatus": _enc("Success")},
      where: "SrvcReqDtlCode = ? AND ActivityCode = ?",
      whereArgs: [_enc(leadID), _enc(activityCode)],
    );

    await db.update(
      "CalendarData_Mob",
      {"SyncStatus": _enc("Completed")},
      where: "ReferenceNo = ?",
      whereArgs: [_enc(leadID)],
    );

    await db.update(
      "DashboardData_Mob",
      {"SyncStatus": _enc("Completed")},
      where: "ReferenceNo = ?",
      whereArgs: [_enc(leadID)],
    );
  }

  // ONLINE SYNC
  static Future<void> _performOnlineSync({
    required String resolvedLeadID,
    required String activityCode,
    required String loginSAPCode,
  }) async {
    try {
      // final response = await UpdateActivityService.call(
      //   srvcReqDtlCode: resolvedLeadID,
      // );
      final response = await UpdateActivityService.call(
        srvcReqDtlCode: resolvedLeadID, // MUST be actual SrvcReqDtlCode from DB
      );

      final tableArray = response["Table"] as List?;

      if (tableArray != null && tableArray.isNotEmpty) {
        for (var item in tableArray) {
          final responseCode = item["ResponseCode"]?.toString();

          if (responseCode == "0") {
            await _updateSyncStatusAfterSuccess(
              leadID: resolvedLeadID,
              activityCode: activityCode,
              loginSAPCode: loginSAPCode,
            );

            final activityDesc = await getActivityDesc(activityCode);
            final successMsg =
                "Activity Disposition of Lead number $resolvedLeadID for $activityDesc is updated successfully.";

            await _showAlert("Activity Disposition", successMsg);
            await _insertNotification(
              title: "Activity Disposition",
              message: successMsg,
              dateTime: _formatAndroidDateTime(DateTime.now()),
              createdBy: loginSAPCode,
             // type: "Online Activity Disposition",
            );
            break;
          } else {
            final errorMsg =
                item["ErrorMessage"] ??
                item["ErrorDescription"] ??
                "Unknown error";
            final activityDesc = await getActivityDesc(activityCode);
            final failMsg =
                "Activity Disposition of Lead number $resolvedLeadID for $activityDesc is failed. Due to $errorMsg";

           // CommonSinglePopup(message: failMsg,title: "Activity Disposition Failed ", onOk:(){ Navigator.pop(context);},);
            await _showAlert("Failed Activity Disposition", failMsg);
            await _insertNotification(
              title: "Failed Activity Disposition",
              message: failMsg,
              dateTime: _formatAndroidDateTime(DateTime.now()),
              createdBy: loginSAPCode,
              //type: "Online Activity Disposition",
            );
          }
        }
      } else {
        final activityDesc = await getActivityDesc(activityCode);
        final failMsg =
            "Activity Disposition of Lead number $resolvedLeadID for $activityDesc is failed. No response data.";

        await _showAlert("Failed Activity Disposition", failMsg);
        await _insertNotification(
          title: "Failed Activity Disposition",
          message: failMsg,
          dateTime: _formatAndroidDateTime(DateTime.now()),
          createdBy: loginSAPCode,
         // type: "Online Activity Disposition",
        );
      }
    } catch (e, stackTrace) {
      final activityDesc = await getActivityDesc(activityCode);
      final failMsg =
          "Activity Disposition of Lead number $resolvedLeadID for $activityDesc is failed.";

      await _showAlert("Failed Activity Disposition", failMsg);
      await _insertNotification(
        title: "Failed Activity Disposition",
        message: failMsg,
        dateTime: _formatAndroidDateTime(DateTime.now()),
        createdBy: loginSAPCode,
       // type: "Online Activity Disposition",
      );

      print("Sync error: $e\n$stackTrace");
    }
  }

  //  MAIN METHOD: insertUpdateActivity
  static Future<void> insertUpdateActivity(
    Map<String, dynamic> activityData,
  ) async {
    final mLeadID = activityData["SrvcReqDtlCode"] ?? "";
    final mTempSrvcReqDtlCode = activityData["TempSrvcReqDtlCode"] ?? "";
    final mSelectedActivityCode = activityData["ActivityCode"] ?? "";
    final mSubActivityCode = activityData["SubActivityCode"] ?? "";
    final loginSAPCode = activityData["CreateBy"] ?? "";
    final cltCode = activityData["CltCode"] ?? "";

    final mExistingActivityCode = activityData["ExistingActivityCode"];
    final isParkedLead = activityData["isParkedLead"] == true;
    final edtExpectedClosureDate = activityData["ExpectedClosureDate"];

    final mInstrumentType = activityData["InstType"];
    final issuedPolicyNo = activityData["IssuedPolicyNo"];
    final chequeNo = activityData["ChequeNo"];
    final premiumCollected = activityData["PremiumCollected"];
    final policyAlreadyRenewedReason =
        activityData["PolicyAlreadyRenewedReason"];
    final appointmentDate = activityData["AppointmentDate"];
    final callBackDate = activityData["CallBackDate"];
    final parkedLeadDateTime = activityData["ParkedLeadDateTime"];
    final followupDt = activityData["FollowupDt"];
    final lostCompDueTo = activityData["LstComDueTo"];
    final cmpNameCompetition = activityData["ComptitorID"];
    final newPolEndDate = activityData["NewPolEndDate"];
    final remark = activityData["Remark"] ?? "";
    final mBizType = activityData["BizType"];
    final mActivityCode = activityData["ActivityCode"];
    final mSubActivityCodeForUpdates = activityData["SubActivityCode"];

    final db = await DatabaseHelper.instance.database;

    try {
      String formattedNow = _formatAndroidDateTime(DateTime.now());

      final cv = <String, dynamic>{};

      cv["ActivityCode"] = _enc(mSelectedActivityCode);
      cv["SubActivityCode"] = _enc(mSubActivityCode);
      cv["SrvcReqDtlCode"] = _enc(mLeadID);
      cv["CreateBy"] = _enc(loginSAPCode);
      cv["CreateDTim"] = _enc(formattedNow);

      if (_eq(mSelectedActivityCode, "35")) {
        cv["IssuedPolicyNo"] = _enc(issuedPolicyNo ?? "");
      } else if (_eq(mSelectedActivityCode, "36")) {
        cv["IssuedPolicyNo"] = _enc(issuedPolicyNo ?? "");
        cv["InstType"] = _enc(mInstrumentType ?? "");
        cv["ChequeNo"] = _enc(chequeNo ?? "");
        cv["PremiumCollected"] = _enc(premiumCollected ?? "");
      } else if (_eq(mSelectedActivityCode, "37")) {
        cv["CallBackDate"] = _enc(callBackDate ?? "");
        cv["AppointmentDate"] = _enc(appointmentDate ?? "");
        cv["ParkedLeadDateTime"] = _enc(parkedLeadDateTime ?? "");
      } else if (_eq(mSelectedActivityCode, "38")) {
        cv["LstComDueTo"] = _enc(lostCompDueTo ?? "");
        cv["ComptitorID"] = _enc(cmpNameCompetition ?? "");
        cv["NewPolEndDate"] = _enc(newPolEndDate ?? "");
      }

      cv["Remark"] = _enc((remark ?? "").trim());
      cv["SyncStatus"] = _enc("Pending");
      cv["TempSrvcReqDtlCode"] = _enc(mTempSrvcReqDtlCode);
      if (followupDt != null && followupDt.isNotEmpty) {
        cv["FollowupDt"] = _enc(followupDt);
      }

      String resolvedLeadID = mLeadID;

      if (mLeadID.startsWith("T")) {
        final cursorLeadCreate = await db.query(
          "LeadDetails",
          where: "SrvcReqDtlCode = ?",
          whereArgs: [_enc(mLeadID)],
          limit: 1,
        );

        if (cursorLeadCreate.isEmpty) {
          final mCursor = await db.query(
            "LeadDetails",
            where: "TempSrvcReqDtlCode = ?",
            whereArgs: [_enc(mTempSrvcReqDtlCode)],
          );

          if (mCursor.isNotEmpty) {
            // ✅ Android: loops ALL rows, last value wins
            for (var row in mCursor) {
              resolvedLeadID = _dec(row["SrvcReqDtlCode"]) ?? mLeadID;
              cv["SrvcReqDtlCode"] = _enc(resolvedLeadID);
            }
          }
        }
      }

      await db.transaction((txn) async {
        await txn.delete(
          "LMSLeadActivityTracker",
          where: "SrvcReqDtlCode = ? AND ActivityCode = ?",
          whereArgs: [_enc(resolvedLeadID), _enc(mSelectedActivityCode)],
        );

        await txn.insert("LMSLeadActivityTracker", cv);

        final cursorUpdate = await txn.query(
          "LeadDetails",
          columns: ["SrvcReqDtlCode"],
          where: "SrvcReqDtlCode = ?",
          whereArgs: [_enc(resolvedLeadID)],
          limit: 1,
        );

        if (cursorUpdate.isNotEmpty) {
          await txn.update(
            "LeadDetails",
            {
              "ActivityStatus": _enc(mSelectedActivityCode),
              "SrvcReqDtlCode": _enc(resolvedLeadID),
              "UpdatedBy": _enc(loginSAPCode),
              "UpdateDTim": _enc(formattedNow),
            },
            where: "SrvcReqDtlCode = ?",
            whereArgs: [_enc(resolvedLeadID)],
          );
        }
      });

      if (mBizType != null && mBizType.isNotEmpty) {
        final leadLostCodes = [
          "24",
          "5",
          "05",
          "18",
          "29",
          "3",
          "03",
          "31",
          "38",
        ];
        if (leadLostCodes.contains(mSelectedActivityCode)) {
          await updateLeadLostToCalendarTbl(
            resolvedLeadID,
            "Lead Lost",
            resolvedLeadID,
            loginSAPCode,
          );
          await updateLeadLostToDashboardTbl(
            resolvedLeadID,
            "Lead Lost",
            resolvedLeadID,
            loginSAPCode,
            mActivityCode ?? "",
            mSubActivityCodeForUpdates ?? "",
          );
        } else if ([
          "04",
          "4",
          "17",
          "30",
          "35",
        ].contains(mSelectedActivityCode)) {
          await updateLeadLostToCalendarTbl(
            resolvedLeadID,
            "Lead Converted",
            resolvedLeadID,
            loginSAPCode,
          );
          await updateLeadLostToDashboardTbl(
            resolvedLeadID,
            "Lead Converted",
            resolvedLeadID,
            loginSAPCode,
            mActivityCode ?? "",
            mSubActivityCodeForUpdates ?? "",
          );
        } else if (_eq(mSelectedActivityCode, "36")) {
          await updateLeadDateToCalendarTbl(
            resolvedLeadID,
            loginSAPCode,
            mSelectedActivityCode,
          );
          await updateSalesCloseDashboardTbl(
            resolvedLeadID,
            mActivityCode ?? "",
            mSubActivityCodeForUpdates ?? "",
            loginSAPCode,
            resolvedLeadID,
            isParkedLead,
            mSelectedActivityCode,
            mSubActivityCode,
          );
        } else if ([
          "01",
          "1",
          "02",
          "2",
          "19",
          "20",
          "21",
          "27",
          "28",
          "32",
          "37",
        ].contains(mSelectedActivityCode)) {
          await updateLeadDateToCalendarTbl(
            resolvedLeadID,
            loginSAPCode,
            mSelectedActivityCode,
          );
          await updateLeadDateToDashboardTbl(
            resolvedLeadID,
            mSelectedActivityCode,
            resolvedLeadID,
            loginSAPCode,
            isParkedLead: isParkedLead,
            edtExpectedClosureDate: edtExpectedClosureDate,
            mExistingActivityCode: mExistingActivityCode,
          );
        }
      }

      bool isConnected = await _isConnected();

      if (isConnected && !resolvedLeadID.startsWith("T")) {
        await _performOnlineSync(
          resolvedLeadID: resolvedLeadID,
          activityCode: mSelectedActivityCode,
          loginSAPCode: loginSAPCode,
        );
      } else {
        final activityDesc = await getActivityDesc(mSelectedActivityCode);
        final offlineMsg =
            "Activity Disposition saved in database and it will be auto sync to server when mobile connect to internet.";
        await _showAlert("Offline Activity Disposition", offlineMsg);
        await _insertNotification(
          title: "Offline Activity Disposition",
          message:
              "Activity Disposition of Lead number $resolvedLeadID for $activityDesc is saved offline.",
          dateTime: _formatAndroidDateTime(DateTime.now()),
          createdBy: loginSAPCode,
          // type: "Offline Activity Disposition",
        );
      }
    } catch (e, stackTrace) {
      print("❌ ERROR in insertUpdateActivity: $e\n$stackTrace");
    }
  }

  // updateLeadLostToCalendarTbl
  static Future<void> updateLeadLostToCalendarTbl(
    String referenceNo,
    String mLeadStatus,
    String mLeadID,
    String loginSAPCode,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      String calDate = "";
      String? reqChannelId, lobCode, prodCode, businessType, leadType;

      // ✅ FIX #4: Loop ALL rows (Android cursor loop parity)
      final leadRows = await db.query(
        "LeadDetails",
        where: "SrvcReqDtlCode = ?",
        whereArgs: [_enc(mLeadID)],
      );

      for (var row in leadRows) {
        reqChannelId = _dec(row["ReqChannelId"]);
        lobCode = _dec(row["LOBCode"]);
        prodCode = _dec(row["ProdCode"]);
        businessType = _dec(row["BusinessType"]);

        if (reqChannelId != null &&
            businessType != null &&
            _eq(reqChannelId, "RQ17") &&
            _eq(businessType, "3")) {
          calDate = convertFormatDate(_dec(row["PolicyEndDate"]));
          leadType = "R";
        } else {
          calDate = convertFormatDate(_dec(row["CreateDTim"]));
          leadType = "N";
        }
      }

      // ✅ FIX #1 & #5: Build dynamic WHERE - NO null in whereArgs
      final whereParts = <String>[];
      final whereArgsList = <dynamic>[];

      whereParts.add("UserId = ?");
      whereArgsList.add(_enc(loginSAPCode));

      if (calDate.isNotEmpty) {
        whereParts.add("date = ?");
        whereArgsList.add(_enc(calDate)); // ✅ FIX #5: Direct add, no ternary
      }
      if (lobCode != null && lobCode.isNotEmpty) {
        whereParts.add("LOBCode = ?");
        whereArgsList.add(_enc(lobCode)); // ✅ FIX #1 & #5: Direct add
      }
      if (prodCode != null && prodCode.isNotEmpty) {
        whereParts.add("ProdCode = ?");
        whereArgsList.add(_enc(prodCode)); // ✅ FIX #1 & #5: Direct add
      }
      if (leadType != null && leadType.isNotEmpty) {
        whereParts.add("BizType = ?");
        whereArgsList.add(_enc(leadType)); // ✅ FIX #1 & #5: Direct add
      }
      whereParts.add("WIPLeads != 0");

      final calRows = await db.query(
        "CalendarData_Mob",
        where: whereParts.join(" AND "),
        whereArgs: whereArgsList,
        limit: 1,
      );

      int totalLeads = 0, wipLeads = 0, leadConverted = 0, leadLost = 0;
      String recId = "";

      if (calRows.isNotEmpty) {
        final row = calRows.first;
        recId = row["RecId"].toString();
        totalLeads = _parseIntSafe(_dec(row["TotalLeads"]));
        wipLeads = _parseIntSafe(_dec(row["WIPLeads"]));
        leadConverted = _parseIntSafe(_dec(row["LeadConverted"]));
        leadLost = _parseIntSafe(_dec(row["LeadLost"]));
      }

      if (wipLeads > 1)
        wipLeads--;
      else
        wipLeads = 0;

      if (_eq(mLeadStatus, "Lead Lost")) {
        leadLost = leadLost > 1 ? leadLost + 1 : 1;
      } else if (_eq(mLeadStatus, "Lead Converted")) {
        leadConverted = leadConverted > 1 ? leadConverted + 1 : 1;
      }

      await db.update(
        "CalendarData_Mob",
        {
          "TotalLeads": _enc(totalLeads.toString()),
          "WIPLeads": _enc(wipLeads.toString()),
          "LeadConverted": _enc(leadConverted.toString()),
          "LeadLost": _enc(leadLost.toString()),
          "CreatedBy": _enc(loginSAPCode),
          "ReferenceNo": _enc(referenceNo),
          "SyncStatus": _enc("Pending"),
        },
        where: "RecId = ?",
        whereArgs: [recId],
      );

      await db.update(
        "LeadDetails",
        {"UserId": _enc("")},
        where: "SrvcReqDtlCode = ?",
        whereArgs: [_enc(mLeadID)],
      );
    } catch (e) {
      print("updateLeadLostToCalendarTbl ERROR: $e");
    }
  }

  // updateLeadLostToDashboardTbl
  static Future<void> updateLeadLostToDashboardTbl(
    String referenceNo,
    String mLeadStatus,
    String mLeadID,
    String loginSAPCode,
    String iActivityCode,
    String iSubActivityCode,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      String calDate = "";
      String? reqChannelId, lobCode, prodCode, businessType, leadType;

      //  Loop ALL rows
      final leadRows = await db.query(
        "LeadDetails",
        where: "SrvcReqDtlCode = ?",
        whereArgs: [_enc(mLeadID)],
      );

      for (var row in leadRows) {
        reqChannelId = _dec(row["ReqChannelId"]);
        lobCode = _dec(row["LOBCode"]);
        prodCode = _dec(row["ProdCode"]);
        businessType = _dec(row["BusinessType"]);

        if (reqChannelId != null &&
            businessType != null &&
            _eq(reqChannelId, "RQ17") &&
            _eq(businessType, "3")) {
          calDate = convertFormatDate(_dec(row["PolicyEndDate"]));
          leadType = "R";
        } else {
          calDate = convertFormatDate(_dec(row["CreateDTim"]));
          leadType = "N";
        }
      }

      //  Dynamic WHERE - NO null in whereArgs
      final whereParts = <String>[];
      final whereArgsList = <dynamic>[];

      whereParts.add("UserId = ?");
      whereArgsList.add(_enc(loginSAPCode));

      if (calDate.isNotEmpty) {
        whereParts.add("date = ?");
        whereArgsList.add(_enc(calDate));
      }
      if (lobCode != null && lobCode.isNotEmpty) {
        whereParts.add("LOBCode = ?");
        whereArgsList.add(_enc(lobCode));
      }
      if (prodCode != null && prodCode.isNotEmpty) {
        whereParts.add("ProdCode = ?");
        whereArgsList.add(_enc(prodCode));
      }
      if (leadType != null && leadType.isNotEmpty) {
        whereParts.add("BizType = ?");
        whereArgsList.add(_enc(leadType));
      }
      whereParts.add("WIPLeads != 0");

      final dashRows = await db.query(
        "DashboardData_Mob",
        where: whereParts.join(" AND "),
        whereArgs: whereArgsList,
        limit: 1,
      );

      int totalLeads = 0, wipLeads = 0, leadConverted = 0, leadLost = 0;
      String recId = "";
      String? bActivity, bSubActivity;
      int iOpenParkCount = 0, iTotalCallBack = 0, iTotalAppointment = 0;
      int iLeadLostNCCount = 0, iLeadLostNICount = 0, iLeadLostNRCount = 0;
      double iAmount = 0.0;

      if (dashRows.isNotEmpty) {
        final row = dashRows.first;
        recId = row["RecId"].toString();
        totalLeads = _parseIntSafe(_dec(row["TotalLeads"]));
        wipLeads = _parseIntSafe(_dec(row["WIPLeads"]));
        leadConverted = _parseIntSafe(_dec(row["LeadConverted"]));
        leadLost = _parseIntSafe(_dec(row["LeadLost"]));

        bActivity = _dec(row["Activity"]);
        bSubActivity = _dec(row["SubActivity"]);

        if (_eq(bActivity, "37")) {
          iAmount = _parseDoubleSafe(_dec(row["Amount"]));
          if (_eq(bSubActivity, "6")) {
            iOpenParkCount = _parseIntSafe(_dec(row["Non_Contactable"]));
          } else if (_eq(bSubActivity, "4")) {
            iTotalCallBack = _parseIntSafe(_dec(row["Call_Back"]));
          } else if (_eq(bSubActivity, "5")) {
            iTotalAppointment = _parseIntSafe(_dec(row["Appointment_Fixed"]));
          }
        } else if (_eq(bActivity, "38")) {
          iAmount = _parseDoubleSafe(_dec(row["Amount"]));
          if (_eq(bSubActivity, "7")) {
            iLeadLostNCCount = _parseIntSafe(_dec(row["Lost_To_Competition"]));
          } else if (_eq(bSubActivity, "8")) {
            iLeadLostNICount = _parseIntSafe(
              _dec(row["Customer_Not_Interested"]),
            );
          } else if (_eq(bSubActivity, "9")) {
            iLeadLostNRCount = _parseIntSafe(
              _dec(row["Customer_Not_Responding"]),
            );
          }
        }
      }

      if (_eq(bActivity, "37")) {
        if (_eq(bSubActivity, "4")) {
          if (iAmount > 0 && iTotalCallBack > 0) {
            iAmount -= (iAmount / iTotalCallBack);
          } else if (iAmount <= 0)
            iAmount = 0;
          iTotalCallBack = iTotalCallBack > 1 ? iTotalCallBack - 1 : 0;
        } else if (_eq(bSubActivity, "5")) {
          if (iAmount > 0 && iTotalAppointment > 0) {
            iAmount -= (iAmount / iTotalAppointment);
          } else if (iAmount <= 0)
            iAmount = 0;
          iTotalAppointment = iTotalAppointment > 1 ? iTotalAppointment - 1 : 0;
        } else if (_eq(bSubActivity, "6")) {
          if (iAmount > 0 && iOpenParkCount > 0) {
            iAmount -= (iAmount / iOpenParkCount);
          } else if (iAmount <= 0)
            iAmount = 0;
          iOpenParkCount = iOpenParkCount > 1 ? iOpenParkCount - 1 : 0;
        }
      } else if (_eq(bActivity, "38")) {
        if (_eq(bSubActivity, "7")) {
          if (iAmount > 0 && iLeadLostNCCount > 0) {
            iAmount -= (iAmount / iLeadLostNCCount);
          } else if (iAmount <= 0)
            iAmount = 0;
          iLeadLostNCCount = iLeadLostNCCount > 1 ? iLeadLostNCCount - 1 : 0;
        } else if (_eq(bSubActivity, "8")) {
          if (iAmount > 0 && iLeadLostNICount > 0) {
            iAmount -= (iAmount / iLeadLostNICount);
          } else if (iAmount <= 0)
            iAmount = 0;
          iLeadLostNICount = iLeadLostNICount > 1 ? iLeadLostNICount - 1 : 0;
        } else if (_eq(bSubActivity, "9")) {
          if (iAmount > 0 && iLeadLostNRCount > 0) {
            iAmount -= (iAmount / iLeadLostNRCount);
          } else if (iAmount <= 0)
            iAmount = 0;
          iLeadLostNRCount = iLeadLostNRCount > 1 ? iLeadLostNRCount - 1 : 0;
        }
      }

      if (wipLeads > 1)
        wipLeads--;
      else
        wipLeads = 0;

      if (_eq(iActivityCode, "38")) {
        if (_eq(iSubActivityCode, "7")) {
          iLeadLostNCCount++;
        } else if (_eq(iSubActivityCode, "8")) {
          iLeadLostNICount++;
        } else if (_eq(iSubActivityCode, "9")) {
          iLeadLostNRCount++;
        }
      }
      if (_eq(iActivityCode, "35") && _eq(iSubActivityCode, "1")) {
        leadConverted++;
      }
      if (_eq(mLeadStatus, "Lead Lost")) {
        leadLost = leadLost > 1 ? leadLost + 1 : 1;
      } else if (_eq(mLeadStatus, "Lead Converted")) {
        leadConverted = leadConverted > 1 ? leadConverted + 1 : 1;
      }

      final updateData = <String, dynamic>{
        "Activity": _enc(iActivityCode),
        "SubActivity": _enc(iSubActivityCode),
        "TotalLeads": _enc(totalLeads.toString()),
        "WIPLeads": _enc(wipLeads.toString()),
        "LeadConverted": _enc(leadConverted.toString()),
        "LeadLost": _enc(leadLost.toString()),
        "Lead_Converted": _enc("0"),
      };

      if (_eq(iActivityCode, "37")) {
        updateData["Amount"] = _enc(iAmount.toString());
        if (_eq(iSubActivityCode, "6")) {
          updateData["Non_Contactable"] = _enc(iOpenParkCount.toString());
        } else if (_eq(iSubActivityCode, "4")) {
          updateData["Call_Back"] = _enc(iTotalCallBack.toString());
        } else if (_eq(iSubActivityCode, "5")) {
          updateData["Appointment_Fixed"] = _enc(iTotalAppointment.toString());
        }
      } else if (_eq(iActivityCode, "38")) {
        updateData["Amount"] = _enc(iAmount.toString());
        if (_eq(iSubActivityCode, "7")) {
          updateData["Lost_To_Competition"] = _enc(iLeadLostNCCount.toString());
        } else if (_eq(iSubActivityCode, "8")) {
          updateData["Customer_Not_Interested"] = _enc(
            iLeadLostNICount.toString(),
          );
        } else if (_eq(iSubActivityCode, "9")) {
          updateData["Customer_Not_Responding"] = _enc(
            iLeadLostNRCount.toString(),
          );
        }
      }

      updateData["CreatedBy"] = _enc(loginSAPCode);
      updateData["ReferenceNo"] = _enc(referenceNo);
      updateData["SyncStatus"] = _enc("Pending");

      await db.update(
        "DashboardData_Mob",
        updateData,
        where: "RecId = ?",
        whereArgs: [recId],
      );
    } catch (e) {
      print("updateLeadLostToDashboardTbl ERROR: $e");
    }
  }

  //  updateLeadDateToCalendarTbl
  static Future<void> updateLeadDateToCalendarTbl(
    String referenceNo,
    String loginSAPCode,
    String selectedActivityCode,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      String calDate = "";
      String? reqChannelId, lobCode, prodCode, businessType, leadType;

      //  Loop ALL rows
      final leadRows = await db.query(
        "LeadDetails",
        where: "SrvcReqDtlCode=?",
        whereArgs: [_enc(referenceNo)],
      );

      for (var row in leadRows) {
        reqChannelId = _dec(row["ReqChannelId"]);
        lobCode = _dec(row["LOBCode"]);
        prodCode = _dec(row["ProdCode"]);
        businessType = _dec(row["BusinessType"]);

        if (reqChannelId != null &&
            businessType != null &&
            _eq(reqChannelId, "RQ17") &&
            _eq(businessType, "3")) {
          calDate = convertFormatDate(_dec(row["PolicyEndDate"]));
          leadType = "R";
        } else {
          calDate = convertFormatDate(_dec(row["CreateDTim"]));
          leadType = "N";
        }
      }

      if (!_eq(leadType, "N")) return;

      // ✅ FIX #1 & #5: Dynamic WHERE - NO null in whereArgs
      final whereParts = <String>[];
      final whereArgsList = <dynamic>[];

      whereParts.add("UserId = ?");
      whereArgsList.add(_enc(loginSAPCode));

      if (calDate.isNotEmpty) {
        whereParts.add("date = ?");
        whereArgsList.add(_enc(calDate));
      }
      if (lobCode != null && lobCode.isNotEmpty) {
        whereParts.add("LOBCode = ?");
        whereArgsList.add(_enc(lobCode)); // ✅ FIX #1 & #5
      }
      if (prodCode != null && prodCode.isNotEmpty) {
        whereParts.add("ProdCode = ?");
        whereArgsList.add(_enc(prodCode)); // ✅ FIX #1 & #5
      }
      if (leadType != null && leadType.isNotEmpty) {
        whereParts.add("BizType = ?");
        whereArgsList.add(_enc(leadType)); // ✅ FIX #1 & #5
      }

      final calRows = await db.query(
        "CalendarData_Mob",
        where: whereParts.join(" AND "),
        whereArgs: whereArgsList,
        limit: 1,
      );

      if (calRows.isEmpty) return;

      final oldRow = calRows.first;
      String recId = oldRow["RecId"].toString();
      int wipLeads = _parseIntSafe(_dec(oldRow["WIPLeads"]));
      String agentCode = _dec(oldRow["AgentCode"]) ?? "";
      String agentName = _dec(oldRow["AgentName"]) ?? "";
      String hninCode = _dec(oldRow["HNINCode"]) ?? "";
      String hninName = _dec(oldRow["HNINName"]) ?? "";
      String ncbFlag = _dec(oldRow["NCBFlag"]) ?? "";

      final trackerRows = await db.query(
        "LMSLeadActivityTracker",
        where: "SrvcReqDtlCode=?",
        whereArgs: [_enc(referenceNo)],
        orderBy: "RecId DESC",
        limit: 1,
      );

      if (trackerRows.isEmpty) return;
      final tracker = trackerRows.first;

      // ✅ Use passed selectedActivityCode
      String activityDate = "";
      switch (selectedActivityCode) {
        case "1":
        case "20":
        case "27":
          activityDate = _dec(tracker["AppointmentDate"]) ?? "";
          break;
        case "2":
        case "28":
          activityDate = _dec(tracker["RescheduleDate"]) ?? "";
          break;
        case "19":
        case "21":
          activityDate = _dec(tracker["CallBackDate"]) ?? "";
          break;
        case "32":
          activityDate = _dec(tracker["FollowupDt"]) ?? "";
          break;
        default:
          activityDate = "";
      }

      if (activityDate.isEmpty) return;

      String formattedDate = convertFormatDate(activityDate);

      if (wipLeads > 0) {
        if (wipLeads > 1)
          wipLeads--;
        else
          wipLeads = 0;

        await db.update(
          "CalendarData_Mob",
          {
            "WIPLeads": _enc(wipLeads.toString()),
            "CreatedBy": _enc(loginSAPCode),
            "SyncStatus": _enc("Completed"),
          },
          where: "RecId=?",
          whereArgs: [recId],
        );

        await db.delete(
          "CalendarData_Mob",
          where: "ReferenceNo=?",
          whereArgs: [_enc(referenceNo)],
        );

        final parsed = _parseAndroidDate(activityDate);
        final createDTime = _formatAndroidDateTime(parsed);
        final monthYear = "${parsed.month}-${parsed.year}";

        await db.insert("CalendarData_Mob", {
          "UserId": _enc(loginSAPCode),
          "date": _enc(formattedDate),
          "AgentCode": _enc(agentCode),
          "AgentName": _enc(agentName),
          "HNINCode": _enc(hninCode),
          "HNINName": _enc(hninName),
          "LOBCode": _enc(lobCode ?? ""),
          "ProdCode": _enc(prodCode ?? ""),
          "NCBFlag": _enc(ncbFlag),
          "TotalLeads": _enc("1"),
          "WIPLeads": _enc("1"),
          "LeadConverted": _enc("0"),
          "LeadLost": _enc("0"),
          "LeadType": _enc("L"),
          "BizType": _enc("N"),
          "CreatedBy": _enc(loginSAPCode),
          "CreateDTime": _enc(createDTime),
          "mdate": _enc(monthYear),
          "ReferenceNo": _enc(referenceNo),
          "SyncStatus": _enc("Pending"),
        });
      } else {
        await db.update(
          "CalendarData_Mob",
          {
            "date": _enc(formattedDate),
            "CreatedBy": _enc(loginSAPCode),
            "ReferenceNo": _enc(referenceNo),
            "SyncStatus": _enc("Pending"),
          },
          where: "RecId=?",
          whereArgs: [recId],
        );
      }

      final parsed = _parseAndroidDate(activityDate);
      final createDTime = _formatAndroidDateTime(parsed);

      await db.update(
        "LeadDetails",
        {"CreateDTim": _enc(createDTime)},
        where: "SrvcReqDtlCode=?",
        whereArgs: [_enc(referenceNo)],
      );
    } catch (e) {
      print("updateLeadDateToCalendarTbl ERROR: $e");
    }
  }

  // ================= 🔹 updateLeadDateToDashboardTbl =================
  static Future<void> updateLeadDateToDashboardTbl(
    String referenceNo,
    String selectedActivityCode,
    String leadId,
    String sapCode, {
    bool isParkedLead = false,
    String? edtExpectedClosureDate,
    String? mExistingActivityCode,
  }) async {
    final db = await DatabaseHelper.instance.database;

    try {
      final lead = await db.query(
        "LeadDetails",
        where: "SrvcReqDtlCode=?",
        whereArgs: [_enc(leadId)],
        limit: 1,
      );
      if (lead.isEmpty) return;

      String? reqChannelId, lobCode, prodCode, businessType;
      String calDate = "";
      String leadType = "";

      for (var row in lead) {
        reqChannelId = _dec(row["ReqChannelId"]);
        lobCode = _dec(row["LOBCode"]);
        prodCode = _dec(row["ProdCode"]);
        businessType = _dec(row["BusinessType"]);

        if (reqChannelId != null &&
            businessType != null &&
            _eq(reqChannelId, "RQ17") &&
            _eq(businessType, "3")) {
          calDate = convertFormatDate(_dec(row["PolicyEndDate"]));
          leadType = "R";
        } else {
          calDate = convertFormatDate(_dec(row["CreateDTim"]));
          leadType = "N";
        }
      }

      if (_eq(leadType, "N")) {
        // ✅ FIX #1 & #5: Dynamic WHERE - NO null in whereArgs
        final whereParts = <String>[];
        final whereArgsList = <dynamic>[];

        whereParts.add("UserId = ?");
        whereArgsList.add(_enc(sapCode));

        if (calDate.isNotEmpty) {
          whereParts.add("date = ?");
          whereArgsList.add(_enc(calDate));
        }
        if (lobCode != null && lobCode.isNotEmpty) {
          whereParts.add("LOBCode = ?");
          whereArgsList.add(_enc(lobCode)); // ✅ FIX #1 & #5
        }
        if (prodCode != null && prodCode.isNotEmpty) {
          whereParts.add("ProdCode = ?");
          whereArgsList.add(_enc(prodCode)); // ✅ FIX #1 & #5
        }
        if (leadType != null && leadType.isNotEmpty) {
          whereParts.add("BizType = ?");
          whereArgsList.add(_enc(leadType)); // ✅ FIX #1 & #5
        }

        // ✅ FIX #4: Android loops → remove limit:1, iterate for last
        final dashboardRows = await db.query(
          "DashboardData_Mob",
          where: whereParts.join(" AND "),
          whereArgs: whereArgsList,
        );

        Map<String, dynamic>? dashboard;
        for (var row in dashboardRows) {
          dashboard = row; // last row wins
        }
        if (dashboard == null) return;

        String recId = dashboard["RecId"].toString();
        int wipLeads = _parseIntSafe(_dec(dashboard["WIPLeads"]));

        final tracker = await db.query(
          "LMSLeadActivityTracker",
          where: "SrvcReqDtlCode=?",
          whereArgs: [_enc(leadId)],
          orderBy: "RecId DESC",
          limit: 1,
        );
        if (tracker.isEmpty) return;

        String activityDate = "";
        switch (selectedActivityCode) {
          case "1":
          case "20":
          case "27":
            activityDate = _dec(tracker.first["AppointmentDate"]) ?? "";
            break;
          case "2":
          case "28":
            activityDate = _dec(tracker.first["RescheduleDate"]) ?? "";
            break;
          case "19":
          case "21":
            activityDate = _dec(tracker.first["CallBackDate"]) ?? "";
            break;
          case "32":
            activityDate = _dec(tracker.first["FollowupDt"]) ?? "";
            break;
          default:
            activityDate = "";
        }
        if (activityDate.isEmpty) return;

        String newDate = convertFormatDate(activityDate);
        wipLeads = wipLeads > 0 ? wipLeads - 1 : 0;

        await db.update(
          "DashboardData_Mob",
          {
            "WIPLeads": _enc(wipLeads.toString()),
            "SyncStatus": _enc("Completed"),
            "UpdatedBy": _enc(sapCode),
          },
          where: "RecId=?",
          whereArgs: [recId],
        );

        final parsed = _parseAndroidDate(activityDate);
        final createDTime = _formatAndroidDateTime(parsed);
        final monthYear = "${parsed.month}-${parsed.year}";

        await db.insert("DashboardData_Mob", {
          "UserId": _enc(sapCode),
          "date": _enc(newDate),
          "TotalLeads": _enc("1"),
          "WIPLeads": _enc("1"),
          "LeadConverted": _enc("0"),
          "LeadLost": _enc("0"),
          "LeadType": _enc("L"),
          "BizType": _enc(leadType),
          "CreatedBy": _enc(sapCode),
          "CreateDTime": _enc(createDTime),
          "MothYear": _enc(monthYear),
          "ReferenceNo": _enc(referenceNo),
          "SyncStatus": _enc("Pending"),
        });

        await db.update(
          "LeadDetails",
          {"CreateDTim": _enc(createDTime)},
          where: "SrvcReqDtlCode=?",
          whereArgs: [_enc(leadId)],
        );
      } else if (_eq(selectedActivityCode, "37")) {
        DateTime? dateExpClosureDt;
        if (edtExpectedClosureDate != null &&
            edtExpectedClosureDate.isNotEmpty) {
          try {
            final parts = edtExpectedClosureDate.trim().split('-');
            if (parts.length == 3) {
              dateExpClosureDt = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          } catch (_) {}
        }
        final dateCurrentDateTime = DateTime.now();

        int wipLeads = 0, totalLeads = 0;
        int iParkLead = 0, iFollowUp = 0;
        double iAmount = 0.0;
        String recId = "", bActivity = "", bSubActivity = "";

        // ✅ FIX #3 & #5: Activity 37 queries - dynamic WHERE, NO null in whereArgs
        List<Map<String, dynamic>> cursor = [];

        if (mExistingActivityCode != null && _eq(mExistingActivityCode, "36")) {
          final whereParts = <String>[];
          final whereArgsList = <dynamic>[];

          whereParts.add("UserId = ?");
          whereArgsList.add(_enc(sapCode));
          if (calDate.isNotEmpty) {
            whereParts.add("date = ?");
            whereArgsList.add(_enc(calDate));
          }
          if (lobCode != null && lobCode.isNotEmpty) {
            whereParts.add("LOBCode = ?");
            whereArgsList.add(_enc(lobCode));
          } // ✅ FIX #3
          if (prodCode != null && prodCode.isNotEmpty) {
            whereParts.add("ProdCode = ?");
            whereArgsList.add(_enc(prodCode));
          } // ✅ FIX #3
          if (leadType != null && leadType.isNotEmpty) {
            whereParts.add("BizType = ?");
            whereArgsList.add(_enc(leadType));
          } // ✅ FIX #3
          whereParts.add("WIPLeads != 0");
          whereParts.add("Activity = ?");
          whereArgsList.add(_enc("36"));

          // ✅ FIX #4: Android loops → remove limit, iterate for last
          final rows = await db.query(
            "DashboardData_Mob",
            where: whereParts.join(" AND "),
            whereArgs: whereArgsList,
          );
          Map<String, dynamic>? lastRow;
          for (var row in rows) {
            lastRow = row;
          }
          if (lastRow != null) cursor = [lastRow];
        } else {
          if (isParkedLead) {
            final whereParts = <String>[];
            final whereArgsList = <dynamic>[];

            whereParts.add("UserId = ?");
            whereArgsList.add(_enc(sapCode));
            if (calDate.isNotEmpty) {
              whereParts.add("date = ?");
              whereArgsList.add(_enc(calDate));
            }
            if (lobCode != null && lobCode.isNotEmpty) {
              whereParts.add("LOBCode = ?");
              whereArgsList.add(_enc(lobCode));
            } // ✅ FIX #3
            if (prodCode != null && prodCode.isNotEmpty) {
              whereParts.add("ProdCode = ?");
              whereArgsList.add(_enc(prodCode));
            } // ✅ FIX #3
            if (leadType != null && leadType.isNotEmpty) {
              whereParts.add("BizType = ?");
              whereArgsList.add(_enc(leadType));
            } // ✅ FIX #3
            whereParts.add("Activity = ?");
            whereArgsList.add(_enc("37"));
            whereParts.add("WIPLeads != 0");
            whereParts.add("ParkLead != 0");

            cursor = await db.query(
              "DashboardData_Mob",
              where: whereParts.join(" AND "),
              whereArgs: whereArgsList,
              limit: 1,
            );
          } else {
            final whereParts = <String>[];
            final whereArgsList = <dynamic>[];

            whereParts.add("UserId = ?");
            whereArgsList.add(_enc(sapCode));
            if (calDate.isNotEmpty) {
              whereParts.add("date = ?");
              whereArgsList.add(_enc(calDate));
            }
            if (lobCode != null && lobCode.isNotEmpty) {
              whereParts.add("LOBCode = ?");
              whereArgsList.add(_enc(lobCode));
            } // ✅ FIX #3
            if (prodCode != null && prodCode.isNotEmpty) {
              whereParts.add("ProdCode = ?");
              whereArgsList.add(_enc(prodCode));
            } // ✅ FIX #3
            if (leadType != null && leadType.isNotEmpty) {
              whereParts.add("BizType = ?");
              whereArgsList.add(_enc(leadType));
            } // ✅ FIX #3
            whereParts.add("WIPLeads != 0");
            whereParts.add("FollowUp != 0");

            // ✅ FIX #4: Android loops → remove limit, iterate for last
            final rows = await db.query(
              "DashboardData_Mob",
              where: whereParts.join(" AND "),
              whereArgs: whereArgsList,
            );
            Map<String, dynamic>? lastRow;
            for (var row in rows) {
              lastRow = row;
            }
            if (lastRow != null) cursor = [lastRow];
          }
        }

        if (cursor.isNotEmpty) {
          final row = cursor.first;
          recId = row["RecId"]?.toString() ?? "";
          wipLeads = _parseIntSafe(_dec(row["WIPLeads"]));
          totalLeads = _parseIntSafe(_dec(row["TotalLeads"]));
          bActivity = (_dec(row["Activity"]) ?? "").trim().toLowerCase();
          bSubActivity = (_dec(row["SubActivity"]) ?? "").trim().toLowerCase();

          if (_eq(bActivity, "36")) {
            iAmount = _parseDoubleSafe(_dec(row["Amount"]));
          } else if (_eq(bActivity, "37")) {
            iParkLead = _parseIntSafe(_dec(row["ParkLead"]));
            iFollowUp = _parseIntSafe(_dec(row["FollowUp"]));
            iAmount = _parseDoubleSafe(_dec(row["Amount"]));
          }
        }

        if (_eq(bActivity, "37")) {
          int tempParkLead = iParkLead;
          int tempFollowUp = iFollowUp;

          if (dateExpClosureDt != null &&
              dateExpClosureDt.isAfter(dateCurrentDateTime)) {
            if (tempFollowUp > 0) {
              tempParkLead = tempParkLead + 1;
              tempFollowUp = tempFollowUp - 1;
            }
          } else {
            if (tempFollowUp == 0) {
              tempFollowUp = tempFollowUp + 1;
              tempParkLead = tempParkLead - 1;
            }
          }

          if (tempParkLead != iParkLead || tempFollowUp != iFollowUp) {
            iParkLead = tempParkLead;
            iFollowUp = tempFollowUp;

            if (dateExpClosureDt != null &&
                dateExpClosureDt.isAfter(dateCurrentDateTime)) {
              if (!isParkedLead && iFollowUp > 0) {
                if (iAmount > 0 && iFollowUp > 0) {
                  iAmount -= (iAmount / iFollowUp);
                } else if (iAmount <= 0)
                  iAmount = 0;
                iParkLead = iParkLead + 1;
                iFollowUp = iFollowUp - 1;
              }
            } else {
              if (iFollowUp == 0) {
                if (iAmount > 0 && iParkLead > 0) {
                  iAmount -= (iAmount / iParkLead);
                } else if (iAmount <= 0)
                  iAmount = 0;
                iFollowUp = iFollowUp + 1;
                iParkLead = iParkLead - 1;
              }
            }
          }
        }

        if (wipLeads > 1 && cursor.isNotEmpty) {
          for (var row in cursor) {
            final cv = <String, dynamic>{};

            cv["UserId"] = row["UserId"];
            cv["AgentCode"] = row["AgentCode"];
            cv["LOBCode"] = row["LOBCode"];
            cv["ProdCode"] = row["ProdCode"];
            cv["date"] = row["date"];

            final rawTotal = _parseIntSafe(_dec(row["TotalLeads"]));
            final rawWIP = _parseIntSafe(_dec(row["WIPLeads"]));
            cv["TotalLeads"] = (rawTotal > 1)
                ? "1"
                : row["TotalLeads"]?.toString();
            cv["WIPLeads"] = (rawWIP > 1) ? "1" : row["WIPLeads"]?.toString();

            cv["LeadConverted"] = "0";
            cv["LeadLost"] = "0";

            if (dateExpClosureDt != null &&
                dateExpClosureDt.isAfter(dateCurrentDateTime)) {
              cv["ParkLead"] = "1";
              cv["FollowUp"] = "0";
            } else {
              cv["ParkLead"] = "0";
              cv["FollowUp"] = "1";
            }

            final mInitAmount = _parseDoubleSafe(_dec(row["Amount"]));
            if (mInitAmount > 0 && iAmount > 0) {
              cv["Amount"] = _enc((mInitAmount - iAmount).toString());
            } else {
              cv["Amount"] = row["Amount"];
            }

            cv["Activity"] = _enc(selectedActivityCode);
            cv["SubActivity"] = _enc("");
            cv["CreatedBy"] = _enc(sapCode);
            cv["ReferenceNo"] = _enc(referenceNo);
            cv["SyncStatus"] = _enc("Pending");

            await db.insert("DashboardData_Mob", cv);
          }

          if (wipLeads > 1) wipLeads--;
          if (totalLeads > 1) totalLeads--;

          final updateData = <String, dynamic>{
            "TotalLeads": _enc(totalLeads.toString()),
            "WIPLeads": _enc(wipLeads.toString()),
          };

          if (dateExpClosureDt != null &&
              dateExpClosureDt.isAfter(dateCurrentDateTime)) {
            updateData["FollowUp"] = _enc(iFollowUp.toString());
          } else {
            updateData["ParkLead"] = _enc(iParkLead.toString());
          }

          await db.update(
            "DashboardData_Mob",
            updateData,
            where: "RecId=?",
            whereArgs: [recId],
          );
        } else {
          final updateData = <String, dynamic>{
            "Activity": _enc(selectedActivityCode),
            "SubActivity": _enc(""),
            "ParkLead": _enc(iParkLead.toString()),
            "FollowUp": _enc(iFollowUp.toString()),
          };

          await db.update(
            "DashboardData_Mob",
            updateData,
            where: "RecId=?",
            whereArgs: [recId],
          );
        }

        final tracker = await db.query(
          "LMSLeadActivityTracker",
          where: "SrvcReqDtlCode=?",
          whereArgs: [_enc(leadId)],
          orderBy: "RecId DESC",
          limit: 1,
        );
        if (tracker.isNotEmpty) {
          String activityDate = "";
          switch (selectedActivityCode) {
            case "1":
            case "20":
            case "27":
              activityDate = _dec(tracker.first["AppointmentDate"]) ?? "";
              break;
            case "2":
            case "28":
              activityDate = _dec(tracker.first["RescheduleDate"]) ?? "";
              break;
            case "19":
            case "21":
              activityDate = _dec(tracker.first["CallBackDate"]) ?? "";
              break;
            case "32":
              activityDate = _dec(tracker.first["FollowupDt"]) ?? "";
              break;
            default:
              activityDate = "";
          }
          if (activityDate.isNotEmpty) {
            final parsed = _parseAndroidDate(activityDate);
            final createDTime = _formatAndroidDateTime(parsed);

            await db.update(
              "LeadDetails",
              {"CreateDTim": _enc(createDTime)},
              where: "SrvcReqDtlCode=?",
              whereArgs: [_enc(leadId)],
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print("updateLeadDateToDashboardTbl ERROR: $e\n$stackTrace");
    }
  }

  // ================= 🔹 updateSalesCloseDashboardTbl =================
  static Future<void> updateSalesCloseDashboardTbl(
    String referenceNo,
    String iActivityCode,
    String iSubActivityCode,
    String loginSAPCode,
    String mLeadID,
    bool isParkedLead,
    String mSelectedActivityCode,
    String mSubActivityCode,
  ) async {
    final db = await DatabaseHelper.instance.database;

    try {
      String calDate = "";
      String? reqChannelId, lobCode, prodCode, businessType, leadType;

      // ✅ FIX #4: Loop ALL rows
      final leadRows = await db.query(
        "LeadDetails",
        where: "SrvcReqDtlCode = ?",
        whereArgs: [_enc(mLeadID)],
      );

      for (var row in leadRows) {
        reqChannelId = _dec(row["ReqChannelId"]);
        lobCode = _dec(row["LOBCode"]);
        prodCode = _dec(row["ProdCode"]);
        businessType = _dec(row["BusinessType"]);

        if (reqChannelId != null &&
            businessType != null &&
            _eq(reqChannelId, "RQ17") &&
            _eq(businessType, "3")) {
          calDate = convertFormatDate(_dec(row["PolicyEndDate"]));
          leadType = "R";
        } else {
          calDate = convertFormatDate(_dec(row["CreateDTim"]));
          leadType = "N";
        }
      }

      List<Map<String, dynamic>> dashboardRows = [];

      // ✅ FIX #1, #3, #5: Dynamic WHERE for Activity 37 queries - NO null in whereArgs
      final encUserId = _enc(loginSAPCode);
      final encCalDate = _enc(calDate);

      if (isParkedLead) {
        final whereParts = <String>[];
        final whereArgsList = <dynamic>[];

        whereParts.add("UserId = ?");
        whereArgsList.add(encUserId);
        if (calDate.isNotEmpty) {
          whereParts.add("date = ?");
          whereArgsList.add(encCalDate);
        }
        if (lobCode != null && lobCode.isNotEmpty) {
          whereParts.add("LOBCode = ?");
          whereArgsList.add(_enc(lobCode));
        } // ✅ FIX #1 & #5
        if (prodCode != null && prodCode.isNotEmpty) {
          whereParts.add("ProdCode = ?");
          whereArgsList.add(_enc(prodCode));
        } // ✅ FIX #1 & #5
        if (leadType != null && leadType.isNotEmpty) {
          whereParts.add("BizType = ?");
          whereArgsList.add(_enc(leadType));
        } // ✅ FIX #1 & #5
        whereParts.add("Activity = ?");
        whereArgsList.add(_enc("37"));
        whereParts.add("WIPLeads != 0");
        whereParts.add("ParkLead != 0");

        // ✅ FIX #4: Android loops → remove limit, iterate for last
        final rows = await db.query(
          "DashboardData_Mob",
          where: whereParts.join(" AND "),
          whereArgs: whereArgsList,
        );
        Map<String, dynamic>? lastRow;
        for (var row in rows) {
          lastRow = row;
        }
        if (lastRow != null) dashboardRows = [lastRow];

        if (dashboardRows.isEmpty) {
          final whereParts2 = <String>[];
          final whereArgsList2 = <dynamic>[];

          whereParts2.add("UserId = ?");
          whereArgsList2.add(encUserId);
          if (calDate.isNotEmpty) {
            whereParts2.add("date = ?");
            whereArgsList2.add(encCalDate);
          }
          if (lobCode != null && lobCode.isNotEmpty) {
            whereParts2.add("LOBCode = ?");
            whereArgsList2.add(_enc(lobCode));
          } // ✅ FIX #1 & #5
          if (prodCode != null && prodCode.isNotEmpty) {
            whereParts2.add("ProdCode = ?");
            whereArgsList2.add(_enc(prodCode));
          } // ✅ FIX #1 & #5
          if (leadType != null && leadType.isNotEmpty) {
            whereParts2.add("BizType = ?");
            whereArgsList2.add(_enc(leadType));
          } // ✅ FIX #1 & #5
          whereParts2.add("WIPLeads != 0");
          whereParts2.add("ParkLead != 0");

          final rows2 = await db.query(
            "DashboardData_Mob",
            where: whereParts2.join(" AND "),
            whereArgs: whereArgsList2,
          );
          Map<String, dynamic>? lastRow2;
          for (var row in rows2) {
            lastRow2 = row;
          }
          if (lastRow2 != null) dashboardRows = [lastRow2];
        }
      } else {
        final whereParts = <String>[];
        final whereArgsList = <dynamic>[];

        whereParts.add("UserId = ?");
        whereArgsList.add(encUserId);
        if (calDate.isNotEmpty) {
          whereParts.add("date = ?");
          whereArgsList.add(encCalDate);
        }
        if (lobCode != null && lobCode.isNotEmpty) {
          whereParts.add("LOBCode = ?");
          whereArgsList.add(_enc(lobCode));
        } // ✅ FIX #1 & #5
        if (prodCode != null && prodCode.isNotEmpty) {
          whereParts.add("ProdCode = ?");
          whereArgsList.add(_enc(prodCode));
        } // ✅ FIX #1 & #5
        if (leadType != null && leadType.isNotEmpty) {
          whereParts.add("BizType = ?");
          whereArgsList.add(_enc(leadType));
        } // ✅ FIX #1 & #5
        whereParts.add("WIPLeads != 0");
        whereParts.add("FollowUp != 0");

        // ✅ FIX #4: Android loops → remove limit, iterate for last
        final rows = await db.query(
          "DashboardData_Mob",
          where: whereParts.join(" AND "),
          whereArgs: whereArgsList,
        );
        Map<String, dynamic>? lastRow;
        for (var row in rows) {
          lastRow = row;
        }
        if (lastRow != null) dashboardRows = [lastRow];

        if (dashboardRows.isEmpty) {
          final whereParts2 = <String>[];
          final whereArgsList2 = <dynamic>[];

          whereParts2.add("UserId = ?");
          whereArgsList2.add(encUserId);
          if (calDate.isNotEmpty) {
            whereParts2.add("date = ?");
            whereArgsList2.add(encCalDate);
          }
          if (lobCode != null && lobCode.isNotEmpty) {
            whereParts2.add("LOBCode = ?");
            whereArgsList2.add(_enc(lobCode));
          } // ✅ FIX #1 & #5
          if (prodCode != null && prodCode.isNotEmpty) {
            whereParts2.add("ProdCode = ?");
            whereArgsList2.add(_enc(prodCode));
          } // ✅ FIX #1 & #5
          if (leadType != null && leadType.isNotEmpty) {
            whereParts2.add("BizType = ?");
            whereArgsList2.add(_enc(leadType));
          } // ✅ FIX #1 & #5
          whereParts2.add("WIPLeads != 0");

          final rows2 = await db.query(
            "DashboardData_Mob",
            where: whereParts2.join(" AND "),
            whereArgs: whereArgsList2,
          );
          Map<String, dynamic>? lastRow2;
          for (var row in rows2) {
            lastRow2 = row;
          }
          if (lastRow2 != null) dashboardRows = [lastRow2];
        }
      }

      if (dashboardRows.isEmpty) return;

      int totalLeads = 0, wipLeads = 0, leadConverted = 0, leadLost = 0;
      int saleClosed = 0;
      String recId = "";
      String? bActivity, bSubActivity;

      int iOpenParkCount = 0, iTotalCallBack = 0, iTotalAppointment = 0;
      int iPremiumCollected = 0, iPolicyIssued = 0;
      double iAmount = 0.0;
      int iParkLead = 0, iFollowUp = 0;

      // ✅ FIX #4: Loop ALL rows (Android cursor loop parity - last row wins)
      for (var row in dashboardRows) {
        recId = row["RecId"].toString();

        totalLeads = _parseIntSafe(_dec(row["TotalLeads"]));
        wipLeads = _parseIntSafe(_dec(row["WIPLeads"]));
        leadConverted = _parseIntSafe(_dec(row["LeadConverted"]));
        leadLost = _parseIntSafe(_dec(row["LeadLost"]));

        bActivity = _dec(row["Activity"]);
        bSubActivity = _dec(row["SubActivity"]);

        if (_eq(bActivity, "37")) {
          iAmount = _parseDoubleSafe(_dec(row["Amount"]));

          final parkVal = _parseIntSafe(_dec(row["ParkLead"]));
          if (parkVal > 0) iParkLead = parkVal;

          final followVal = _parseIntSafe(_dec(row["FollowUp"]));
          if (followVal > 0) iFollowUp = followVal;

          if (_eq(bSubActivity, "6")) {
            iOpenParkCount = _parseIntSafe(_dec(row["Non_Contactable"]));
          } else if (_eq(bSubActivity, "4")) {
            iTotalCallBack = _parseIntSafe(_dec(row["Call_Back"]));
          } else if (_eq(bSubActivity, "5")) {
            iTotalAppointment = _parseIntSafe(_dec(row["Appointment_Fixed"]));
          }
        } else if (_eq(bActivity, "36")) {
          iAmount = _parseDoubleSafe(_dec(row["Amount"]));
          saleClosed = _parseIntSafe(_dec(row["WIPLeads"]));

          if (_eq(bSubActivity, "2")) {
            iPremiumCollected = _parseIntSafe(_dec(row["Premium_Collected"]));
          } else if (_eq(bSubActivity, "3")) {
            iPolicyIssued = _parseIntSafe(_dec(row["Policy_Issued"]));
          }
        }
      }

      if (_eq(bActivity, "37")) {
        if (!isParkedLead && iFollowUp > 0) {
          iFollowUp--;
        } else if (iParkLead > 0) {
          iParkLead--;
        }

        if (_eq(bSubActivity, "4")) {
          if (iAmount > 0 && iTotalCallBack > 0) {
            iAmount -= (iAmount / iTotalCallBack);
          } else if (iAmount <= 0)
            iAmount = 0;
          iTotalCallBack = iTotalCallBack > 1 ? iTotalCallBack - 1 : 0;
        } else if (_eq(bSubActivity, "5")) {
          if (iAmount > 0 && iTotalAppointment > 0) {
            iAmount -= (iAmount / iTotalAppointment);
          } else if (iAmount <= 0)
            iAmount = 0;
          iTotalAppointment = iTotalAppointment > 1 ? iTotalAppointment - 1 : 0;
        } else if (_eq(bSubActivity, "6")) {
          if (iAmount > 0 && iOpenParkCount > 0) {
            iAmount -= (iAmount / iOpenParkCount);
          } else if (iAmount <= 0)
            iAmount = 0;
          iOpenParkCount = iOpenParkCount > 1 ? iOpenParkCount - 1 : 0;
        }
      } else if (_eq(bActivity, "36")) {
        if (_eq(bSubActivity, "2")) {
          if (iAmount > 0 && iPremiumCollected > 0) {
            iAmount -= (iAmount / iPremiumCollected);
          } else if (iAmount <= 0)
            iAmount = 0;
          iPremiumCollected = iPremiumCollected > 1 ? iPremiumCollected - 1 : 0;
        } else if (_eq(bSubActivity, "3")) {
          if (iAmount > 0 && iPolicyIssued > 0) {
            iAmount -= (iAmount / iPolicyIssued);
          } else if (iAmount <= 0)
            iAmount = 0;
          iPolicyIssued = iPolicyIssued > 1 ? iPolicyIssued - 1 : 0;
        }
      }

      if (_eq(iActivityCode, "36")) {
        if (_eq(iSubActivityCode, "2")) {
          iPremiumCollected++;
        } else if (_eq(iSubActivityCode, "3")) {
          iPolicyIssued++;
        }
      }

      if (wipLeads > 1) {
        if (dashboardRows.isNotEmpty) {
          for (var row in dashboardRows) {
            final cv = <String, dynamic>{};

            cv["UserId"] = row["UserId"];
            cv["AgentCode"] = row["AgentCode"];
            cv["AgentName"] = row["AgentName"];
            cv["HNINCode"] = row["HNINCode"];
            cv["HNINName"] = row["HNINName"];
            cv["LOBCode"] = row["LOBCode"];
            cv["ProdCode"] = row["ProdCode"];
            cv["NCBFlag"] = row["NCBFlag"];
            cv["date"] = row["date"];
            cv["DateInLong"] = row["DateInLong"];

            final rawTotalLeads = _parseIntSafe(_dec(row["TotalLeads"]));
            final rawWIPLeads = _parseIntSafe(_dec(row["WIPLeads"]));

            cv["TotalLeads"] = (rawTotalLeads > 1)
                ? "1"
                : row["TotalLeads"]?.toString();
            cv["WIPLeads"] = (rawWIPLeads > 1)
                ? "1"
                : row["WIPLeads"]?.toString();

            cv["LeadConverted"] = "0";
            cv["LeadLost"] = "0";
            cv["Lead_Converted"] = "0";
            cv["Call_Back"] = "0";
            cv["Appointment_Fixed"] = "0";
            cv["Non_Contactable"] = "0";
            cv["Lost_To_Competition"] = "0";
            cv["Customer_Not_Interested"] = "0";
            cv["Customer_Not_Responding"] = "0";
            cv["ParkLead"] = "0";
            cv["FollowUp"] = "0";

            cv["Premium_Collected"] = _enc(iPremiumCollected.toString());
            cv["Policy_Issued"] = _enc(iPolicyIssued.toString());

            cv["Activity"] = _enc(mSelectedActivityCode);
            cv["SubActivity"] = _enc(mSubActivityCode);

            final mInitAmount = _parseDoubleSafe(_dec(row["Amount"]));
            if (mInitAmount > 0 && iAmount > 0) {
              final diff = mInitAmount - iAmount;
              cv["Amount"] = _enc(diff.toString());
            } else {
              cv["Amount"] = row["Amount"];
            }

            cv["LeadType"] = row["LeadType"];
            cv["BizType"] = row["BizType"];
            cv["MarcketType"] = row["MarcketType"];
            cv["PolicyChanel"] = row["PolicyChanel"];
            cv["BMCMCode"] = row["BMCMCode"];
            cv["ircCode"] = row["ircCode"];
            cv["ircname"] = row["ircname"];
            cv["RNType"] = row["RNType"];
            cv["NetODPremium"] = row["NetODPremium"];
            cv["NetTPPremium"] = row["NetTPPremium"];
            cv["RNblockReason"] = row["RNblockReason"];
            cv["ProductGroup"] = row["ProductGroup"];
            cv["ProductSubCategory"] = row["ProductSubCategory"];
            cv["NILDep"] = row["NILDep"];
            cv["Category"] = row["Category"];
            cv["FuelType"] = row["FuelType"];
            cv["VehicleType"] = row["VehicleType"];
            cv["SeatingCapacity"] = row["SeatingCapacity"];
            cv["AgeGroup"] = row["AgeGroup"];
            cv["FamilySize"] = row["FamilySize"];
            cv["SumInsuredBand"] = row["SumInsuredBand"];
            cv["PreExiting"] = row["PreExiting"];
            cv["Occupancy"] = row["Occupancy"];
            cv["SumInsured"] = row["SumInsured"];
            cv["LifeGroup"] = row["LifeGroup"];
            cv["Zone"] = row["Zone"];
            cv["Region"] = row["Region"];
            cv["RenewalYearCount"] = row["RenewalYearCount"];
            cv["Preferred"] = row["Preferred"];
            cv["SMName"] = row["SMName"];
            cv["SMBranch"] = row["SMBranch"];
            cv["SMBranchName"] = row["SMBranchName"];
            cv["CreateDTime"] = row["CreateDTime"];
            cv["UpdatedBy"] = row["UpdatedBy"];
            cv["UpdatedDtime"] = row["UpdatedDtime"];
            cv["MothYear"] = row["MothYear"];

            cv["CreatedBy"] = _enc(loginSAPCode);
            cv["ReferenceNo"] = _enc(referenceNo);
            cv["SyncStatus"] = _enc("Pending");

            await db.insert("DashboardData_Mob", cv);
          }
        }

        if (wipLeads > 1) wipLeads--;
        if (totalLeads > 1) totalLeads--;

        final updateData = <String, dynamic>{};
        updateData["TotalLeads"] = _enc(totalLeads.toString());
        updateData["WIPLeads"] = _enc(wipLeads.toString());
        updateData["LeadConverted"] = _enc(leadConverted.toString());
        updateData["LeadLost"] = _enc(leadLost.toString());

        if (_eq(bActivity, "37")) {
          updateData["Amount"] = _enc(iAmount.toString());
          updateData["ParkLead"] = _enc(iParkLead.toString());
          updateData["FollowUp"] = _enc(iFollowUp.toString());

          if (_eq(bSubActivity, "6")) {
            updateData["Non_Contactable"] = _enc(iOpenParkCount.toString());
          } else if (_eq(bSubActivity, "4")) {
            updateData["Call_Back"] = _enc(iTotalCallBack.toString());
          } else if (_eq(bSubActivity, "5")) {
            updateData["Appointment_Fixed"] = _enc(
              iTotalAppointment.toString(),
            );
          }
        }

        await db.update(
          "DashboardData_Mob",
          updateData,
          where: "RecId = ?",
          whereArgs: [recId],
        );
      } else {
        final updateData = <String, dynamic>{};
        updateData["Activity"] = _enc(mSelectedActivityCode);
        updateData["SubActivity"] = _enc(mSubActivityCode);
        updateData["TotalLeads"] = _enc(totalLeads.toString());
        updateData["WIPLeads"] = _enc(wipLeads.toString());
        updateData["LeadConverted"] = _enc(leadConverted.toString());
        updateData["LeadLost"] = _enc(leadLost.toString());
        updateData["Premium_Collected"] = _enc(iPremiumCollected.toString());
        updateData["Policy_Issued"] = _enc(iPolicyIssued.toString());

        if (_eq(bActivity, "37")) {
          updateData["Amount"] = _enc(iAmount.toString());
          updateData["ParkLead"] = _enc(iParkLead.toString());
          updateData["FollowUp"] = _enc(iFollowUp.toString());

          if (_eq(bSubActivity, "6")) {
            updateData["Non_Contactable"] = _enc(iOpenParkCount.toString());
          } else if (_eq(bSubActivity, "4")) {
            updateData["Call_Back"] = _enc(iTotalCallBack.toString());
          } else if (_eq(bSubActivity, "5")) {
            updateData["Appointment_Fixed"] = _enc(
              iTotalAppointment.toString(),
            );
          }
        }

        updateData["CreatedBy"] = _enc(loginSAPCode);
        updateData["ReferenceNo"] = _enc(referenceNo);
        updateData["SyncStatus"] = _enc("Pending");

        await db.update(
          "DashboardData_Mob",
          updateData,
          where: "RecId = ?",
          whereArgs: [recId],
        );
      }
    } catch (e, stackTrace) {
      print("ERROR in updateSalesCloseDashboardTbl: $e");
      print("Stack: $stackTrace");
      rethrow;
    }
  }

  // ================= HELPERS =================
  static DateTime _parseAndroidDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        final parts = dateStr.trim().split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }
    return DateTime.now();
  }

  //new added method
  // Add this to SaveActivityOfflineRepository class: static Future<void> saveLeadActivityOffline({ required String leadId, required String tempLeadId, required String activityCode, required String subActivityCode, required String loginSAPCode, required String cltCode, required String remark, String? bizType, String? existingActivityCode, bool? isParkedLead, String? expectedClosureDate, String? issuedPolicyNo, String? instType, String? chequeNo, String? premiumCollected, String? policyAlreadyRenewedReason, String? appointmentDate, String? callBackDate, String? parkedLeadDateTime, String? followupDt, String? lostCompDueTo, String? cmpNameCompetition, String? newPolEndDate, }) async { final activityData = <String, dynamic>{ "SrvcReqDtlCode": leadId, "TempSrvcReqDtlCode": tempLeadId, "ActivityCode": activityCode, "SubActivityCode": subActivityCode, "CreateBy": loginSAPCode, "CltCode": cltCode, "Remark": remark, if (bizType != null) "BizType": bizType, if (existingActivityCode != null) "ExistingActivityCode": existingActivityCode, if (isParkedLead != null) "isParkedLead": isParkedLead, if (expectedClosureDate != null) "ExpectedClosureDate": expectedClosureDate, if (issuedPolicyNo != null) "IssuedPolicyNo": issuedPolicyNo, if (instType != null) "InstType": instType, if (chequeNo != null) "ChequeNo": chequeNo, if (premiumCollected != null) "PremiumCollected": premiumCollected, if (policyAlreadyRenewedReason != null) "PolicyAlreadyRenewedReason": policyAlreadyRenewedReason, if (appointmentDate != null) "AppointmentDate": appointmentDate, if (callBackDate != null) "CallBackDate": callBackDate, if (parkedLeadDateTime != null) "ParkedLeadDateTime": parkedLeadDateTime, if (followupDt != null) "FollowupDt": followupDt, if (lostCompDueTo != null) "LstComDueTo": lostCompDueTo, if (cmpNameCompetition != null) "ComptitorID": cmpNameCompetition, if (newPolEndDate != null) "NewPolEndDate": newPolEndDate, }; await insertUpdateActivity(activityData); }
}
