import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/common/encryption_util.dart';

class ActivityRepository {
  // static String _getDecrypted(Map<String, dynamic> row, String key) {
  //   return EncryptionUtil.decrypt(row[key]?.toString() ?? "");
  // }

  //   static String _getDecrypted(Map<String, dynamic> row, String key) {
  //   if (!row.containsKey(key)) {
  //     throw Exception("❌ Column missing in DB: $key");
  //   }
  //   return EncryptionUtil.decrypt(row[key]?.toString() ?? "");
  // }

  static String _getDecrypted(Map<String, dynamic> row, String key) {
    if (!row.containsKey(key)) {
      return '';
    }

    final value = row[key]?.toString() ?? '';

    if (value.isEmpty) {
      return '';
    }

    try {
      return EncryptionUtil.decrypt(value) ?? '';
    } catch (e) {
      print('Unable to decrypt $key: $e');
      return '';
    }
  }

  static Future<Map<String, dynamic>?> getActivityData(
    String srvcReqDtlCode,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;

      String enSrvcReqDtlCode = EncryptionUtil.encrypt(srvcReqDtlCode);
      String enSyncStatus = EncryptionUtil.encrypt("Pending");

      final result = await db.query(
        "LMSLeadActivityTracker",
        where: "SrvcReqDtlCode=? AND SyncStatus=?",
        whereArgs: [enSrvcReqDtlCode, enSyncStatus],
        orderBy: "RecId DESC",
        limit: 1,
      );

      if (result.isEmpty) return null;

      final row = result.first;

      return {
        "CltCode": _getDecrypted(row, "CltCode"),
        "SrvcReqDtlCode": _getDecrypted(row, "SrvcReqDtlCode"),
        "ActivityCode": _getDecrypted(row, "ActivityCode"),
        "SubActivityCode": _getDecrypted(row, "SubActivityCode"),
        "AppointmentDate": _getDecrypted(row, "AppointmentDate"),
        "Hour": _getDecrypted(row, "Hour"),
        "Minute": _getDecrypted(row, "Minute"),
        "AppointmentAddrss": _getDecrypted(row, "AppointmentAddrss"),
        "AppThrough": _getDecrypted(row, "AppThrough"),
        "ResThrough": _getDecrypted(row, "ResThrough"),
        "RescheduleDate": _getDecrypted(row, "RescheduleDate"),
        "RescheduleAddrss": _getDecrypted(row, "RescheduleAddrss"),
        "ParkedLead": _getDecrypted(row, "ParkedLead"),
        "ProposalNo": _getDecrypted(row, "ProposalNo"),
        "IssuedPolicyNo": _getDecrypted(row, "IssuedPolicyNo"),
        "PremiumCollected": _getDecrypted(row, "PremiumCollected"),
        "AppReason": _getDecrypted(row, "AppReason"),
        "SubReason": _getDecrypted(row, "SubReason"),
        "DuplicateLeadId": _getDecrypted(row, "DuplicateLeadId"),
        "ComptitorID": _getDecrypted(row, "ComptitorID"),
        "LocationDtls": _getDecrypted(row, "LocationDtls"),
        "NonContble": _getDecrypted(row, "NonContble"),
        "NotIntrest": _getDecrypted(row, "NotIntrest"),
        "PhoneNumber": _getDecrypted(row, "PhoneNumber"),
        "CreateBy": _getDecrypted(row, "CreateBy"),
        "CreateDTim": _getDecrypted(row, "CreateDTim"),
        "UpdateBy": _getDecrypted(row, "UpdateBy"),
        "UpdateDTim": _getDecrypted(row, "UpdateDTim"),
        "IsActive": _getDecrypted(row, "IsActive"),
        "oriPREMCOL": _getDecrypted(row, "oriPREMCOL"),
        "MakenModel": _getDecrypted(row, "MakenModel"),
        "ExpiryDate": _getDecrypted(row, "ExpiryDate"),
        "CallBackDate": _getDecrypted(row, "CallBackDate"),
        "InfectionID": _getDecrypted(row, "InfectionID"),
        "TicketNo": _getDecrypted(row, "TicketNo"),
        "QuoteNo": _getDecrypted(row, "QuoteNo"),
        "LcReason": _getDecrypted(row, "LcReason"),
        "LcSubReason": _getDecrypted(row, "LcSubReason"),
        "Age": _getDecrypted(row, "Age"),
        "RtoLoc": _getDecrypted(row, "RtoLoc"),
        "Price": _getDecrypted(row, "Price"),
        "YOM": _getDecrypted(row, "YOM"),
        "PED": _getDecrypted(row, "PED"),
        "Feature": _getDecrypted(row, "Feature"),
        "Area": _getDecrypted(row, "Area"),
        "PHC_NO": _getDecrypted(row, "PHC_NO"),
        "ProductType": _getDecrypted(row, "ProductType"),
        "Lan": _getDecrypted(row, "Lan"),
        "PostPQuery": _getDecrypted(row, "PostPQuery"),
        "NotEligible": _getDecrypted(row, "NotEligible"),
        "Reason": _getDecrypted(row, "Reason"),
        "RsReason": _getDecrypted(row, "RsReason"),
        "ModelValue": _getDecrypted(row, "ModelValue"),
        "NonContactableDtm": _getDecrypted(row, "NonContactableDtm"),
        "CallBackDateRenewal": _getDecrypted(row, "CallBackDateRenewal"),
        "NonConRes": _getDecrypted(row, "NonConRes"),
        "ChequeNo": _getDecrypted(row, "ChequeNo"),
        "ChequeDate": _getDecrypted(row, "ChequeDate"),
        "ChequeBankName": _getDecrypted(row, "ChequeBankName"),
        "RegistrationNo": _getDecrypted(row, "RegistrationNo"),
        "RenewalLeadLostReason": _getDecrypted(row, "RenewalLeadLostReason"),
        "PolicyAlreadyRenewedReason": _getDecrypted(
          row,
          "PolicyAlreadyRenewedReason",
        ),
        "ParkedLeadDateTime": _getDecrypted(row, "ParkedLeadDateTime"),
        "FollowupDt": _getDecrypted(row, "FollowupDt"),
        "QutationDt": _getDecrypted(row, "QutationDt"),
        "ddlAct16Subreason": _getDecrypted(row, "ddlAct16Subreason"),
        "txt416": _getDecrypted(row, "txt416"),
        "txtAD16": _getDecrypted(row, "txtAD16"),
        "txtPN16": _getDecrypted(row, "txtPN16"),
        "txt316": _getDecrypted(row, "txt316"),
        "ddlMakeModel516": _getDecrypted(row, "ddlMakeModel516"),
        "ddlModel616": _getDecrypted(row, "ddlModel616"),
        "txt716": _getDecrypted(row, "txt716"),
        "txt816": _getDecrypted(row, "txt816"),
        "ddlAppReasonTrack5": _getDecrypted(row, "ddlAppReasonTrack5"),
        "ddlSubReason": _getDecrypted(row, "ddlSubReason"),
        "txtDuplicateLeadId": _getDecrypted(row, "txtDuplicateLeadId"),
        "ddlCompetitorList": _getDecrypted(row, "ddlCompetitorList"),
        "txtLocationDtls": _getDecrypted(row, "txtLocationDtls"),
        "txtTctNoact5": _getDecrypted(row, "txtTctNoact5"),
        "txtAge": _getDecrypted(row, "txtAge"),
        "txtArea2": _getDecrypted(row, "txtArea2"),
        "ddlRTOLoc": _getDecrypted(row, "ddlRTOLoc"),
        "txtPhcNo": _getDecrypted(row, "txtPhcNo"),
        "txtPrice": _getDecrypted(row, "txtPrice"),
        "txtPrdType": _getDecrypted(row, "txtPrdType"),
        "txtYOM": _getDecrypted(row, "txtYOM"),
        "txtPed2": _getDecrypted(row, "txtPed2"),
        "txtLanguage": _getDecrypted(row, "txtLanguage"),
        "ddlMakeModelact5": _getDecrypted(row, "ddlMakeModelact5"),
        "txtReason5": _getDecrypted(row, "txtReason5"),
        "txtCallBakDateTime19": _getDecrypted(row, "txtCallBakDateTime19"),
        "txtPN19": _getDecrypted(row, "txtPN19"),
        "txt319": _getDecrypted(row, "txt319"),
        "txtRMSAppointmentDate": _getDecrypted(row, "txtRMSAppointmentDate"),
        "txtRMSCallBackDate": _getDecrypted(row, "txtRMSCallBackDate"),
        "ddlRMSNonContactableReason": _getDecrypted(
          row,
          "ddlRMSNonContactableReason",
        ),
        "txtRMSChequeNo": _getDecrypted(row, "txtRMSChequeNo"),
        "ddlRMSRenewalLeadLostReason": _getDecrypted(
          row,
          "ddlRMSRenewalLeadLostReason",
        ),
        "ddlRMSPolicyAlreadyRenewedReason": _getDecrypted(
          row,
          "ddlRMSPolicyAlreadyRenewedReason",
        ),
        "txtRMSMobileNo": _getDecrypted(row, "txtRMSMobileNo"),
        "txtAppointmentDate27": _getDecrypted(row, "txtAppointmentDate27"),
        "txtRescheduletDate28": _getDecrypted(row, "txtRescheduletDate28"),
        "ddlAppReasonTrack29": _getDecrypted(row, "ddlAppReasonTrack29"),
        "txtPolicyNo30": _getDecrypted(row, "txtPolicyNo30"),
        "txtParkedLead31": _getDecrypted(row, "txtParkedLead31"),
        "txtFollowup32": _getDecrypted(row, "txtFollowup32"),
        "txtQutation33": _getDecrypted(row, "txtQutation33"),
        "internalcomment": _getDecrypted(row, "internalcomment"),
        "InstType": _getDecrypted(row, "InstType"),
        "LstComDueTo": _getDecrypted(row, "LstComDueTo"),
        "NewPolEndDate": _getDecrypted(row, "NewPolEndDate"),
        "Remark": _getDecrypted(row, "Remark"),
      };
    } catch (e) {
      print("Repository Error: $e");
      return null;
    }
  }
}
