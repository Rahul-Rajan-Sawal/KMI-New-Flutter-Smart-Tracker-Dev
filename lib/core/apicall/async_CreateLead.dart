import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

Future<Map<String, dynamic>> createLeadFromMob({
  required String sapCode,
  required String reqChannelId,
  required String leadSource,
  required String leadSubSource,
  required String businessType,
  required String LOBCode,
  required String prodCode,
  required String saleType,
  required String LeadQueue,
  required String name,
  required String mobileTel,
  required String addr1,
  required String addr2,
  required String addr3,
  required String cityCode,
  required String districtCode,
  required String stateCode,
  required String pinCode,
  required String area,
  required String TempSrvcReqDtlCode,
  required String callerId,
  required String callerPass,
  required String tokenId,
}) async {
  try {
    final requestJson = ApiRequestBuilder.CreateLeadFromMob(
      SAPCode: StaticVariables.mSAPCode,
      reqChannelId: reqChannelId,
      leadSource: leadSource,
      leadSubSource: leadSubSource,
      businessType: businessType,
      LOBCode: LOBCode,
      prodCode: prodCode,
      saleType: saleType,
      LeadQueue: LeadQueue,
      name: name,
      mobileTel: mobileTel,
      addr1: addr1,
      addr2: addr2,
      addr3: addr3,
      cityCode: cityCode,
      districtCode: districtCode,
      stateCode: stateCode,
      pinCode: pinCode,
      area: area,
      TempSrvcReqDtlCode: TempSrvcReqDtlCode,
      CallerId: StaticVariables.callerId,
      CallerPass: callerPass,
      TokenId: StaticVariables.TokenId,
    );

    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.CreateLeadFromMob}",
      requestJson: requestJson,
    );

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    print("CreateLeadFromMob Response: $jsonResponse");

    return jsonResponse;
  } catch (e) {
    print("CreateLeadFromMob Error: $e");
    return {};
  }
}
