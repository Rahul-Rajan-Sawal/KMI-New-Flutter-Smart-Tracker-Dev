class CalendarDataModel {
  final String? responseCode;
  final String? message;
  final String? userId;
  final String? agentCode;
  final String? agentName;
  final String? hninCode;
  final String? hninName;
  final String? lobCode;
  final String? prodCode;
  final String? ncbFlag;
  final String? date;
  final String? totalLeads;
  final String? wipLeads;
  final String? leadConverted;
  final String? leadLost;
  final String? leadType;
  final String? bizType;
  final String? marcketType;
  final String? policyChanel;
  final String? bmcmCode;
  final String? ircCode;
  final String? ircname;
  final String? rnType;
  final String? netODPremium;
  final String? netTPPremium;
  final String? rnblockReason;
  final String? productGroup;
  final String? productSubCategory;
  final String? nilDep;
  final String? category;
  final String? fuelType;
  final String? vehicleType;
  final String? seatingCapacity;
  final String? ageGroup;
  final String? familySize;
  final String? sumInsuredBand;
  final String? preExiting;
  final String? occupancy;
  final String? sumInsured;
  final String? lifeGroup;
  final String? zone;
  final String? region;
  final String? renewalYearCount;
  final String? preferred;
  final String? smName;
  final String? smBranch;
  final String? smBranchName;
  final String? createdBy;
  final String? createDTime;
  final String? updatedBy;
  final String? updatedDtime;
  final String? mdate;

  CalendarDataModel({
    this.responseCode,
    this.message,
    this.userId,
    this.agentCode,
    this.agentName,
    this.hninCode,
    this.hninName,
    this.lobCode,
    this.prodCode,
    this.ncbFlag,
    this.date,
    this.totalLeads,
    this.wipLeads,
    this.leadConverted,
    this.leadLost,
    this.leadType,
    this.bizType,
    this.marcketType,
    this.policyChanel,
    this.bmcmCode,
    this.ircCode,
    this.ircname,
    this.rnType,
    this.netODPremium,
    this.netTPPremium,
    this.rnblockReason,
    this.productGroup,
    this.productSubCategory,
    this.nilDep,
    this.category,
    this.fuelType,
    this.vehicleType,
    this.seatingCapacity,
    this.ageGroup,
    this.familySize,
    this.sumInsuredBand,
    this.preExiting,
    this.occupancy,
    this.sumInsured,
    this.lifeGroup,
    this.zone,
    this.region,
    this.renewalYearCount,
    this.preferred,
    this.smName,
    this.smBranch,
    this.smBranchName,
    this.createdBy,
    this.createDTime,
    this.updatedBy,
    this.updatedDtime,
    this.mdate,
  });

  factory CalendarDataModel.fromJson(Map<String, dynamic> json) {
    return CalendarDataModel(
      responseCode: json['ResponseCode']?.toString(),
      message: json['Message']?.toString(),
      userId: json['UserId']?.toString(),
      agentCode: json['AgentCode']?.toString(),
      agentName: json['AgentName']?.toString(),
      hninCode: json['HNINCode']?.toString(),
      hninName: json['HNINName']?.toString(),
      lobCode: json['LOBCode']?.toString(),
      prodCode: json['ProdCode']?.toString(),
      ncbFlag: json['NCBFlag']?.toString(),
      date: json['date']?.toString(),
      totalLeads: json['TotalLeads']?.toString(),
      wipLeads: json['WIPLeads']?.toString(),
      leadConverted: json['LeadConverted']?.toString(),
      leadLost: json['LeadLost']?.toString(),
      leadType: json['LeadType']?.toString(),
      bizType: json['BizType']?.toString(),
      marcketType: json['MarcketType']?.toString(),
      policyChanel: json['PolicyChanel']?.toString(),
      bmcmCode: json['BMCMCode']?.toString(),
      ircCode: json['ircCode']?.toString(),
      ircname: json['ircname']?.toString(),
      rnType: json['RNType']?.toString(),
      netODPremium: json['NetODPremium']?.toString(),
      netTPPremium: json['NetTPPremium']?.toString(),
      rnblockReason: json['RNblockReason']?.toString(),
      productGroup: json['ProductGroup']?.toString(),
      productSubCategory: json['ProductSubCategory']?.toString(),
      nilDep: json['NILDep']?.toString(),
      category: json['Category']?.toString(),
      fuelType: json['FuelType']?.toString(),
      vehicleType: json['VehicleType']?.toString(),
      seatingCapacity: json['SeatingCapacity']?.toString(),
      ageGroup: json['AgeGroup']?.toString(),
      familySize: json['FamilySize']?.toString(),
      sumInsuredBand: json['SumInsuredBand']?.toString(),
      preExiting: json['PreExiting']?.toString(),
      occupancy: json['Occupancy']?.toString(),
      sumInsured: json['SumInsured']?.toString(),
      lifeGroup: json['LifeGroup']?.toString(),
      zone: json['Zone']?.toString(),
      region: json['Region']?.toString(),
      renewalYearCount: json['RenewalYearCount']?.toString(),
      preferred: json['Preferred']?.toString(),
      smName: json['SMName']?.toString(),
      smBranch: json['SMBranch']?.toString(),
      smBranchName: json['SMBranchName']?.toString(),
      createdBy: json['CreatedBy']?.toString(),
      createDTime: json['CreateDTime']?.toString(),
      updatedBy: json['UpdatedBy']?.toString(),
      updatedDtime: json['UpdatedDtime']?.toString(),
      mdate: json['mdate']?.toString(),
    );
  }
}
