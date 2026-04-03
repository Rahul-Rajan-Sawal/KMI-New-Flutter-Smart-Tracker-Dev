import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/repository/customer_contact_repository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:http/http.dart';

Future<Map<String, dynamic>> searchCustomerContact({
  required String sapCode,
  required String leadNo,
  required String policyNo,
}) async {
  String errorFlag = "failed";
  bool isSearched = false;
  String responseBody = "";

  try {

    final requestJson = ApiRequestBuilder.buildSearchLeadRequest(
       sapCode: sapCode,
        leadNo: leadNo,
        policyNo: policyNo,
        tokenId: StaticVariables.TokenId,
        callerId: StaticVariables.callerId,
        callerPass: StaticVariables.callerPass!,
    );

    final responseString = await EncryptedHttpservice.post(
      url:"${StaticVariables.baseUrl}/${StaticVariables.SearchLead}", 
     requestJson: requestJson
    );

    responseBody = responseString;
    final decoded = jsonDecode(responseBody);
      if (decoded["Table"] != null && decoded["Table"].length > 0) {
      final first = decoded["Table"][0];

      if (first["ResponseCode"] == "1" || first["ResponseCode"] == "2") {
        print(first);
        return {
          "response": responseBody,
          "errorFlag": "error", 
        };
      }
    }

  final repo = CustomerContactRepository();
    isSearched = await repo.parseAndStoreCustomerContacts(responseBody);

    errorFlag = isSearched ? "success" : "error";
  } catch (e) {
    errorFlag = "true";
    print("Error in searchCustomerContact: $e");
  }


  return {
    "response": responseBody,
    "errorFlag": errorFlag,
  };
}