import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class GetDataForDashboard {
  static Future<Map<String, dynamic>> getDataForDashboard({
    required String UserId,
    required String CurMonth,
    required String ActivityCode,
    required String SubActivityCode,
    required String Status,
  }) async {
    final requestJson = ApiRequestBuilder.getDataForDashboard(
      UserId: UserId,
      CurMonth: CurMonth,
      ActivityCode: ActivityCode,
      SubActivityCode: SubActivityCode,
      Status: Status,
      CallerId: StaticVariables.callerId,
      CallerPass: StaticVariables.callerPass!,
      TokenId: StaticVariables.TokenId,
    );

    debugPrint("========== GetDataForDashboard REQUEST ==========");
    debugPrint(jsonEncode(requestJson));

    final String responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.GetDataForDashboard}",
      requestJson: requestJson,
    );

    debugPrint("========== GetDataForDashboard RAW RESPONSE ==========");
    debugPrint(responseString);

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    print("GetDataForDashboard: $jsonResponse");

    return jsonResponse;
  }
}
