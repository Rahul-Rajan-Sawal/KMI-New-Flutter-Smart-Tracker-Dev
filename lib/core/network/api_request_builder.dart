import 'dart:convert';

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

  // static Map<String, dynamic> bridgeCall({
  //   required String reqSystemCampaign,
  //   required String systemUniqueNo,
  //   required String smMobileNo,
  //   required String custMobileNo,
  //   required String systemEvent,
  //   required String systemName,
  //   required String msgToPlay,
  //   required String leadNo,
  //   required String sapCode,
  //   String? callerId,
  //   String? callerPass,
  //   String? tokenId,
  // }) {
  //   return {
  //     "Req_system_campaign": reqSystemCampaign,
  //     "System_UniqueNo": systemUniqueNo,
  //     "SMMobileNo": smMobileNo,
  //     "CustMobileNo": custMobileNo,
  //     "System_event": systemEvent,
  //     "SystemName": systemName,
  //     "MsgToPlay": msgToPlay,
  //     "LeadNo": leadNo,
  //     "UserId": sapCode,
  //     "CallerId": callerId,
  //     "CallerPass": callerPass,
  //     "TokenId": tokenId,
  //   };
  // }

}
