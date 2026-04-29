import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

Future<Map<String, dynamic>> submitagentcontact({
  required String sapCode,
  required String intermediaryType,
  required String intermediaryValue,
  required String intermediaryName,
  required String contactNo,
  required String emailId,
  required String isPrimaryMobile,
  required String isPrimaryEmail,
  required String callerId,
  required String callerPass,
  required String tokenId,
}) async {
  try {
    final requestJson = ApiRequestBuilder.SubmitAgntContact(
      sapCode: sapCode,
      intermediaryType: intermediaryType,
      intermediaryValue: intermediaryValue,
      intermediaryName: intermediaryName,
      contactNo: contactNo,
      emailId: emailId,
      isPrimaryMobile: isPrimaryMobile,
      isPrimaryEmail: isPrimaryEmail,
      callerId: callerId,
      callerPass: callerPass,
      tokenId: tokenId,
    );

    print("SubmitAgentContact Request: $requestJson");

    //APi Call
    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.SubmitAgntContact}",
      requestJson: requestJson,
    );

    print("SubmitAgentContact Request: $requestJson");

    print("SubmitAgentContact Response: $responseString");

    //Decode and return

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
    return jsonResponse;
  } catch (e) {
    print("Error: $e");
    return {};
  }
}
