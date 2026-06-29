import 'dart:convert';
import 'package:flutter_bottom_nav/core/apicall/async_get_LeadDataForUser.dart';
import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

Future<Map<String, dynamic>> GetLeadDataForUser({
  required String sapCode,
  required String CurrentMonth,
  required String callerId,
  required String callerPass,
  required String tokenId,
}) async {
  try {
    final requestJson = ApiRequestBuilder.GetLeadDataForUser(
      UserId: sapCode,
      CurMonth: CurrentMonth,
      CallerPass: callerPass,
      CallerId: callerId,
      TokenId: tokenId,
    );

    print("GetLeadDataForUser : $requestJson");

    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.GetLeadDataForUser}",
      requestJson: requestJson,
    );

    print("Response $responseString");

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    print("jsonresponse $jsonResponse");

    return jsonResponse;
  } catch (e) {
    print("Error $e");
    return {};
  }
}
