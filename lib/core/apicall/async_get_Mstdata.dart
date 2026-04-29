import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/repository/getmasrteDatarepository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class MastersMappingApi {
  static Future<bool> call({
    required String userId,
    // required String LastSyncDate,
  }) async {
    try {
      final requestJson = ApiRequestBuilder.getMastersMapping(
        userId: userId,
        // LastSyncDate: StaticVariables.lastSyncDate,
        callerId: StaticVariables.callerId,
        callerPass: StaticVariables.callerPass!,
        tokenId: StaticVariables.TokenId,
      );

      final responseString = await EncryptedHttpservice.post(
        url: "${StaticVariables.baseUrl}/${StaticVariables.GetMstMapping}",
        requestJson: requestJson,
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

      print("Masters Mapping Response Received  :  $jsonResponse");

      List table = jsonResponse["Table"];

      for (var item in table) {
        print(item); 
      }

      await MastersRepository.insertMasters(jsonResponse);

      return true;
    } catch (e) {
      print("GetMastersMapping Error : $e");
      return false;
    }
  }
}
