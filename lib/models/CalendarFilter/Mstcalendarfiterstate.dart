import 'package:flutter_bottom_nav/models/Calendar/filter_option.dart';

class CalMstFilterState {
  final bool isLoading;

  // Available options loaded from DB
  final List<FilterOption> zones;
  final List<FilterOption> regions;
  final List<FilterOption> branches;
  final List<FilterOption> salesManagers;
  final List<FilterOption> agents;
  final List<FilterOption> references;

  final List<FilterOption> lobs;
  final List<FilterOption> productGroups;
  final List<FilterOption> products;
  final List<FilterOption> productSubCategories;

  final Map<String, List<FilterOption>> lookupCache;

  final List<FilterOption> nilDepOptions;
  final List<FilterOption> categoryOptions;
  final List<FilterOption> mopedTypeOptions;
  final List<FilterOption> gvwOptions;
  final List<FilterOption> fuelTypeOptions;
  final List<FilterOption> makeOptions;
  final List<FilterOption> vehicleAgeGroupOptions;
  final List<FilterOption> seatingCapacityOptions;
  final List<FilterOption> ageGroupOptions;
  final List<FilterOption> familySizeOptions;
  final List<FilterOption> sumInsuredBandOptions;
  final List<FilterOption> preExistingOptions;
  final List<FilterOption> occupancyOptions;
  final List<FilterOption> sumInsuredOptions;
  final List<FilterOption> lifeGroupOptions;

  final List<FilterOption> renewalYearCounts;
  final List<FilterOption> ncbOptions;
  final List<FilterOption> preferredOptions;

  // Temporary selected options inside filter screen
  final List<FilterOption> selectedZones;
  final List<FilterOption> selectedRegions;
  final List<FilterOption> selectedBranches;
  final List<FilterOption> selectedSalesManagers;
  final List<FilterOption> selectedAgents;
  final List<FilterOption> selectedReferences;

  final List<FilterOption> selectedLobs;
  final List<FilterOption> selectedProductGroups;
  final List<FilterOption> selectedProducts;
  final List<FilterOption> selectedProductSubCategories;

  final List<FilterOption> selectedNilDep;
  final List<FilterOption> selectedCategory;
  final List<FilterOption> selectedMopedType;
  final List<FilterOption> selectedGvw;
  final List<FilterOption> selectedFuelType;
  final List<FilterOption> selectedMake;
  final List<FilterOption> selectedVehicleAgeGroup;
  final List<FilterOption> selectedSeatingCapacity;
  final List<FilterOption> selectedAgeGroup;
  final List<FilterOption> selectedFamilySize;
  final List<FilterOption> selectedSumInsuredBand;
  final List<FilterOption> selectedPreExisting;
  final List<FilterOption> selectedOccupancy;
  final List<FilterOption> selectedSumInsured;
  final List<FilterOption> selectedLifeGroup;

  final List<FilterOption> selectedRenewalYearCounts;
  final List<FilterOption> selectedNcb;
  final List<FilterOption> selectedPreferred;

  const CalMstFilterState({
    this.isLoading = false,
    this.zones = const [],
    this.regions = const [],
    this.branches = const [],
    this.salesManagers = const [],
    this.agents = const [],
    this.references = const [],
    this.lobs = const [],
    this.productGroups = const [],
    this.products = const [],
    this.productSubCategories = const [],
    this.renewalYearCounts = const [],
    this.ncbOptions = const [],
    this.preferredOptions = const [],
    this.selectedZones = const [],
    this.selectedRegions = const [],
    this.selectedBranches = const [],
    this.selectedSalesManagers = const [],
    this.selectedAgents = const [],
    this.selectedReferences = const [],
    this.selectedLobs = const [],
    this.selectedProductGroups = const [],
    this.selectedProducts = const [],
    this.selectedProductSubCategories = const [],

    this.lookupCache = const {},
    this.nilDepOptions = const [],
    this.categoryOptions = const [],
    this.mopedTypeOptions = const [],
    this.gvwOptions = const [],
    this.fuelTypeOptions = const [],
    this.makeOptions = const [],
    this.vehicleAgeGroupOptions = const [],
    this.seatingCapacityOptions = const [],
    this.ageGroupOptions = const [],
    this.familySizeOptions = const [],
    this.sumInsuredBandOptions = const [],
    this.preExistingOptions = const [],
    this.occupancyOptions = const [],
    this.sumInsuredOptions = const [],
    this.lifeGroupOptions = const [],

    this.selectedNilDep = const [],
    this.selectedCategory = const [],
    this.selectedMopedType = const [],
    this.selectedGvw = const [],
    this.selectedFuelType = const [],
    this.selectedMake = const [],
    this.selectedVehicleAgeGroup = const [],
    this.selectedSeatingCapacity = const [],
    this.selectedAgeGroup = const [],
    this.selectedFamilySize = const [],
    this.selectedSumInsuredBand = const [],
    this.selectedPreExisting = const [],
    this.selectedOccupancy = const [],
    this.selectedSumInsured = const [],
    this.selectedLifeGroup = const [],
    this.selectedRenewalYearCounts = const [],
    this.selectedNcb = const [],
    this.selectedPreferred = const [],
  });

  CalMstFilterState copyWith({
    bool? isLoading,
    List<FilterOption>? zones,
    List<FilterOption>? regions,
    List<FilterOption>? branches,
    List<FilterOption>? salesManagers,
    List<FilterOption>? agents,
    List<FilterOption>? references,
    List<FilterOption>? lobs,
    List<FilterOption>? productGroups,
    List<FilterOption>? products,
    List<FilterOption>? productSubCategories,
    Map<String, List<FilterOption>>? lookupCache,
    List<FilterOption>? renewalYearCounts,
    List<FilterOption>? ncbOptions,
    List<FilterOption>? preferredOptions,
    List<FilterOption>? selectedZones,
    List<FilterOption>? selectedRegions,
    List<FilterOption>? selectedBranches,
    List<FilterOption>? selectedSalesManagers,
    List<FilterOption>? selectedAgents,
    List<FilterOption>? selectedReferences,
    List<FilterOption>? selectedLobs,
    List<FilterOption>? selectedProductGroups,
    List<FilterOption>? selectedProducts,
    List<FilterOption>? selectedProductSubCategories,
    List<FilterOption>? nilDepOptions,
    List<FilterOption>? categoryOptions,
    List<FilterOption>? mopedTypeOptions,
    List<FilterOption>? gvwOptions,
    List<FilterOption>? fuelTypeOptions,
    List<FilterOption>? makeOptions,
    List<FilterOption>? vehicleAgeGroupOptions,
    List<FilterOption>? seatingCapacityOptions,
    List<FilterOption>? ageGroupOptions,
    List<FilterOption>? familySizeOptions,
    List<FilterOption>? sumInsuredBandOptions,
    List<FilterOption>? preExistingOptions,
    List<FilterOption>? occupancyOptions,
    List<FilterOption>? sumInsuredOptions,
    List<FilterOption>? lifeGroupOptions,

    List<FilterOption>? selectedNilDep,
    List<FilterOption>? selectedCategory,
    List<FilterOption>? selectedMopedType,
    List<FilterOption>? selectedGvw,
    List<FilterOption>? selectedFuelType,
    List<FilterOption>? selectedMake,
    List<FilterOption>? selectedVehicleAgeGroup,
    List<FilterOption>? selectedSeatingCapacity,
    List<FilterOption>? selectedAgeGroup,
    List<FilterOption>? selectedFamilySize,
    List<FilterOption>? selectedSumInsuredBand,
    List<FilterOption>? selectedPreExisting,
    List<FilterOption>? selectedOccupancy,
    List<FilterOption>? selectedSumInsured,
    List<FilterOption>? selectedLifeGroup,
    List<FilterOption>? selectedRenewalYearCounts,
    List<FilterOption>? selectedNcb,
    List<FilterOption>? selectedPreferred,
  }) {
    return CalMstFilterState(
      isLoading: isLoading ?? this.isLoading,
      zones: zones ?? this.zones,
      regions: regions ?? this.regions,
      branches: branches ?? this.branches,
      salesManagers: salesManagers ?? this.salesManagers,
      agents: agents ?? this.agents,
      references: references ?? this.references,
      lobs: lobs ?? this.lobs,
      productGroups: productGroups ?? this.productGroups,
      products: products ?? this.products,
      productSubCategories: productSubCategories ?? this.productSubCategories,
      lookupCache: lookupCache ?? this.lookupCache,
      renewalYearCounts: renewalYearCounts ?? this.renewalYearCounts,
      ncbOptions: ncbOptions ?? this.ncbOptions,
      preferredOptions: preferredOptions ?? this.preferredOptions,
      selectedZones: selectedZones ?? this.selectedZones,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      selectedBranches: selectedBranches ?? this.selectedBranches,
      selectedSalesManagers:
          selectedSalesManagers ?? this.selectedSalesManagers,
      selectedAgents: selectedAgents ?? this.selectedAgents,
      selectedReferences: selectedReferences ?? this.selectedReferences,
      selectedLobs: selectedLobs ?? this.selectedLobs,
      selectedProductGroups:
          selectedProductGroups ?? this.selectedProductGroups,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedProductSubCategories:
          selectedProductSubCategories ?? this.selectedProductSubCategories,

      nilDepOptions: nilDepOptions ?? this.nilDepOptions,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      mopedTypeOptions: mopedTypeOptions ?? this.mopedTypeOptions,
      gvwOptions: gvwOptions ?? this.gvwOptions,
      fuelTypeOptions: fuelTypeOptions ?? this.fuelTypeOptions,
      makeOptions: makeOptions ?? this.makeOptions,
      vehicleAgeGroupOptions:
          vehicleAgeGroupOptions ?? this.vehicleAgeGroupOptions,
      seatingCapacityOptions:
          seatingCapacityOptions ?? this.seatingCapacityOptions,
      ageGroupOptions: ageGroupOptions ?? this.ageGroupOptions,
      familySizeOptions: familySizeOptions ?? this.familySizeOptions,
      sumInsuredBandOptions:
          sumInsuredBandOptions ?? this.sumInsuredBandOptions,
      preExistingOptions: preExistingOptions ?? this.preExistingOptions,
      occupancyOptions: occupancyOptions ?? this.occupancyOptions,
      sumInsuredOptions: sumInsuredOptions ?? this.sumInsuredOptions,
      lifeGroupOptions: lifeGroupOptions ?? this.lifeGroupOptions,

      selectedNilDep: selectedNilDep ?? this.selectedNilDep,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedMopedType: selectedMopedType ?? this.selectedMopedType,
      selectedGvw: selectedGvw ?? this.selectedGvw,
      selectedFuelType: selectedFuelType ?? this.selectedFuelType,
      selectedMake: selectedMake ?? this.selectedMake,
      selectedVehicleAgeGroup:
          selectedVehicleAgeGroup ?? this.selectedVehicleAgeGroup,
      selectedSeatingCapacity:
          selectedSeatingCapacity ?? this.selectedSeatingCapacity,
      selectedAgeGroup: selectedAgeGroup ?? this.selectedAgeGroup,
      selectedFamilySize: selectedFamilySize ?? this.selectedFamilySize,
      selectedSumInsuredBand:
          selectedSumInsuredBand ?? this.selectedSumInsuredBand,
      selectedPreExisting: selectedPreExisting ?? this.selectedPreExisting,
      selectedOccupancy: selectedOccupancy ?? this.selectedOccupancy,
      selectedSumInsured: selectedSumInsured ?? this.selectedSumInsured,
      selectedLifeGroup: selectedLifeGroup ?? this.selectedLifeGroup,
      selectedRenewalYearCounts:
          selectedRenewalYearCounts ?? this.selectedRenewalYearCounts,
      selectedNcb: selectedNcb ?? this.selectedNcb,
      selectedPreferred: selectedPreferred ?? this.selectedPreferred,
    );
  }
}
