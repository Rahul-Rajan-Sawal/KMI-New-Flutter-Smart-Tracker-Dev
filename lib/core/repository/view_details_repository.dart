import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/async_getcalldowntime.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/contact_Model.dart';

class ViewDetailsRepository {
  Future<Map<String, String>?> getBridgeCallTimes(String userId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final encryptedLeadId = CommonUtil.encryptIfNotEmpty(userId);

      final result = await db.query(
        'iUser',
        columns: [
          'BridgeCallToTime',
          'BridgeCallFromTime',
          'BridgeCallDownTime',
        ],
        where: 'UserId = ?',
        whereArgs: [encryptedLeadId],
        // limit: 1,
      );

      if (result.isNotEmpty) {
        final row = result.first;

        return {
          "BridgeCallToTime": CommonUtil.decryptIfNotEmpty(
            row['BridgeCallToTime']?.toString() ?? "",
          ),
          "BridgeCallFromTime": CommonUtil.decryptIfNotEmpty(
            row['BridgeCallFromTime']?.toString() ?? "",
          ),
          "BridgeCallDownTime": CommonUtil.decryptIfNotEmpty(
            row['BridgeCallDownTime']?.toString() ?? "",
          ),
        };
      }

      return null;
    } catch (e) {
      print("ViewDetailsRepository ERROR: $e");
      return null;
    }
  }

  Future<bool> isDownTime({
    required String sapCode,
    required String srvcReqDtlCode,
  }) async {
    try {
      final response = await GetCallDownTime.getData(
        SAPCode: sapCode,
        SrvcReqDtlCode: srvcReqDtlCode,
      );

      if (response.isEmpty) return false;

      final List table = response["Table"] ?? [];

      for (var item in table) {
        String responseCode = item["ResponseCode"] ?? "";
        String message = item["Message"] ?? "";

        if (responseCode == "0" && message.startsWith("You can initiate")) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print("isDownTime ERROR: $e");
      return false;
    }
  }

  ///Customer Contact mobile details
  Future<List<ContactModel>> getCustomerMobileContacts(String leadId) async {
    final List<ContactModel> contacts = [];

    try {
      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'TBL_CUSTOMER_CNT_DTLS',
       where: 'LEAD_NO = ?',
      whereArgs: [CommonUtil.encryptIfNotEmpty(leadId)],
        orderBy: 'DateInLong ASC',
      );
    print(result);
      for (var row in result) {
        final model = ContactModel.fromMap(row);

        final decryptedContact = CommonUtil.decryptIfNotEmpty(model.contact);

        final updatemodel = ContactModel(
          custCode: model.custCode,
          type: model.type,
          contact: decryptedContact,
        );

        //validation

        if (updatemodel.isValidMobile) {
          contacts.add(updatemodel);
        }
        print(CommonUtil.decryptIfNotEmpty(contacts));
      }

      final uniqueMap = <String, ContactModel>{};

      for (var contact in contacts) {
        final key = contact.cleanedContact!;
        uniqueMap[key] = contact;
      }
      return uniqueMap.values.toList();
    } catch (e) {
      print("Error while fetching cust contact : $e");
      return [];
    }
  }

  Future<List<String>> getCustomerMobileNumbers(String leadId) async {
    final contacts = await getCustomerMobileContacts(leadId);
    return contacts.map((e) => e.cleanedContact!).toList();
  }
}
