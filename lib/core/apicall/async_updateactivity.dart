import 'dart:convert';

import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/repository/activityrepository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class UpdateActivityService {
  static Future<Map<String, dynamic>> call({
    required String srvcReqDtlCode,
  }) async {
    try {
      //get data from repo
      final data = await ActivityRepository.getActivityData(srvcReqDtlCode);

      if (data == null) {
        return {"status": "error", "message": "No data found in DB"};
      }

      final requestJson = ApiRequestBuilder.updateActivityRequest(
        sapCode: StaticVariables.mSAPCode,
        CltCode: (data["CltCode"] ?? "").toString(),
        //CltCode: data["CltCode"].toString()?? "",
        SrvcReqDtlCode: data["SrvcReqDtlCode"],
        ActivityCode: (data["ActivityCode"]).toString(),
        SubActivityCode: (data["SubActivityCode"]).toString(),
        AppointmentDate: (data["AppointmentDate"]).toString(),
        Hour: (data["Hour"]).toString(),
        Minute: (data["Minute"]).toString(),
        AppointmentAddrss: (data["AppointmentAddrss"]).toString(),
        AppThrough: (data["AppThrough"]).toString(),
        ResThrough: (data["ResThrough"]).toString(),
        RescheduleDate: (data["RescheduleDate"]).toString(),
        RescheduleAddrss: (data["RescheduleAddrss"]).toString(),
        ParkedLead: (data["ParkedLead"]).toString(),
        ProposalNo: (data["ProposalNo"]).toString(),
        IssuedPolicyNo: (data["IssuedPolicyNo"]).toString(),
        PremiumCollected: (data["PremiumCollected"]).toString(),
        AppReason: (data["AppReason"]).toString(),
        SubReason: (data["SubReason"]).toString(),
        DuplicateLeadId: (data["DuplicateLeadId"]).toString(),
        ComptitorID: (data["ComptitorID"]).toString(),
        LocationDtls: (data["LocationDtls"]).toString(),
        NonContble: (data["NonContble"]).toString(),
        NotIntrest: (data["NotIntrest"]).toString(),
        PhoneNumber: (data["PhoneNumber"]).toString(),
        CreateBy: (data["CreateBy"]).toString(),
        CreateDTim: (data["CreateDTim"]).toString(),
        UpdateBy: (data["UpdateBy"]).toString(),
        UpdateDTim: (data["UpdateDTim"]).toString(),
        IsActive: (data["IsActive"]).toString(),
        oriPREMCOL: (data["oriPREMCOL"]).toString(),
        MakenModel: (data["MakenModel"]).toString(),
        ExpiryDate: (data["ExpiryDate"]).toString(),
        CallBackDate: (data["CallBackDate"]).toString(),
        InfectionID: (data["InfectionID"]).toString(),
        TicketNo: (data["TicketNo"]).toString(),
        QuoteNo: (data["QuoteNo"]).toString(),
        LcReason: (data["LcReason"]).toString(),
        LcSubReason: (data["LcSubReason"]).toString(),
        Age: (data["Age"]).toString(),
        RtoLoc: (data["RtoLoc"]).toString(),
        Price: (data["Price"]).toString(),
        YOM: (data["YOM"]).toString(),
        PED: (data["PED"]).toString(),
        Feature: (data["Feature"]).toString(),
        Area: (data["Area"]).toString(),
        PHC_NO: (data["PHC_NO"]).toString(),
        ProductType: (data["ProductType"]).toString(),
        Lan: (data["Lan"]).toString(),
        PostPQuery: (data["PostPQuery"]).toString(),
        NotEligible: (data["NotEligible"]).toString(),
        Reason: (data["Reason"]).toString(),
        RsReason: (data["RsReason"]).toString(),
        ModelValue: (data["ModelValue"]).toString(),
        NonContactableDtm: (data["NonContactableDtm"]).toString(),
        CallBackDateRenewal: (data["CallBackDateRenewal"]).toString(),
        NonConRes: (data["NonConRes"]).toString(),
        ChequeNo: (data["ChequeNo"]).toString(),
        ChequeDate: (data["ChequeDate"]).toString(),
        ChequeBankName: (data["ChequeBankName"]).toString(),
        RegistrationNo: (data["RegistrationNo"]).toString(),
        RenewalLeadLostReason: (data["RenewalLeadLostReason"]).toString(),
        PolicyAlreadyRenewedReason: (data["PolicyAlreadyRenewedReason"]).toString(),
        ParkedLeadDateTime: (data["ParkedLeadDateTime"]).toString(),
        FollowupDt: (data["FollowupDt"]).toString(),
        QutationDt: (data["QutationDt"]).toString(),
        ddlAct16Subreason: (data["ddlAct16Subreason"]).toString(),
        txt416: (data["txt416"]).toString(),
        txtAD16: (data["txtAD16"]).toString(),
        txtPN16: (data["txtPN16"]).toString(),
        txt316: (data["txt316"]).toString(),
        ddlMakeModel516: (data["ddlMakeModel516"]).toString(),
        ddlModel616: (data["ddlModel616"]).toString(),
        txt716: (data["txt716"]).toString(),
        txt816: (data["txt816"]).toString(),
        ddlAppReasonTrack5: (data["ddlAppReasonTrack5"]).toString(),
        ddlSubReason: (data["ddlSubReason"]).toString(),
        txtDuplicateLeadId: (data["txtDuplicateLeadId"]).toString(),
        ddlCompetitorList: (data["ddlCompetitorList"]).toString(),
        txtLocationDtls: (data["txtLocationDtls"]).toString(),
        txtTctNoact5: (data["txtTctNoact5"]).toString(),
        txtAge: (data["txtAge"]).toString(),
        txtArea2: (data["txtArea2"]).toString(),
        ddlRTOLoc: (data["ddlRTOLoc"]).toString(),
        txtPhcNo: (data["txtPhcNo"]).toString(),
        txtPrice: (data["txtPrice"]).toString(),
        txtPrdType: (data["txtPrdType"]).toString(),
        txtYOM: (data["txtYOM"]).toString(),
        txtPed2: (data["txtPed2"]).toString(),
        txtLanguage: (data["txtLanguage"]).toString(),
        ddlMakeModelact5: (data["ddlMakeModelact5"]).toString(),
        txtReason5: (data["txtReason5"]).toString(),
        txtCallBakDateTime19: (data["txtCallBakDateTime19"]).toString(),
        txtPN19: (data["txtPN19"]).toString(),
        txt319: (data["txt319"]).toString(),
        txtRMSAppointmentDate: (data["txtRMSAppointmentDate"]).toString(),
        txtRMSCallBackDate: (data["txtRMSCallBackDate"]).toString(),
        ddlRMSNonContactableReason: (data["ddlRMSNonContactableReason"]).toString(),
        txtRMSChequeNo: (data["txtRMSChequeNo"]).toString(),
        ddlRMSRenewalLeadLostReason: (data["ddlRMSRenewalLeadLostReason"]).toString(),
        ddlRMSPolicyAlreadyRenewedReason:
            (data["ddlRMSPolicyAlreadyRenewedReason"]).toString(),
        txtRMSMobileNo: (data["txtRMSMobileNo"]).toString(),
        txtAppointmentDate27: (data["txtAppointmentDate27"]).toString(),
        txtRescheduletDate28: (data["txtRescheduletDate28"]).toString(),
        ddlAppReasonTrack29: (data["ddlAppReasonTrack29"]).toString(),
        txtPolicyNo30: (data["txtPolicyNo30"]).toString(),
        txtParkedLead31: (data["txtParkedLead31"]).toString(),
        txtFollowup32: (data["txtFollowup32"]).toString(),
        txtQutation33: (data["txtQutation33"]).toString(),
        internalcomment: (data["internalcomment"]).toString(),
        InstType: (data["InstType"]).toString(),
        LstComDueTo: (data["LstComDueTo"]).toString(),
        NewPolEndDate: (data["NewPolEndDate"]).toString(),
        Remark: (data["Remark"]).toString(),
        // CallerId: StaticVariables.callerId,
        // CallerPass: StaticVariables.callerPass,
        // TokenId: StaticVariables.TokenId,
      );

      final responseString = await EncryptedHttpservice.post(
        url: "${StaticVariables.baseUrl}/${StaticVariables.UpdateActivity}",
        requestJson: requestJson,
      );
      final response = jsonDecode(responseString);

  print(requestJson);
      return response;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
