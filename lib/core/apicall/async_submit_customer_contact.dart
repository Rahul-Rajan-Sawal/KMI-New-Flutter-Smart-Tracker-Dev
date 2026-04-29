// SubmitCustContact
import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:http/http.dart';

Future<Map<String, dynamic>> submitcustomercontact({
  required String sapCode,
  required String leadNo,
  required String policyNo,
  required String contactNo,
  required String emailId,
  required String isPrimaryMobile,
  required String isPrimaryEmail,
  required String callerId,
  required String callerPass,
  required String tokeId,
}) async {
  try {
    final requestJson = ApiRequestBuilder.submitCustomerContact(
      sapCode: sapCode,
      leadNo: leadNo,
      policyNo: policyNo,
      contactNo: contactNo,
      emailId: emailId,
      isPrimaryMobile: isPrimaryMobile,
      isPrimaryEmail: isPrimaryEmail,
      callerId: callerId,
      callerPass: callerPass,
      tokenId: StaticVariables.TokenId,
    );

    print("SubmitCust Request: $requestJson");

    //API call
    final responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.SubmitCustContact}",
      requestJson: requestJson,
    );

    print("SubmitCustContact Response: $responseString");

    //Decode and return
    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
    return jsonResponse;
  } catch (e) {
    print("Error: $e");
    return {};
  }
}
