class LeadCardModel {
  final String customerName;
  final String leadId;
  final String product;
  final String premium;
  final String policyNumber;
  final String ncb;
  final String vehicleModel;
  final String lastActivity;
  final String dateTime;
  final String paymentLink;

  const LeadCardModel({
    required this.customerName,
    required this.leadId,
    required this.product,
    required this.premium,
    required this.policyNumber,
    required this.ncb,
    required this.vehicleModel,
    required this.lastActivity,
    required this.dateTime,
    required this.paymentLink,
  });

  factory LeadCardModel.fromMap(
    Map<String, dynamic> map, {
    String? activityDescription,
  }) {
    String value(String key) {
      final result = map[key]?.toString().trim();

      if (result == null || result.isEmpty || result.toLowerCase() == 'null') {
        return 'Not Available';
      }

      return result;
    }

    final make = value('Make');
    final model = value('Model');

    String vehicleModel;

    if (make == 'Not Available' && model == 'Not Available') {
      vehicleModel = 'Not Available';
    } else if (make == 'Not Available') {
      vehicleModel = model;
    } else if (model == 'Not Available') {
      vehicleModel = make;
    } else {
      vehicleModel = '$make & $model';
    }

    final activityDesc = activityDescription?.trim();

    return LeadCardModel(
      customerName: value('Name'),
      leadId: value('SrvcReqDtlCode'),
      product: value('ProdName'),
      premium: value('InstallmentPrem'),
      policyNumber: value('PolicyNo'),
      ncb: value('PolNCB'),
      vehicleModel: vehicleModel,
      lastActivity: activityDesc != null && activityDesc.isNotEmpty
          ? activityDesc
          : value('ActivityStatus'),
      dateTime: value('SrvcFromDTim'),
      paymentLink: value('RenewalPaymentLink'),
    );
  }
}
