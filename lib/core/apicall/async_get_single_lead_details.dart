import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

Future<Map<String, dynamic>> GetSingleLeadDetails({
  required String sapCode,
  required String LeadID,
  required String PolicyNo,
}) async {
  try {
    final requestJson = ApiRequestBuilder.GetLeadDetails(
      sapCode: sapCode,
      LeadID: LeadID,
      PolicyNo: PolicyNo,
      tokenId: StaticVariables.TokenId, 
    );

    print("Printing $requestJson");

    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.GetLeadDetails}",
      requestJson: requestJson,
    );

    print("Printed $responseString");

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    print(jsonResponse);

    return jsonResponse;
  } catch (e) {
    print("Error In SingleLeadDetails $e");
    return {};
  }
}
