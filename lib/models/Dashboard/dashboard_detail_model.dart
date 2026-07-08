import 'package:flutter_bottom_nav/common/common_util.dart';

class DashboardDetailModel {
  final String leadNo;
  final String policyNo;
  final String product;
  final String premium;

  DashboardDetailModel({
    required this.leadNo,
    required this.policyNo,
    required this.product,
    required this.premium,
  });

  factory DashboardDetailModel.fromDb(Map<String, dynamic> row) {
    String dec(dynamic value) {
      return CommonUtil.decryptIfNotEmpty(value?.toString() ?? "");
    }

    return DashboardDetailModel(
      // Kept plain in DB for navigation/query
      leadNo: (row['SrvcReqDtlCode'] ?? '').toString(),
      // These are encrypted while saving, so decrypt while showing
      policyNo: dec(row['PolicyNo']),
      product: dec(row['ProdName']),
      premium: dec(row['leadAmt'] ?? row['Amount'] ?? '0'),
    );
  }
}
