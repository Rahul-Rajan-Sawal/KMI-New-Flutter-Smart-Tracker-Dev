import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class GetCallDownTime {
  static Future<Map<String, dynamic>> getData({
    required String SAPCode,
    required String SrvcReqDtlCode,
  }) async {
    try {
      
      final requestJson = ApiRequestBuilder.getCallDownTime(
        SAPCode: SAPCode,
        SrvcReqDtlCode: SrvcReqDtlCode,
        CallerId: StaticVariables.callerId,
        CallerPass: StaticVariables.callerPass,
        TokenId: StaticVariables.TokenId,
      );

      //API call
      final String responseString = await EncryptedHttpservice.post(
        url:
            "${StaticVariables.baseUrl}/${StaticVariables.getCallDownTime}",
        requestJson: requestJson,
      );

    
      final Map<String, dynamic> jsonResponse =
          jsonDecode(responseString);

      return jsonResponse;

    } catch (e) {
      print("Error: $e");
      return {};
    }
  }
}