import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/common/common_singltbtn_popup.dart';
import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/common/progress_dialog.dart';
import 'package:flutter_bottom_nav/core/apicall/async_search_customer_contact.dart';
import 'package:flutter_bottom_nav/core/apicall/bridgeapicall.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/contact_Model.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonUtil {
  static void show(BuildContext context, {String message = "Please wait..."}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => ProgressDialogWidget(message: message),
    );
  }

  static Widget loader({String message = "Please wait..."}) {
    return Center(child: ProgressDialogWidget(message: message));
  }

  static void showdashloader(
    BuildContext context, {
    String message = "Please wait...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => ProgressDialogWidget(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static String encryptIfNotEmpty(dynamic value) {
    if (value == null) return "";
    final str = value.toString().trim();
    if (str.isEmpty) return "";
    return EncryptionUtil.encrypt(str);
  }

  static String decryptIfNotEmpty(dynamic value) {
    if (value == null) return "";
    final str = value.toString().trim();
    if (str.isEmpty) return "";
    try {
      return EncryptionUtil.decrypt(str);
    } catch (_) {
      return str;
    }
  }

  static String getValueInLakh(double value) {
    if (value <= 0) return "0.00";

    double amountInLakh = value / 100000;
    return amountInLakh.toStringAsFixed(2);
  }

  static double calculatePercentage(int value, int total) {
    if (total == 0) return 0.0;
    return (value * 100) / total;
  }

  static Future<bool> isPrivacyFlag() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'iUser',
        where: 'UserId = ?',
        whereArgs: [encryptIfNotEmpty(StaticVariables.mSAPCode)],
      );

      if (result.isNotEmpty) {
        String EncryptedPFlag = result.first['Privacy_Flag']?.toString() ?? '';

        String DecryptedPFlag = decryptIfNotEmpty(EncryptedPFlag);

        return DecryptedPFlag.trim().toUpperCase() == 'Y';
      }

      return false;
    } catch (e) {
      print("Error Getting Privacy Flag : $e");
      return false;
    }
  }

  static Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<ContactModel>> getContactFrmCustCnct(
    Database db,
    String customerCode,
    String type,
  ) async {
    try {
      final result = await db.query(
        'CUSTOMER_CONTACT',
        where: 'CustomerCode = ? AND Type = ?',
        whereArgs: [customerCode, type],
      );

      return result.map((row) {
        final encryptedContact = row['Contact'] as String? ?? '';

        return ContactModel(
          custCode: row['CustomerCode'].toString(),
          type: row['Type'].toString(),
          contact: decryptIfNotEmpty(encryptedContact),
        );
      }).toList();
    } catch (e) {
      print("Error fetching contacts: $e");
      return [];
    }
  }

  ////contact
  static String normalizeMobileNumber(String number) {
    if (number.isEmpty) return "";

    String mobile = number.trim();

    if (mobile.length == 10) {
    } else if (mobile.length == 12 && mobile.startsWith("91")) {
      mobile = mobile.substring(2);
    } else if (mobile.length == 13 && mobile.startsWith("+91")) {
      mobile = mobile.substring(3);
    }

    if (mobile.length != 10) {
      print(" Invalid mobile number after normalization: $mobile");
      return "";
    }

    return mobile;
  }

  static Future<void> makeCall(
    String number,
    String leadId,
    String uniqueNo,
    String name,
  ) async {
    final cleanNumber = normalizeMobileNumber(number);

    bool isPrivacy = await CommonUtil.isPrivacyFlag();

    if (cleanNumber.isEmpty) {
      print("Invalid number, cannot make call");
      return;
    }

    if (!isPrivacy) {
      await launchDirectCall(cleanNumber);
    } else {
      await makeBridgeCall(cleanNumber, leadId, uniqueNo, name);
    }
  }

  static Future<void> launchDirectCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);

    bool hasPermission = await requestCallPermission();

    if (!hasPermission) {
      print("permission not granted to make call");
      return;
    }

    bool? res = await FlutterPhoneDirectCaller.callNumber(number);

    if (res == true) {
      print(" Call started");
    } else {
      print(" Call failed");
    }

    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url);
    // } else {
    //   print("Could not launch dialer for $number");
    // }
  }

  //param defined
  static String reqeusting_system_campaign = "Renewal_Conf_call";
  static String system_event = "Renewal Calling";
  static String SystemName = "smarttracker";
  // Robo call

  static Future<void> makeBridgeCall(
    String number,
    String leadId,
    String uniqueno,
    String name,
  ) async {
    try {
      String smMobileNumber = await CommonUtil.getUserMobileNo();

      String msg_to_play =
          StaticVariables.mSAPCode +
          " | " +
          name +
          " | " +
          leadId +
          " | " +
          uniqueno;
      // if (!await isConnected()) {
      //   print("No internet connection for bridge call");
      //   return;
      // }

      print("Making Bridge Call to: $number");

      final response = await Bridgeapicall.call(
        smMobileNo: smMobileNumber,
        custMobileNo: number,
        reqSystemCampaign: reqeusting_system_campaign,
        systemUniqueNo: uniqueno,
        systemEvent: system_event,
        systemName: SystemName,
        msgToPlay: msg_to_play,
        leadNo: leadId,
        sapCode: StaticVariables.mSAPCode,
      );

      //   if (response["errorFlag"] == "success") {
      //     print("Bridge Call Success");
      //   } else {
      //     print("Bridge Call Failed");
      //   }
      // } catch (e) {
      //   print("Bridge Call Error: $e");
      // }

      if (response != null &&
          response["Table"] != null &&
          response["Table"].isNotEmpty) {
        var result = response["Table"][0];

        if (result["ResponseCode"].toString() == "1") {
          print("Bridge Call Success");
        } else {
          print("Bridge Call Failed: ${result["Message"]}");
        }
      } else {
        print("Bridge Call Failed: Invalid response structure");
      }
    } catch (e) {
      print("Bridge Call Error: $e");
    }
  }

  static Future<bool> requestCallPermission() async {
    var status = await Permission.phone.request();

    if (status.isGranted) {
      return true;
    } else {
      print("Call permission denied");
      return false;
    }
  }

  static Future<String> getUserMobileNo() async {
    String mobileNo = "";

    try {
      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'iUser',
        where: 'UserId = ?',
        whereArgs: [CommonUtil.encryptIfNotEmpty(StaticVariables.mSAPCode)],
      );

      if (result.isNotEmpty) {
        String encryptedMobile = result.first['MobileNo']?.toString() ?? "";

        mobileNo = CommonUtil.decryptIfNotEmpty(encryptedMobile);
      } else {
        print("No user found in iUser table");
      }
    } catch (e) {
      print("Error fetching MobileNo: $e");
    }

    return mobileNo;
  }

  static Future<void> sendSms(String number) async {
    final Uri smsUri = Uri(scheme: 'sms', path: number);

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw Exception("Could not open SMS app");
    }
  }

  static Future<void> sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw Exception("Could not open email app");
    }
  }

  static Future<bool> clearAppData() async {
    try {
      final db = await DatabaseHelper.instance.database;

      await db.transaction((txn) async {
        // User data
        await txn.delete('LeadDetails');
        await txn.delete('CalendarData_Mob');
        await txn.delete('DashboardData_Mob');
        await txn.delete('TeamDashboardData_Mob');
        await txn.delete('LMSLeadActivityTracker');
        await txn.delete('NotificationDetails');
        await txn.delete('TBL_CUSTOMER_CNT_DTLS');
        await txn.delete('TBL_AGENT_CNT_DTLS');

        // Master tables
        await txn.delete('CBFrmMSTLOB');
        await txn.delete('CBFrmMSTProduct');
        await txn.delete('Tbl_ZoneRegionBranch');
        await txn.delete('Tbl_SalesManager');
        await txn.delete('Tbl_Agent');
        await txn.delete('Tbl_Reference');
        await txn.delete('LookUpSU');
        await txn.delete('Make_Master');
        await txn.delete('MstReqChannel');

        // Keep iUser if you don't want to delete login details.
        // Otherwise uncomment:
        // await txn.delete('iUser');
      });

      print("App data cleared successfully.");
      return true;
    } catch (e) {
      print("Error clearing app data: $e");
      return false;
    }
  }
}
