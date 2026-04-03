import 'dart:convert';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class CustomerContactRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Parses JSON response and inserts/updates customer contacts in the database
  Future<bool> parseAndStoreCustomerContacts(String response) async {
    try {
      final db = await _dbHelper.database;

      final decoded = jsonDecode(response);
      final List table = decoded["Table"] ?? [];

      if (table.isEmpty) return false;

      final first = table[0];
      if (first is Map &&
          (first["ResponseCode"]?.toString() == "1" ||
           first["ResponseCode"]?.toString() == "2")) {
        return false;
      }

      // Start a batch for efficient insertion/upsert
      final batch = db.batch();

      for (var json in table) {
        final leadNo = CommonUtil.encryptIfNotEmpty(json["SrvcReqDtlCode"] ?? "").trim();
        final mobile = CommonUtil.encryptIfNotEmpty(json["MobileNo"] ?? "").trim();
        final email = CommonUtil.encryptIfNotEmpty(json["Email"] ?? "").trim();

        final record = {
          "Cust_Name": CommonUtil.encryptIfNotEmpty(json["Cust_Name"] ?? "").trim(),
          "POLICY_NO": CommonUtil.encryptIfNotEmpty(json["PolicyNo"] ?? "").trim(),
          "LEAD_NO": leadNo,
          "MOBILE_NO": mobile,
          "EMAIL_ID": email,
          "IS_PRIMARY": CommonUtil.encryptIfNotEmpty(json["IsPrimary"] ?? "").trim(),
          "IS_PRIMARY_EMAIL": CommonUtil.encryptIfNotEmpty(json["IsEmailPrimary"] ?? "").trim(),
          "SRC": CommonUtil.encryptIfNotEmpty(json["SRC"] ?? "").trim(),
          "CREATEDDTIME": CommonUtil.encryptIfNotEmpty(json["CreateDTim"] ?? "").trim(),
          "DateInLong": CommonUtil.encryptIfNotEmpty(json["CreateDTim"]),
          "SyncStatus": CommonUtil.encryptIfNotEmpty("FromServer"),
        };

        batch.insert(
          "TBL_CUSTOMER_CNT_DTLS",
          record,
          conflictAlgorithm: ConflictAlgorithm.replace, // upsert
        );
      }

      await batch.commit(noResult: true);
      return true;
    } catch (e) {
      print("Error in CustomerContactRepository: $e");
      return false;
    }
  }
}