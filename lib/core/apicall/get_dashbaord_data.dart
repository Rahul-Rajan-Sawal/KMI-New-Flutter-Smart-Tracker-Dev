import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter/foundation.dart';

class GetDashbaordData {
  static Future<Map<String, dynamic>> getdashboarddata({
    required String UserId,
    required String CurMonth,
  }) async {
    final requestJson = ApiRequestBuilder.getDashboardData(
      UserId: UserId,
      CurMonth: CurMonth,
      CallerId: StaticVariables.callerId,
      CallerPass: StaticVariables.callerPass!,
      TokenId: StaticVariables.TokenId,
    );
    final String responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.GetDashboardData}",
      requestJson: requestJson,
    );
    debugPrint(responseString);

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    print("GetDashboardData: $jsonResponse");
    return jsonResponse;
  }
}
