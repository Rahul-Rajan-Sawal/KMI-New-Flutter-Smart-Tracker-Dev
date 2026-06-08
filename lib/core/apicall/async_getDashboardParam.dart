import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class GetDashboardParamApi {
  static Future<Map<String, dynamic>> getData({
    required String sapCode,
    required String branchCode,
    required String smCode,
    required String agentCode,
    required String flag,
    required String filterType,
    required String year,
    required String month,
  }) async {
    try {
      /// Request JSON
      final requestJson = ApiRequestBuilder.GetDashboardParam(
        SAPCode: sapCode,
        BranchCode: branchCode,
        Flag: flag,
        SMCode: smCode,
        AgentCode: agentCode,
        DType: filterType,
        Year: year,
        Month: month,
        CallerId: StaticVariables.callerId,
        CallerPass: StaticVariables.callerPass!,
        tokenId: StaticVariables.TokenId,
      );

      /// API Call
      final String responseString = await EncryptedHttpservice.post(
        url: "${StaticVariables.baseUrl}/${StaticVariables.GetDashboardParam}",
        requestJson: requestJson,
      );

      /// Decode Response
      final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

      // =====================================================

      // await CommonRepo().saveZoneRegionBranchListBatch(
      //   response: jsonResponse,
      //   year: year,
      //   month: month,
      // );
      // Repository call for DB save can be added here later

      // await FilterRepository().saveDashboardData(jsonResponse);

      return jsonResponse;
    } catch (e) {
      print("GetDashboardParamApi Error: $e");
      return {};
    }
  }
}
