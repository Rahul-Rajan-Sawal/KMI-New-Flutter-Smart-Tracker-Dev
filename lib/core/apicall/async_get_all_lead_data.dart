import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

Future<Map<String, dynamic>> GetAllAssignedLeads({
  required String sapCode,
  required String CurMonth,
  required String lastSyncDate,
}) async {
  try {
    final requestJson = ApiRequestBuilder.GetAllAssignedLeads(
      sapCode: sapCode,
      CurMonth: CurMonth,
      lastSyncDate: lastSyncDate,
      CallerId: StaticVariables.callerId,
      CallerPass: StaticVariables.callerPass!,
      tokenId: StaticVariables.TokenId,
    );

    print("Request: $requestJson");

    //call API
    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.GetAllAssignedLeads}",
      requestJson: requestJson,
    );

    print("Response: $responseString");

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    return jsonResponse;
  } catch (e) {
    print("GetAllAssignedLeads Error : $e");
    return {};
  }
}
