import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bottom_nav/core/network/api_request_builder.dart';
import 'package:flutter_bottom_nav/core/network/encrypted_httpservice.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class GetTeamDashboardData {
  static Future<Map<String, dynamic>> getTeamDashboardData({
    required String UserId,
    required String Period,

    String Zone = "",
    String Region = "",
    String Branch = "",
    String SMCode = "",
    String Agent = "",
    String Reference = "",
    String Lob = "",
    String ProductGroup = "",
    String Product = "",
    String ProductSubCat = "",
    String RenewalYearCount = "",
    String NCB = "",
    String Prefered = "",
    String NilDep = "",
    String Category = "",
    String FuelType = "",
    String Make = "",
    String VehicleAgeGroup = "",
    String GVW = "",
    String VehicleType = "",
    String SeatingCapacity = "",
    String AgeGroup = "",
    String FamilySize = "",
    String SumInsuredBand = "",
    String PreExisting = "",
    String Occupancy = "",
    String SumInsured = "",
    String LifeGroup = "",
  }) async {
    final requestJson = ApiRequestBuilder.getTeamsDashboard(
      UserId: UserId,
      Period: Period,
      Zone: Zone,
      Region: Region,
      Branch: Branch,
      SMCode: SMCode,
      Agent: Agent,
      Reference: Reference,
      Lob: Lob,
      ProductGroup: ProductGroup,
      Product: Product,
      ProductSubCat: ProductSubCat,
      RenewalYearCount: RenewalYearCount,
      NCB: NCB,
      Prefered: Prefered,
      NilDep: NilDep,
      Category: Category,
      FuelType: FuelType,
      Make: Make,
      VehicleAgeGroup: VehicleAgeGroup,
      GVW: GVW,
      VehicleType: VehicleType,
      SeatingCapacity: SeatingCapacity,
      AgeGroup: AgeGroup,
      FamilySize: FamilySize,
      SumInsuredBand: SumInsuredBand,
      PreExisting: PreExisting,
      Occupancy: Occupancy,
      SumInsured: SumInsured,
      LifeGroup: LifeGroup,
      CallerId: StaticVariables.callerId,
      CallerPass: StaticVariables.callerPass!,
      TokenId: StaticVariables.TokenId,
    );

    debugPrint("========== GetTeamsDashboard REQUEST ==========");
    debugPrint(jsonEncode(requestJson));

    final String responseString = await EncryptedHttpservice.post(
      url: "${StaticVariables.baseUrl}/${StaticVariables.GetTeamsDashboard}",
      requestJson: requestJson,
    );

    debugPrint("========== GetTeamsDashboard RAW RESPONSE ==========");
    debugPrint(responseString);

    final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

    debugPrint("GetTeamsDashboard: $jsonResponse");

    return jsonResponse;
  }
}