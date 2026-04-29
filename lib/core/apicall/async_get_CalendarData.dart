import 'dart:convert';
import 'dart:math';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/models/calendarDataModel.dart';

class AsyncGetCalendardata {
  Future<List<CalendarDataModel>> getCalendarData({
    required String SAPCode,
    required String curMonth,
  }) async {
    try {
      final requestJson = ApiRequestBuilder.GetCalendarData(
        SAPCode: SAPCode,
        CurMonth: curMonth,
        CallerId: StaticVariables.callerId,
        callerPass: StaticVariables.callerPass!,
        TokenId: StaticVariables.TokenId,
      );

      final responseString = await EncryptedHttpservice.post(
        url: "${StaticVariables.baseUrl}/${StaticVariables.GetCalendarData}",
        requestJson: requestJson,
      );

      print("Calendar data respnse check : $responseString");

      String cleaner = responseString
          .replaceAll('{  "Table": [ ', '[')
          .replaceAll('{"Table":[', '[')
          .replaceAll('] }', ']')
          .replaceAll(']}', ']');

      
      final List<dynamic> jsonList = jsonDecode(cleaner);

      final List<CalendarDataModel> dataList = jsonList.map((e)=>CalendarDataModel.fromJson(e)).toList();
     
      return dataList;
      //final jsonResponse = jsonDecode(responseString);
    } catch (e) {
      print("Error Getting Calendar data : $e");
      return [];
    }
  }
}
