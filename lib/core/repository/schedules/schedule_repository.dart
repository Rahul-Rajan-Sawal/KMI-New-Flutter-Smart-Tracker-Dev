import 'package:flutter_bottom_nav/core/apicall/async_get_all_lead_data.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ScheduleRepository {
  /// 1. CHECK DB
  /// 2. IF DATA EXISTS -> RETURN DB DATA
  /// 3. ELSE CALL API
  /// 4. SAVE API DATA INTO DB
  /// 5. RETURN API DATA
  ///
  Future<List<Map<String, dynamic>>> getUpcomingLeads() async {
    try {
      final db = await DatabaseHelper.instance.database;

      /// CHECK LOCAL DB

      final localData = await db.query(
        "LeadDetails",
        where: "UserId = ?",
        whereArgs: [StaticVariables.mSAPCode],
      );

      /// RETURN DB DATA

      if (localData.isNotEmpty) {
        print("DATA LOADED FROM DB");

        return localData;
      }

      /// CALL API

      print("DB EMPTY -> CALLING API");

      final response = await GetAllAssignedLeads(
        sapCode: StaticVariables.mSAPCode,
        CurMonth: "01-05-2026",
        lastSyncDate: "",
      );

      List<dynamic> apiData = response["Table"] ?? [];

      if (apiData.isEmpty) {
        return [];
      }

      /// SAVE DATA

      await saveLeadData(apiData);

      /// RETURN MEMORY LIST

      return List<Map<String, dynamic>>.from(apiData);
    } catch (e) {
      print("GET UPCOMING ERROR : $e");

      return [];
    }
  }

  /// SAVE API DATA

  Future<void> saveLeadData(List<dynamic> apiData) async {
    try {
      final db = await DatabaseHelper.instance.database;

      /// TRANSACTION START

      await db.transaction((txn) async {
        Batch batch = txn.batch();

        /// DELETE OLD DATA

        await txn.delete(
          "LeadDetails",
          where: "UserId = ?",
          whereArgs: [StaticVariables.mSAPCode],
        );

        await txn.delete("LMSLeadActivityTracker");

        /// LOOP API DATA

        for (var item in apiData) {
          /// LEAD DETAILS MAP
          final leadMap = <String, dynamic>{
            "SrvcReqDtlCode": item["SrvcReqDtlCode"],
            "SrvcGrpCode": item["SrvcGrpCode"],
            "CltCode": item["CltCode"],
            "AgentCode": item["AgentCode"],
            "UserId": StaticVariables.mSAPCode,
            "ReqChannelId": item["ReqChannelId"],
            "ReqChannel": item["ReqChannel"],
            "LOBCode": item["LOBCode"],
            "LOB": item["LOB"],
            "ProdCode": item["ProdCode"],
            "ProdName": item["ProdName"],
            "CRMStatus": item["CRMStatus"],
            "LMSStatusDesc": item["LMSStatusDesc"],
            "WFStatus": item["WFStatus"],
            "WFStatDesc": item["WFStatDesc"],
            "LeadSource": item["LeadSource"],
            "LeadSourceDesc": item["LeadSourceDesc"],
            "LeadSubSource": item["LeadSubSource"],
            "LeadSubSourceDesc": item["LeadSubSourceDesc"],
            "BusinessType": item["BusinessType"],
            "BusinessTypeDesc": item["BusinessTypeDesc"],
            "LeadQueue": item["LeadQueue"],
            "LeadQueueDesc": item["LeadQueueDesc"],
            "leadAmt": item["leadAmt"],
            "TypeFlag": item["TypeFlag"],
            "LeadTypeDesc": item["LeadTypeDesc"],
            "LeadStatusCode": item["LeadStatusCode"],
            "ActivityStatus": item["ActivityStatus"],
            "CustPriority": item["CustPriority"],
            "CustPriorityDesc": item["CustPriorityDesc"],
            "SaleType": item["SaleType"],
            "SaleTypeDesc": item["SaleTypeDesc"],
            "CreatedBy": item["CreatedBy"],
            "CreateDTim": item["CreateDTim"],
            "UpdatedBy": item["UpdatedBy"],
            "UpdateDTim": item["UpdateDTim"],
            "Remark": item["Remark"],
            "ProposalNo": item["ProposalNo"],
            "PolicyNo": item["PolicyNo"],
            "PolicyStatus": item["PolicyStatus"],
            "PolicyStartDate": item["PolicyStartDate"],
            "PolicyEndDate": item["PolicyEndDate"],
            "IssBranchCode": item["IssBranchCode"],
            "IssBranchName": item["IssBranchName"],
            "InstallmentPrem": item["InstallmentPrem"],
            "PrevPolicyNo": item["PrevPolicyNo"],
            "PrevPolicyInsCompName": item["PrevPolicyInsCompName"],
            "ProdClassCode": item["ProdClassCode"],
            "ProdClassName": item["ProdClassName"],
            "ChassisNo": item["ChassisNo"],
            "EngineNo": item["EngineNo"],
            "RegistrationNo": item["RegistrationNo"],
            "Make": item["Make"],
            "Model": item["Model"],
            "PlanName": item["PlanName"],
            "AgentName": item["AgentName"],
            "HNINCode": item["HNINCode"],
            "HNINName": item["HNINName"],
            "PolNCB": item["PolNCB"],
            "Name": item["Name"],
            "MobileTel": item["MobileTel"],
            "WorkTel": item["WorkTel"],
            "Email": item["Email"],
            "AddrType": item["AddrType"],
            "Addr1": item["Addr1"],
            "Addr2": item["Addr2"],
            "Addr3": item["Addr3"],
            "CityCode": item["CityCode"],
            "DistrictCode": item["DistrictCode"],
            "StateCode": item["StateCode"],
            "PinCode": item["PinCode"],
            "CountryCode": item["CountryCode"],
            "Area": item["Area"],
            "isWarmTransfer": item["isWarmTransfer"],
            "SrvcCommentType": item["SrvcCommentType"],
            "SrvcComments": item["SrvcComments"],
            "SrvcFromDTim": item["SrvcFromDTim"],
            "Breaking": item["Breaking"],
            "LeadRating": item["LeadRating"],
            "isOwner": item["isOwner"],
            "OwnerName": item["OwnerName"],
            "AssignedTo": item["AssignedTo"],
            "AssignedToName": item["AssignedToName"],
            "CustTypeDesc": item["CustTypeDesc"],
            "LeadAging": item["LeadAging"],
            "TelesaleActivity": item["TelesaleActivity"],
            "TelesaleActivityDoneBy": item["TelesaleActivityDoneBy"],
            "TelesaleActivityDate": item["TelesaleActivityDate"],
            "TelesaleRemark": item["TelesaleRemark"],
            "LeadType": item["LeadType"],
            "BizType": item["BizType"],
            "MarcketType": item["MarcketType"],
            "PolicyChanel": item["PolicyChanel"],
            "BMCMCode": item["BMCMCode"],
            "ircCode": item["ircCode"],
            "ircname": item["ircname"],
            "RNType": item["RNType"],
            "NetODPremium": item["NetODPremium"],
            "NetTPPremium": item["NetTPPremium"],
            "RNblockReason": item["RNblockReason"],
            "ProductGroup": item["ProductGroup"],
            "ProductSubCategory": item["ProductSubCategory"],
            "NILDep": item["NILDep"],
            "Category": item["Category"],
            "FuelType": item["FuelType"],
            "VehicleType": item["VehicleType"],
            "SeatingCapacity": item["SeatingCapacity"],
            "AgeGroup": item["AgeGroup"],
            "FamilySize": item["FamilySize"],
            "SumInsuredBand": item["SumInsuredBand"],
            "PreExiting": item["PreExiting"],
            "Occupancy": item["Occupancy"],
            "LifeGroup": item["LifeGroup"],
            "Zone": item["Zone"],
            "Region": item["Region"],
            "RenewalYearCount": item["RenewalYearCount"],
            "Preferred": item["Preferred"],
            "Activity": item["Activity"],
            "SubActivity": item["SubActivity"],
            "Amount": item["Amount"],
            "SMName": item["SMName"],
            "SMBranch": item["SMBranch"],
            "SMBranchName": item["SMBranchName"],
            "NCBFlag": item["NCBFlag"],
            "RenewalPaymentLink": item["RenewalPaymentLink"],
            "SyncStatus": "Complete",
          };

          /// TRACKER MAP

          final trackerMap = <String, dynamic>{
            "CltCode": item["CltCode"],
            "SrvcReqDtlCode": item["SrvcReqDtlCode"],
            "ActivityCode": item["ActivityCode"],
            "SubActivityCode": item["SubActivityCode"],
            "AppointmentDate": item["AppointmentDate"],
            "Hour": item["Hour"],
            "Minute": item["Minute"],
            "AppointmentAddrss": item["AppointmentAddrss"],
            "AppThrough": item["AppThrough"],
            "ResThrough": item["ResThrough"],
            "RescheduleDate": item["RescheduleDate"],
            "RescheduleAddrss": item["RescheduleAddrss"],
            "ParkedLead": item["ParkedLead"],
            "ProposalNo": item["ProposalNo"],
            "IssuedPolicyNo": item["IssuedPolicyNo"],
            "PremiumCollected": item["PremiumCollected"],
            "AppReason": item["AppReason"],
            "SubReason": item["SubReason"],
            "DuplicateLeadId": item["DuplicateLeadId"],
            "ComptitorID": item["ComptitorID"],
            "LocationDtls": item["LocationDtls"],
            "NonContble": item["NonContble"],
            "NotIntrest": item["NotIntrest"],
            "PhoneNumber": item["PhoneNumber"],
            "CreateBy": item["CreateBy"],
            "CreateDTim": item["CreateDTim"],
            "UpdateBy": item["UpdateBy"],
            "UpdateDTim": item["UpdateDTim"],
            "MakenModel": item["MakenModel"],
            "ExpiryDate": item["ExpiryDate"],
            "CallBackDate": item["CallBackDate"],
            "InfectionID": item["InfectionID"],
            "TicketNo": item["TicketNo"],
            "QuoteNo": item["QuoteNo"],
            "LcReason": item["LcReason"],
            "LcSubReason": item["LcSubReason"],
            "Age": item["Age"],
            "RtoLoc": item["RtoLoc"],
            "Price": item["Price"],
            "YOM": item["YOM"],
            "PED": item["PED"],
            "Feature": item["Feature"],
            "Area": item["Area"],
            "PHC_NO": item["PHC_NO"],
            "ProductType": item["ProductType"],
            "Lan": item["Lan"],
            "PostPQuery": item["PostPQuery"],
            "NotEligible": item["NotEligible"],
            "Reason": item["Reason"],
            "RsReason": item["RsReason"],
            "ModelValue": item["ModelValue"],
            "NonContactableDtm": item["NonContactableDtm"],
            "CallBackDateRenewal": item["CallBackDateRenewal"],
            "NonConRes": item["NonConRes"],
            "ChequeNo": item["ChequeNo"],
            "ChequeDate": item["ChequeDate"],
            "ChequeBankName": item["ChequeBankName"],
            "RegistrationNo": item["RegistrationNo"],
            "RenewalLeadLostReason": item["RenewalLeadLostReason"],
            "PolicyAlreadyRenewedReason": item["PolicyAlreadyRenewedReason"],
            "ParkedLeadDateTime": item["ParkedLeadDateTime"],
            "FollowupDt": item["FollowupDt"],
            "QutationDt": item["QutationDt"],
            "InstType": item["InstType"],
            "LstComDueTo": item["LstComDueTo"],
            "NewPolEndDate": item["NewPolEndDate"],
            "Remark": item["TrackerRemark"],
            "SyncStatus": "Complete",
          };

          /// INSERT LEAD DETAILS

          batch.insert(
            "LeadDetails",
            leadMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          /// INSERT TRACKER TABLE

          batch.insert(
            "LMSLeadActivityTracker",
            trackerMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        /// COMMIT BATCH

        await batch.commit(noResult: true);

        print("BATCH INSERT SUCCESS");
      });

      print("TRANSACTION SUCCESS");
    } catch (e) {
      print("SAVE ERROR : $e");
    }
  }

  /// REFRESH API

  Future<List<Map<String, dynamic>>> refreshLeads({
    required String sapCode,
  }) async {
    try {
      final response = await GetAllAssignedLeads(
        sapCode: StaticVariables.mSAPCode,
        CurMonth: "01-05-2026",
        lastSyncDate: "",
      );

      List<dynamic> apiData = response["Table"] ?? [];

      await saveLeadData(apiData);

      return List<Map<String, dynamic>>.from(apiData);
    } catch (e) {
      print("REFRESH ERROR : $e");

      return [];
    }
  }
}
