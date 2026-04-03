import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class Bridgeapicall {
  static Future<Map<String, dynamic>> call({
    required String smMobileNo,
    required String custMobileNo,
    required String reqSystemCampaign,
    required String systemUniqueNo,
    required String systemEvent,
    required String systemName,
    required String msgToPlay,
    required String leadNo,
    required String sapCode,
  }) async {
    try {
      final requestJson = ApiRequestBuilder.bridgeCall(
        reqSystemCampaign: reqSystemCampaign,
        systemUniqueNo: systemUniqueNo,
        smMobileNo: smMobileNo,
        custMobileNo: custMobileNo,
        systemEvent: systemEvent,
        systemName: systemName,
        msgToPlay: msgToPlay,
        leadNo: leadNo,
        sapCode: sapCode,
        // callerId: StaticVariables.callerId,
        // callerPass: StaticVariables.callerPass,
        // tokenId: StaticVariables.TokenId,
      );

      final responseString = await EncryptedHttpservice.post(
        url: "${StaticVariables.baseUrl}/${StaticVariables.bridgeCallDtls}",
        requestJson: requestJson,
      );



      final Map<String, dynamic> jsonResponse =jsonDecode(responseString);
    print(jsonResponse);
    return jsonResponse;
    
    } catch (e) {
      print("BridgeCall Error : $e");
      return{};
    }
  }
}
