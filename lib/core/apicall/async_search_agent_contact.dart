import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

Future<Map<String, dynamic>> searchAgentContact({
  required String sapCode,
  required String imdType,
  required String imdValue,
}) async {
  try {
    // 🔷 Build Request
    final requestJson = ApiRequestBuilder.SearchAgentContact(
      SAPCode: sapCode,
      IMDType: imdType,
      IMDValue: imdValue,
      CallerId: StaticVariables.callerId,
      callerPass: StaticVariables.callerPass,
      TokenId: StaticVariables.TokenId,
    );

    print("REQUEST: $requestJson");

    // 🔷 Call API (Encrypted flow - same as your system)
    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.SearchAgent}",
      requestJson: requestJson,
    );

    print("RESPONSE STRING: $responseString");

    // 🔷 Convert to JSON
    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    return jsonResponse;
  } catch (e) {
    print("SearchAgentContact Error: $e");
    return {};
  }
}
