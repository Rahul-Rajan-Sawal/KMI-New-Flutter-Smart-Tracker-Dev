import 'dart:convert';

import 'package:flutter_bottom_nav/core/static_variables.dart';

class ApiRequestBuilder {
  static Map<String, dynamic> buildSearchLeadRequest({
    required String sapCode,
    required String leadNo,
    required String policyNo,
    required String tokenId,
    required String callerId,
    required String callerPass,
  }) {
    return {
      //    "objSearchLead": {
      //   "SAPCode": sapCode,
      //   "LeadNo": leadNo,
      //   "PolicyNo": policyNo,
      //   "CallerId": callerId,
      //   "CallerPass": callerPass,
      //   "TokenId": tokenId,
      // }
      "UserId": sapCode,
      "LeadNo": leadNo,
      "PolicyNo": policyNo,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }

  static String authenticateUserWithAppVersionn({
    required String userId,
    required String password,
    required String imeiString,
    required String appVersion,
    required String sso,
    required String callerId,
    required String callerPass,
    required String tokenId,
  }) {
    return jsonEncode({
      "UserId": userId,
      "Password": password,
      "IMEIstring": imeiString,
      "AppVersion": appVersion,
      "SSO": sso,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    });
  }

  static Map<String, dynamic> authenticateUserWithAppVersion({
    required String userId,
    required String password,
    required String imeiString,
    required String appVersion,
    required String sso,
    required String callerId,
    required String callerPass,
    required String tokenId,
  }) {
    return {
      "UserId": userId,
      "Password": password,
      "IMEIstring": imeiString,
      "AppVersion": appVersion,
      "SSO": sso,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }

  static Map<String, dynamic> getDashboardData({
    required String UserId,
    String? CurMonth,
    String? CallerId,
    String? CallerPass,
    String? TokenId,
  }) {
    return {
      "UserId": UserId,
      "CurMonth": CurMonth,
      "CallerId": CallerId,
      "CallerPass": CallerPass,
      "TokenId": TokenId,
    };
  }

  static Map<String, dynamic> getSearchData({
    required String SAPCode,
    String? LeadNo,
    String? ReqName,
    String? PolicyNo,
    String? ReqMobNo,
    String? LOB,
    String? Product,
    String? AgentCode,
    String? HNINCode,
    String? FromDate,
    String? ToDate,
    String? CallerId,
    String? CallerPass,
    String? TokenId,
  }) {
    return {
      "UserId": SAPCode,
      "LeadNo": LeadNo,
      "ReqName": ReqName,
      "PolicyNo": PolicyNo,
      "ReqMobNo": ReqMobNo,
      "LOB": LOB,
      "Product": Product,
      "AgentCode": AgentCode,
      "HNINCode": HNINCode,
      "FromDate": FromDate,
      "ToDate": ToDate,
      "CallerId": CallerId,
      "CallerPass": CallerPass,
      "TokenId": TokenId,
    };
  }

  static Map<String, dynamic> getCallDownTime({
    required String SAPCode,
    required String SrvcReqDtlCode,
    String? CallerId,
    String? CallerPass,
    String? TokenId,
  }) {
    return {
      "UserId": SAPCode,
      "SrvcReqDtlCode": SrvcReqDtlCode,
      "CallerId": CallerId,
      "CallerPass": CallerPass,
      "TokenId": TokenId,
    };
  }

  static Map<String, dynamic> bridgeCall({
    required String reqSystemCampaign,
    required String systemUniqueNo,
    required String smMobileNo,
    required String custMobileNo,
    required String systemEvent,
    required String systemName,
    required String msgToPlay,
    required String leadNo,
    required String sapCode,
  }) {
    return {
      "reqeusting_system_campaign": reqSystemCampaign,
      "system_UniqueNo": systemUniqueNo,
      "cust_mobile_no": smMobileNo,
      "cust_mobile_no_2": custMobileNo,
      "system_event": systemEvent,
      "system_name": systemName,
      "msg_to_play": msgToPlay,
      "LeadNo": leadNo,
      "UserId": sapCode,
    };
  }

  // static Map<String, dynamic> SearchAgentContact({
  //   String? ErrorFlag,
  //   //required String strResponse,
  //   required String SAPCode,
  //   required String IMDType,
  //   required String IMDValue,
  //   String? CallerId,
  //   String? callerPass,
  //   String? TokenId,
  // }) {
  //   return {
  //     "UserId": SAPCode,
  //     "IMDType": IMDType,
  //     "IMDValue": IMDValue,
  //     "CallerId": CallerId,
  //     "callerPass": callerPass,
  //     "TokenId": TokenId,
  //   };
  // }

  static Map<String, dynamic> SearchAgentContact({
    required String SAPCode,
    required String IMDType,
    required String IMDValue,
    String? CallerId,
    String? callerPass,
    String? TokenId,
  }) {
    return {
      "UserId": SAPCode,
      "IMDType": IMDType,
      "IMDValue": IMDValue,
      "CallerId": CallerId,
      "CallerPass": callerPass,
      "TokenId": TokenId,
    };
  }

  static Map<String, dynamic> SearchCustomerContact({
    required String SAPCode,
    required String mLeadNo,
    required String mPolicyNo,
  }) {
    return {
      "UserId": SAPCode,
      "LeadNo": mLeadNo,
      "PolicyNo": mPolicyNo,
      "CallerId": StaticVariables.callerId,
      "CallerPass": StaticVariables.callerPass,
      "TokenId": StaticVariables.TokenId,
    };
  }

  static Map<String, dynamic> MarkPrimaryContact({
    required String SAPCode,
    required String ProgramFlag,
    required String ParamValue,
    required String MobileNo,
    required String EmailID,
    required String IsPrimaryMobile,
    required String IsPrimaryEmail,
    required String CallerId,
    required String CallerPass,
    required String tokenId,
  }) {
    return {
      "UserId": SAPCode,
      "ParamFlag": ProgramFlag,
      "ParamValue": ParamValue,
      "MobileNo": MobileNo,
      "EmailID": EmailID,
      "IsPrimary": IsPrimaryMobile,
      "IsEmailPrimary": IsPrimaryEmail,
      "CallerId": CallerId,
      "CallerPass": CallerPass,
      "TokenId": tokenId,
    };
  }

  static Map<String, dynamic> SubmitAgntContact({
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
  }) {
    return {
      "UserId": sapCode,
      "IMDType": intermediaryType,
      "IMDValue": intermediaryValue,
      "IMGName": intermediaryName,
      "MobileNo": contactNo,
      "EmailID": emailId,
      "IsPrimary": isPrimaryMobile,
      "IsEmailPrimary": isPrimaryEmail,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }

  static Map<String, dynamic> submitCustomerContact({
    required String sapCode,
    required String leadNo,
    required String policyNo,
    required String contactNo,
    required String emailId,
    required String isPrimaryMobile,
    required String isPrimaryEmail,
    String? callerId,
    String? callerPass,
    required String tokenId,
  }) {
    return {
      "UserId": sapCode,
      "LeadNo": leadNo,
      "PolicyNo": policyNo,
      "ContactNo": contactNo,
      "EmailId": emailId,
      "IsPrimary": isPrimaryMobile,
      "IsPrimaryEmail": isPrimaryEmail,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }

  static Map<String, dynamic> GetCalendarData({
    required String sapCode,
    required String dayFirst,
    required String callerId,
    required String callerPass,
    required String tokenId,
  }) {
    return {
      "UserId": sapCode,
      "Date": "$dayFirst-01",
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }
}
