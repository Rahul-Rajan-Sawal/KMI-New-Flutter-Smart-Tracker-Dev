import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class GetLastActivityForLeadApi {
  static Future<Map<String, dynamic>> getData({
    required String SAPCode,
    required String SrvcReqDtlCode,
  }) async {
    try {
      final requestJson =
          ApiRequestBuilder.getLastActivityForLead(
        SAPCode: SAPCode,
        SrvcReqDtlCode: SrvcReqDtlCode,
        callerId: StaticVariables.callerId,
        callerPass: StaticVariables.callerPass,
        tokenId: StaticVariables.TokenId,
      );

      final responseString = await EncryptedHttpservice.post(
        url:
            "${StaticVariables.baseUrl}/${StaticVariables.getLastActivityForLead}",
        requestJson: requestJson,
      );

      final jsonResponse = jsonDecode(responseString);

      return jsonResponse;
    } catch (e) {
      print("GetLastActivity Error: $e");
      return {};
    }
  }
}