// class FilterState {
//   final String? period;
//   final String? branch;
//   final List<String> zones;
//   final List<String> regions;

//   const FilterState({
//     this.period,
//     this.branch,
//     this.zones = const [],
//     this.regions = const [],
//   });

//   FilterState copyWith({
//     String? period,
//     String? branch,
//     List<String>? zones,
//     List<String>? regions,
//   }) {
//     return FilterState(
//       period: period ?? this.period,
//       branch: branch ?? this.branch,
//       zones: zones ?? this.zones,
//       regions: regions ?? this.regions,
//     );
//   }
// }

class FilterState {
  final List<String> period;
  final List<String> reportingManager;
  final List<String> salesManager;
  final List<String> zone;
  final List<String> region;
  final List<String> branch;
  final List<String> agent;
  final List<String> reference;
  final List<String> lob;
  final List<String> productGroup;
  final List<String> product;
  final List<String> productSubCategory;
  final List<String> renewalYearCount;
  final List<String> ncb;
  final List<String> preferred;

  final String? nilDep;
  final String? categoryName;
  final String? mopedType;
  final String? gvw;
  final String? fuelType;
  final String? make;
  final String? vehicleAgeGrp;
  final String? vehicleType;
  final String? seatingCapacity;
  final String? ageGroup;
  final String? familySize;
  final String? sumInsuredBand;
  final String? preExisting;
  final String? occupancy;
  final String? sumInsured;
  final String? lifeGroup;

  const FilterState({
    this.period = const [],
    this.reportingManager = const [],
    this.salesManager = const [],
    this.zone = const [],
    this.region = const [],
    this.branch = const [],
    this.agent = const [],
    this.reference = const [],
    this.lob = const [],
    this.productGroup = const [],
    this.product = const [],
    this.productSubCategory = const [],
    this.renewalYearCount = const [],
    this.ncb = const [],
    this.preferred = const [],
    this.nilDep,
    this.categoryName,
    this.mopedType,
    this.gvw,
    this.fuelType,
    this.make,
    this.vehicleAgeGrp,
    this.vehicleType,
    this.seatingCapacity,
    this.ageGroup,
    this.familySize,
    this.sumInsuredBand,
    this.preExisting,
    this.occupancy,
    this.sumInsured,
    this.lifeGroup,
  });

  FilterState copyWith({
    List<String>? period,
    List<String>? reportingManager,
    List<String>? salesManager,
    List<String>? zone,
    List<String>? region,
    List<String>? branch,
    List<String>? agent,
    List<String>? reference,
    List<String>? lob,
    List<String>? productGroup,
    List<String>? product,
    List<String>? productSubCategory,
    List<String>? renewalYearCount,
    List<String>? ncb,
    List<String>? preferred,
    String? nilDep,
    String? categoryName,
    String? mopedType,
    String? gvw,
    String? fuelType,
    String? make,
    String? vehicleAgeGrp,
    String? vehicleType,
    String? seatingCapacity,
    String? ageGroup,
    String? familySize,
    String? sumInsuredBand,
    String? preExisting,
    String? occupancy,
    String? sumInsured,
    String? lifeGroup,
  }) {
    return FilterState(
      period: period ?? this.period,
      reportingManager: reportingManager ?? this.reportingManager,
      salesManager: salesManager ?? this.salesManager,
      zone: zone ?? this.zone,
      region: region ?? this.region,
      branch: branch ?? this.branch,
      agent: agent ?? this.agent,
      reference: reference ?? this.reference,
      lob: lob ?? this.lob,
      productGroup: productGroup ?? this.productGroup,
      product: product ?? this.product,
      productSubCategory: productSubCategory ?? this.productSubCategory,
      renewalYearCount: renewalYearCount ?? this.renewalYearCount,
      ncb: ncb ?? this.ncb,
      preferred: preferred ?? this.preferred,
      nilDep: nilDep ?? this.nilDep,
      categoryName: categoryName ?? this.categoryName,
      mopedType: mopedType ?? this.mopedType,
      gvw: gvw ?? this.gvw,
      fuelType: fuelType ?? this.fuelType,
      make: make ?? this.make,
      vehicleAgeGrp: vehicleAgeGrp ?? this.vehicleAgeGrp,
      vehicleType: vehicleType ?? this.vehicleType,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      ageGroup: ageGroup ?? this.ageGroup,
      familySize: familySize ?? this.familySize,
      sumInsuredBand: sumInsuredBand ?? this.sumInsuredBand,
      preExisting: preExisting ?? this.preExisting,
      occupancy: occupancy ?? this.occupancy,
      sumInsured: sumInsured ?? this.sumInsured,
      lifeGroup: lifeGroup ?? this.lifeGroup,
    );
  }
}