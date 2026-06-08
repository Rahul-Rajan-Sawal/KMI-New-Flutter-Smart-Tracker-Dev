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
  // }) {
  //   return {
  //     "reqeusting_system_campaign": reqSystemCampaign,
  //     "system_UniqueNo": systemUniqueNo,
  //     "cust_mobile_no": smMobileNo,
  //     "cust_mobile_no_2": custMobileNo,
  //     "system_event": systemEvent,
  //     "system_name": systemName,
  //     "msg_to_play": msgToPlay,
  //     "LeadNo": leadNo,
  //     "UserId": sapCode,
  //   };
  // }

  static Map<String, dynamic> getMastersMapping({
    required String userId,
    //required String LastSyncDate,
    required String callerId,
    required String callerPass,
    required String tokenId,
  }) {
    return {
      "UserId": userId,
      // "LastSyncDate": LastSyncDate,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }

  static Map<String, dynamic> getLastActivityForLead({
    required String SAPCode,
    required String SrvcReqDtlCode,
    required String callerId,
    String? callerPass,
    required String tokenId,
  }) {
    return {
      "UserId": SAPCode,
      "SrvcReqDtlCode": SrvcReqDtlCode,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }

  static Map<String, dynamic> GetCalendarData({
    required String SAPCode,
    required String CurMonth,
    required String CallerId,
    required String callerPass,
    //String? callerPass,
    required String TokenId,
  }) {
    return {
      "UserId": SAPCode,
      "CurMonth": CurMonth,
      "CallerId": CallerId,
      "CallerPass": callerPass,
      "TokenId": TokenId,
    };
  }

  // Request method for update activity
  static Map<String, dynamic> updateActivityRequest({
    required String sapCode,
    required String CltCode,
    required String SrvcReqDtlCode,
    required String ActivityCode,
    required String SubActivityCode,
    required String AppointmentDate,
    required String Hour,
    required String Minute,
    required String AppointmentAddrss,
    required String AppThrough,
    required String ResThrough,
    required String RescheduleDate,
    required String RescheduleAddrss,
    required String ParkedLead,
    required String ProposalNo,
    required String IssuedPolicyNo,
    required String PremiumCollected,
    required String AppReason,
    required String SubReason,
    required String DuplicateLeadId,
    required String ComptitorID,
    required String LocationDtls,
    required String NonContble,
    required String NotIntrest,
    required String PhoneNumber,
    required String CreateBy,
    required String CreateDTim,
    required String UpdateBy,
    required String UpdateDTim,
    required String IsActive,
    required String oriPREMCOL,
    required String MakenModel,
    required String ExpiryDate,
    required String CallBackDate,
    required String InfectionID,
    required String TicketNo,
    required String QuoteNo,
    required String LcReason,
    required String LcSubReason,
    required String Age,
    required String RtoLoc,
    required String Price,
    required String YOM,
    required String PED,
    required String Feature,
    required String Area,
    required String PHC_NO,
    required String ProductType,
    required String Lan,
    required String PostPQuery,
    required String NotEligible,
    required String Reason,
    required String RsReason,
    required String ModelValue,
    required String NonContactableDtm,
    required String CallBackDateRenewal,
    required String NonConRes,
    required String ChequeNo,
    required String ChequeDate,
    required String ChequeBankName,
    required String RegistrationNo,
    required String RenewalLeadLostReason,
    required String PolicyAlreadyRenewedReason,
    required String ParkedLeadDateTime,
    required String FollowupDt,
    required String QutationDt,

    required String ddlAct16Subreason,
    required String txt416,
    required String txtAD16,
    required String txtPN16,
    required String txt316,
    required String ddlMakeModel516,
    required String ddlModel616,
    required String txt716,
    required String txt816,
    required String ddlAppReasonTrack5,
    required String ddlSubReason,
    required String txtDuplicateLeadId,
    required String ddlCompetitorList,
    required String txtLocationDtls,
    required String txtTctNoact5,
    required String txtAge,
    required String txtArea2,
    required String ddlRTOLoc,
    required String txtPhcNo,
    required String txtPrice,
    required String txtPrdType,
    required String txtYOM,
    required String txtPed2,
    required String txtLanguage,
    required String ddlMakeModelact5,
    required String txtReason5,
    required String txtCallBakDateTime19,
    required String txtPN19,
    required String txt319,

    required String txtRMSAppointmentDate,
    required String txtRMSCallBackDate,
    required String ddlRMSNonContactableReason,
    required String txtRMSChequeNo,
    required String ddlRMSRenewalLeadLostReason,
    required String ddlRMSPolicyAlreadyRenewedReason,
    required String txtRMSMobileNo,
    required String txtAppointmentDate27,
    required String txtRescheduletDate28,
    required String ddlAppReasonTrack29,
    required String txtPolicyNo30,
    required String txtParkedLead31,
    required String txtFollowup32,
    required String txtQutation33,
    required String internalcomment,

    required String InstType,
    required String LstComDueTo,
    required String NewPolEndDate,
    required String Remark,
    String? callerId,
    String? callerPass,
    String? tokenId,
  }) {
    return {
      "UserId": sapCode,

      "CltCode": CltCode,
      "SrvcReqDtlCode": SrvcReqDtlCode,
      "ActivityCode": ActivityCode,
      "SubActivityCode": SubActivityCode,
      "AppointmentDate": AppointmentDate,
      "Hour": Hour,
      "Minute": Minute,
      "AppointmentAddrss": AppointmentAddrss,
      "AppThrough": AppThrough,
      "ResThrough": ResThrough,
      "RescheduleDate": RescheduleDate,
      "RescheduleAddrss": RescheduleAddrss,
      "ParkedLead": ParkedLead,
      "ProposalNo": ProposalNo,
      "IssuedPolicyNo": IssuedPolicyNo,
      "PremiumCollected": PremiumCollected,
      "AppReason": AppReason,
      "SubReason": SubReason,
      "DuplicateLeadId": DuplicateLeadId,
      "ComptitorID": ComptitorID,
      "LocationDtls": LocationDtls,
      "NonContble": NonContble,
      "NotIntrest": NotIntrest,
      "PhoneNumber": PhoneNumber,
      "CreateBy": CreateBy,
      "CreateDTim": CreateDTim,
      "UpdateBy": UpdateBy,
      "UpdateDTim": UpdateDTim,
      "IsActive": IsActive,
      "oriPREMCOL": oriPREMCOL,
      "MakenModel": MakenModel,
      "ExpiryDate": ExpiryDate,
      "CallBackDate": CallBackDate,
      "InfectionID": InfectionID,
      "TicketNo": TicketNo,
      "QuoteNo": QuoteNo,
      "LcReason": LcReason,
      "LcSubReason": LcSubReason,
      "Age": Age,
      "RtoLoc": RtoLoc,
      "Price": Price,
      "YOM": YOM,
      "PED": PED,
      "Feature": Feature,
      "Area": Area,
      "PHC_NO": PHC_NO,
      "ProductType": ProductType,
      "Lan": Lan,
      "PostPQuery": PostPQuery,
      "NotEligible": NotEligible,
      "Reason": Reason,
      "RsReason": RsReason,
      "ModelValue": ModelValue,
      "NonContactableDtm": NonContactableDtm,
      "CallBackDateRenewal": CallBackDateRenewal,
      "NonConRes": NonConRes,
      "ChequeNo": ChequeNo,
      "ChequeDate": ChequeDate,
      "ChequeBankName": ChequeBankName,
      "RegistrationNo": RegistrationNo,
      "RenewalLeadLostReason": RenewalLeadLostReason,
      "PolicyAlreadyRenewedReason": PolicyAlreadyRenewedReason,
      "ParkedLeadDateTime": ParkedLeadDateTime,
      "FollowupDt": FollowupDt,
      "QutationDt": QutationDt,

      "ddlAct16Subreason": ddlAct16Subreason,
      "txt416": txt416,
      "txtAD16": txtAD16,
      "txtPN16": txtPN16,
      "txt316": txt316,
      "ddlMakeModel516": ddlMakeModel516,
      "ddlModel616": ddlModel616,
      "txt716": txt716,
      "txt816": txt816,
      "ddlAppReasonTrack5": ddlAppReasonTrack5,
      "ddlSubReason": ddlSubReason,
      "txtDuplicateLeadId": txtDuplicateLeadId,
      "ddlCompetitorList": ddlCompetitorList,
      "txtLocationDtls": txtLocationDtls,
      "txtTctNoact5": txtTctNoact5,
      "txtAge": txtAge,
      "txtArea2": txtArea2,
      "ddlRTOLoc": ddlRTOLoc,
      "txtPhcNo": txtPhcNo,
      "txtPrice": txtPrice,
      "txtPrdType": txtPrdType,
      "txtYOM": txtYOM,
      "txtPed2": txtPed2,
      "txtLanguage": txtLanguage,
      "ddlMakeModelact5": ddlMakeModelact5,
      "txtReason5": txtReason5,
      "txtCallBakDateTime19": txtCallBakDateTime19,
      "txtPN19": txtPN19,
      "txt319": txt319,

      "txtRMSAppointmentDate": txtRMSAppointmentDate,
      "txtRMSCallBackDate": txtRMSCallBackDate,
      "ddlRMSNonContactableReason": ddlRMSNonContactableReason,
      "txtRMSChequeNo": txtRMSChequeNo,
      "ddlRMSRenewalLeadLostReason": ddlRMSRenewalLeadLostReason,
      "ddlRMSPolicyAlreadyRenewedReason": ddlRMSPolicyAlreadyRenewedReason,
      "txtRMSMobileNo": txtRMSMobileNo,

      "txtAppointmentDate27": txtAppointmentDate27,
      "txtRescheduletDate28": txtRescheduletDate28,
      "ddlAppReasonTrack29": ddlAppReasonTrack29,
      "txtPolicyNo30": txtPolicyNo30,
      "txtParkedLead31": txtParkedLead31,
      "txtFollowup32": txtFollowup32,
      "txtQutation33": txtQutation33,
      "internalcomment": internalcomment,

      "InstType": InstType,
      "LstComDueTo": LstComDueTo,
      "NewPolEndDate": NewPolEndDate,
      "Remark": Remark,

      "CallerId": StaticVariables.callerId,
      "CallerPass": StaticVariables.callerPass,
      "TokenId": StaticVariables.TokenId,
    };
  }

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

  static Map<String, dynamic> GetAllAssignedLeads({
    required String sapCode,
    required String CurMonth,
    required String lastSyncDate,
    required String CallerId,
    required String CallerPass,
    required String tokenId,
  }) {
    return {
      "UserId": sapCode,
      "CurMonth": CurMonth,
      "LastSyncDate": lastSyncDate,
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

  static Map<String, dynamic> GetLeadDetails({
    required String sapCode,
    required String LeadID,
    required String PolicyNo,
    String? callerId,
    String? callerPass,
    required String tokenId,
  }) {
    return {
      "UserId": sapCode,
      "LeadID": LeadID,
      "PolicyNo": PolicyNo,
      "CallerId": callerId,
      "CallerPass": callerPass,
      "TokenId": tokenId,
    };
  }
}
