import 'dart:convert';
import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

Future<Map<String, dynamic>> markPrimaryContact({
  required String sapCode,
  required String programFlag,
  required String paramValue,
  required String mobileNo,
  required String emailId,
  required String isPrimaryMobile,
  required String isPrimaryEmail,
  required String callerId,
  required String callerPass,
  required String tokenId,
}) async {
  try {
    // Step 1: Build request
    final requestJson = ApiRequestBuilder.MarkPrimaryContact(
      SAPCode: sapCode,
      ProgramFlag: programFlag,
      ParamValue: paramValue,
      MobileNo: mobileNo,
      EmailID: emailId,
      IsPrimaryMobile: isPrimaryMobile,
      IsPrimaryEmail: isPrimaryEmail,
      CallerId: callerId,
      CallerPass: callerPass,
      tokenId: tokenId,
    );

    print("MarkPrimaryContact REQUEST: $requestJson");

    // Step 2: Send API call
    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.MarkPrimaryContact}",
      requestJson: requestJson,
    );

    print("MarkPrimaryContact REQUEST: $requestJson");

    print("MarkPrimaryContact RESPONSE: $responseString");

    // Step 3: Decode and return
    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
    print("Jsonreponse print $jsonResponse");
    return jsonResponse;
  } catch (e) {
    print("MarkPrimaryContact Error: $e");
    return {};
  }
}
