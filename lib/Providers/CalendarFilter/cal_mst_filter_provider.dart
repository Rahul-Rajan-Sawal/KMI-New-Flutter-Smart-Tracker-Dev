import 'package:flutter_bottom_nav/core/repository/filterrepository.dart';
import 'package:flutter_bottom_nav/models/Calendar/filter_option.dart';
import 'package:flutter_bottom_nav/models/CalendarFilter/Mstcalendarfiterstate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filterRepositoryProvider = Provider<FilterRepository>((ref) {
  return FilterRepository();
});

class CalMstFilterNotifier extends StateNotifier<CalMstFilterState> {
  final Ref ref;
  final String userId;
  final String year;
  final String month;
  final bool isTeam;

  CalMstFilterNotifier(
    this.ref, {
    required this.userId,
    required this.year,
    required this.month,
    this.isTeam = false,
  }) : super(const CalMstFilterState()) {
    loadInitialFilters();
  }

  Future<void> loadInitialFilters() async {
    state = state.copyWith(isLoading: true);

    final repo = ref.read(filterRepositoryProvider);

    final zones = await repo.getZones(userId: userId, year: year, month: month);

    final lobs = await repo.getLobs();
    final renewalYearCounts = await repo.getRenewalYearCounts();
    final ncbOptions = repo.getNcbOptions();
    final preferredOptions = repo.getPreferredOptions();

    state = state.copyWith(
      zones: zones,
      lobs: lobs,
      renewalYearCounts: renewalYearCounts,
      ncbOptions: ncbOptions,
      preferredOptions: preferredOptions,
      isLoading: false,
    );
  }

  List<FilterOption> _toggleOption(
    List<FilterOption> current,
    FilterOption option, {
    bool single = false,
  }) {
    if (single) {
      return current.any((item) => item.code == option.code) ? [] : [option];
    }

    final updated = [...current];
    final exists = updated.any((item) => item.code == option.code);

    // if (exists) {
    //   updated.removeWhere((item) => item.code == option.code);
    // } else {
    //   if (option.code == 'All') {
    //     return [option];
    //   }

    //   updated.removeWhere((item) => item.code == 'All');
    //   updated.add(option);
    // }
    if (exists) {
      updated.removeWhere((item) => item.code == option.code);
    } else {
      final isAllOption = option.code == 'All' || option.code.isEmpty;

      if (isAllOption) {
        return [option];
      }

      updated.removeWhere((item) => item.code == 'All' || item.code.isEmpty);
      updated.add(option);
    }

    return updated;
  }

  List<String> _codes(List<FilterOption> options) {
    return options.map((item) => item.code).toList();
  }

  Future<void> toggleZone(FilterOption zone) async {
    final selectedZones = _toggleOption(state.selectedZones, zone);

    state = state.copyWith(
      selectedZones: selectedZones,
      selectedRegions: [],
      selectedBranches: [],
      selectedSalesManagers: [],
      selectedAgents: [],
      selectedReferences: [],
      regions: [],
      branches: [],
      salesManagers: [],
      agents: [],
      references: [],
      isLoading: true,
    );

    final repo = ref.read(filterRepositoryProvider);

    final regions = await repo.getRegions(
      userId: userId,
      year: year,
      month: month,
      selectedZones: _codes(selectedZones),
    );

    state = state.copyWith(regions: regions, isLoading: false);
  }

  Future<void> toggleRegion(FilterOption region) async {
    final selectedRegions = _toggleOption(
      state.selectedRegions,
      region,
      single: !isTeam,
    );

    state = state.copyWith(
      selectedRegions: selectedRegions,
      selectedBranches: [],
      selectedSalesManagers: [],
      selectedAgents: [],
      selectedReferences: [],
      branches: [],
      salesManagers: [],
      agents: [],
      references: [],
      isLoading: true,
    );

    final repo = ref.read(filterRepositoryProvider);

    final branches = await repo.getBranches(
      userId: userId,
      year: year,
      month: month,
      selectedRegions: _codes(selectedRegions),
      isTeam: isTeam,
    );

    state = state.copyWith(branches: branches, isLoading: false);
  }

  Future<void> toggleBranch(FilterOption branch) async {
    final selectedBranches = _toggleOption(
      state.selectedBranches,
      branch,
      single: !isTeam,
    );

    state = state.copyWith(
      selectedBranches: selectedBranches,
      selectedSalesManagers: [],
      selectedAgents: [],
      selectedReferences: [],
      salesManagers: [],
      agents: [],
      references: [],
      isLoading: true,
    );

    final repo = ref.read(filterRepositoryProvider);

    final salesManagers = await repo.getSalesManagers(
      userId: userId,
      selectedBranches: _codes(selectedBranches),
      isTeam: isTeam,
    );

    state = state.copyWith(salesManagers: salesManagers, isLoading: false);
  }

  Future<void> toggleSalesManager(FilterOption salesManager) async {
    final selectedSalesManagers = _toggleOption(
      state.selectedSalesManagers,
      salesManager,
      single: !isTeam,
    );

    state = state.copyWith(
      selectedSalesManagers: selectedSalesManagers,
      selectedAgents: [],
      selectedReferences: [],
      agents: [],
      references: [],
      isLoading: true,
    );

    final repo = ref.read(filterRepositoryProvider);

    final agents = await repo.getAgents(
      userId: userId,
      selectedSalesManagers: _codes(selectedSalesManagers),
    );

    state = state.copyWith(agents: agents, isLoading: false);
  }

  Future<void> toggleAgent(FilterOption agent) async {
    final selectedAgents = _toggleOption(state.selectedAgents, agent);

    state = state.copyWith(
      selectedAgents: selectedAgents,
      selectedReferences: [],
      references: [],
      isLoading: true,
    );

    final repo = ref.read(filterRepositoryProvider);

    final references = await repo.getReferences(
      userId: userId,
      selectedAgents: _codes(selectedAgents),
    );

    state = state.copyWith(references: references, isLoading: false);
  }

  void toggleReference(FilterOption reference) {
    state = state.copyWith(
      selectedReferences: _toggleOption(state.selectedReferences, reference),
    );
  }

  // Future<void> toggleLob(FilterOption lob) async {
  //   final selectedLobs = _toggleOption(state.selectedLobs, lob, single: true);

  //   state = state.copyWith(
  //     selectedLobs: selectedLobs,
  //     selectedProductGroups: [],
  //     selectedProducts: [],
  //     selectedProductSubCategories: [],
  //     productGroups: [],
  //     products: [],
  //     productSubCategories: [],
  //     isLoading: true,
  //   );

  //   final repo = ref.read(filterRepositoryProvider);

  //   final productGroups = selectedLobs.isEmpty
  //       ? <FilterOption>[]
  //       : await repo.getProductGroups(lobCode: selectedLobs.first.code);

  //   state = state.copyWith(
  //     productGroups: productGroups,
  //     isLoading: false,
  //   );
  // }

  Future<void> toggleLob(FilterOption lob) async {
    final selectedLobs = _toggleOption(state.selectedLobs, lob, single: true);

    state = state.copyWith(
      selectedLobs: selectedLobs,

      selectedProductGroups: [],
      selectedProducts: [],
      selectedProductSubCategories: [],

      productGroups: [],
      products: [],
      productSubCategories: [],

      // clear dynamic product selected values
      selectedNilDep: [],
      selectedCategory: [],
      selectedMopedType: [],
      selectedGvw: [],
      selectedFuelType: [],
      selectedMake: [],
      selectedVehicleAgeGroup: [],
      selectedSeatingCapacity: [],
      selectedAgeGroup: [],
      selectedFamilySize: [],
      selectedSumInsuredBand: [],
      selectedPreExisting: [],
      selectedOccupancy: [],
      selectedSumInsured: [],
      selectedLifeGroup: [],

      // clear dynamic product options
      nilDepOptions: [],
      categoryOptions: [],
      mopedTypeOptions: [],
      gvwOptions: [],
      fuelTypeOptions: [],
      vehicleAgeGroupOptions: [],
      seatingCapacityOptions: [],
      ageGroupOptions: [],
      familySizeOptions: [],
      sumInsuredBandOptions: [],
      preExistingOptions: [],
      occupancyOptions: [],
      sumInsuredOptions: [],
      lifeGroupOptions: [],

      isLoading: true,
    );

    final repo = ref.read(filterRepositoryProvider);

    final productGroups = selectedLobs.isEmpty
        ? <FilterOption>[]
        : await repo.getProductGroups(lobCode: selectedLobs.first.code);

    state = state.copyWith(productGroups: productGroups, isLoading: false);
  }

  //new added
  Future<void> toggleProductGroup(FilterOption productGroup) async {
    final selectedProductGroups = _toggleOption(
      state.selectedProductGroups,
      productGroup,
      single: true,
    );

    state = state.copyWith(
      selectedProductGroups: selectedProductGroups,

      selectedProducts: [],
      selectedProductSubCategories: [],
      products: [],
      productSubCategories: [],

      selectedNilDep: [],
      selectedCategory: [],
      selectedMopedType: [],
      selectedGvw: [],
      selectedFuelType: [],
      selectedMake: [],
      selectedVehicleAgeGroup: [],
      selectedSeatingCapacity: [],
      selectedAgeGroup: [],
      selectedFamilySize: [],
      selectedSumInsuredBand: [],
      selectedPreExisting: [],
      selectedOccupancy: [],
      selectedSumInsured: [],
      selectedLifeGroup: [],

      nilDepOptions: [],
      categoryOptions: [],
      mopedTypeOptions: [],
      gvwOptions: [],
      fuelTypeOptions: [],
      vehicleAgeGroupOptions: [],
      seatingCapacityOptions: [],
      ageGroupOptions: [],
      familySizeOptions: [],
      sumInsuredBandOptions: [],
      preExistingOptions: [],
      occupancyOptions: [],
      sumInsuredOptions: [],
      lifeGroupOptions: [],

      isLoading: true,
    );

    final repo = ref.read(filterRepositoryProvider);

    final hasLob = state.selectedLobs.isNotEmpty;
    final hasProductGroup = selectedProductGroups.isNotEmpty;

    final products = hasLob && hasProductGroup
        ? await repo.getProducts(
            lobCode: state.selectedLobs.first.code,
            productGroup: selectedProductGroups.first.code,
          )
        : <FilterOption>[];

    final productSubCategories = hasProductGroup
        ? await repo.getProductSubCategories(
            productGroups: _codes(selectedProductGroups),
          )
        : <FilterOption>[];

    final lookupCache = state.lookupCache.isEmpty
        ? await repo.getAllLookupOptions()
        : state.lookupCache;

    final makeOptions = state.makeOptions.isEmpty
        ? await repo.getVehicleMakes()
        : state.makeOptions;

    final dynamicDropdowns = hasProductGroup
        ? repo.getDynamicProductDropdownsFromCache(
            productGroup: selectedProductGroups.first.code,
            lookupCache: lookupCache,
            makeOptions: makeOptions,
          )
        : <String, List<FilterOption>>{};

    print(
      "PRODUCT GROUP: ${hasProductGroup ? selectedProductGroups.first.code : ''}",
    );
    print("LOOKUP CACHE KEYS: ${lookupCache.keys.toList()}");
    print("MAKE COUNT: ${makeOptions.length}");
    print("NIL DEP COUNT: ${dynamicDropdowns['nilDep']?.length}");
    print("CATEGORY COUNT: ${dynamicDropdowns['category']?.length}");
    print("GVW COUNT: ${dynamicDropdowns['gvw']?.length}");
    print("FUEL TYPE COUNT: ${dynamicDropdowns['fuelType']?.length}");
    print("VEHICLE AGE COUNT: ${dynamicDropdowns['vehicleAgeGroup']?.length}");
    print("SEATING COUNT: ${dynamicDropdowns['seatingCapacity']?.length}");
    print("OCCUPANCY COUNT: ${dynamicDropdowns['occupancy']?.length}");
    print("SUM INSURED COUNT: ${dynamicDropdowns['sumInsured']?.length}");

    state = state.copyWith(
      products: products,
      productSubCategories: productSubCategories,

      lookupCache: lookupCache,
      makeOptions: makeOptions,

      nilDepOptions: dynamicDropdowns['nilDep'] ?? [],
      categoryOptions: dynamicDropdowns['category'] ?? [],
      mopedTypeOptions: dynamicDropdowns['mopedType'] ?? [],
      gvwOptions: dynamicDropdowns['gvw'] ?? [],
      fuelTypeOptions: dynamicDropdowns['fuelType'] ?? [],
      vehicleAgeGroupOptions: dynamicDropdowns['vehicleAgeGroup'] ?? [],
      seatingCapacityOptions: dynamicDropdowns['seatingCapacity'] ?? [],
      ageGroupOptions: dynamicDropdowns['ageGroup'] ?? [],
      familySizeOptions: dynamicDropdowns['familySize'] ?? [],
      sumInsuredBandOptions: dynamicDropdowns['sumInsuredBand'] ?? [],
      preExistingOptions: dynamicDropdowns['preExisting'] ?? [],
      occupancyOptions: dynamicDropdowns['occupancy'] ?? [],
      sumInsuredOptions: dynamicDropdowns['sumInsured'] ?? [],
      lifeGroupOptions: dynamicDropdowns['lifeGroup'] ?? [],

      isLoading: false,
    );
  }
  //Commeted for sub dropdowns
  // Future<void> toggleProductGroup(FilterOption productGroup) async {
  //   final selectedProductGroups = _toggleOption(
  //     state.selectedProductGroups,
  //     productGroup,
  //     single: true,
  //   );

  //   state = state.copyWith(
  //     selectedProductGroups: selectedProductGroups,
  //     selectedProducts: [],
  //     selectedProductSubCategories: [],
  //     products: [],
  //     productSubCategories: [],
  //     isLoading: true,
  //   );

  //   final repo = ref.read(filterRepositoryProvider);

  //   final hasLob = state.selectedLobs.isNotEmpty;
  //   final hasProductGroup = selectedProductGroups.isNotEmpty;

  //   final products = hasLob && hasProductGroup
  //       ? await repo.getProducts(
  //           lobCode: state.selectedLobs.first.code,
  //           productGroup: selectedProductGroups.first.code,
  //         )
  //       : <FilterOption>[];

  //   final productSubCategories = hasProductGroup
  //       ? await repo.getProductSubCategories(
  //           productGroups: _codes(selectedProductGroups),
  //         )
  //       : <FilterOption>[];

  //   state = state.copyWith(
  //     products: products,
  //     productSubCategories: productSubCategories,
  //     isLoading: false,
  //   );
  // }

  // void toggleProduct(FilterOption product) {
  //   state = state.copyWith(
  //     selectedProducts: _toggleOption(
  //       state.selectedProducts,
  //       product,
  //       single: true,
  //     ),
  //   );
  // }

  void toggleProduct(FilterOption product) {
    state = state.copyWith(
      selectedProducts: _toggleOption(state.selectedProducts, product),
    );
  }

  void toggleProductSubCategory(FilterOption productSubCategory) {
    state = state.copyWith(
      selectedProductSubCategories: _toggleOption(
        state.selectedProductSubCategories,
        productSubCategory,
      ),
    );
  }

  // Selects or clears the Nil Dep dropdown value.
  void toggleNilDep(FilterOption option) {
    state = state.copyWith(
      selectedNilDep: _toggleOption(state.selectedNilDep, option, single: true),
    );
  }

  // Selects or clears the Category dropdown value.
  void toggleCategory(FilterOption option) {
    state = state.copyWith(
      selectedCategory: _toggleOption(
        state.selectedCategory,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Moped Type dropdown value.
  void toggleMopedType(FilterOption option) {
    state = state.copyWith(
      selectedMopedType: _toggleOption(
        state.selectedMopedType,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the GVW dropdown value.
  void toggleGvw(FilterOption option) {
    state = state.copyWith(
      selectedGvw: _toggleOption(state.selectedGvw, option, single: true),
    );
  }

  // Selects or clears the Fuel Type dropdown value.
  void toggleFuelType(FilterOption option) {
    state = state.copyWith(
      selectedFuelType: _toggleOption(
        state.selectedFuelType,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Make dropdown value.
  void toggleMake(FilterOption option) {
    state = state.copyWith(
      selectedMake: _toggleOption(state.selectedMake, option, single: true),
    );
  }

  // Selects or clears the Vehicle Age Group dropdown value.
  void toggleVehicleAgeGroup(FilterOption option) {
    state = state.copyWith(
      selectedVehicleAgeGroup: _toggleOption(
        state.selectedVehicleAgeGroup,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Seating Capacity dropdown value.
  void toggleSeatingCapacity(FilterOption option) {
    state = state.copyWith(
      selectedSeatingCapacity: _toggleOption(
        state.selectedSeatingCapacity,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Age Group dropdown value.
  void toggleAgeGroup(FilterOption option) {
    state = state.copyWith(
      selectedAgeGroup: _toggleOption(
        state.selectedAgeGroup,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Family Size dropdown value.
  void toggleFamilySize(FilterOption option) {
    state = state.copyWith(
      selectedFamilySize: _toggleOption(
        state.selectedFamilySize,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Sum Insured Band dropdown value.
  void toggleSumInsuredBand(FilterOption option) {
    state = state.copyWith(
      selectedSumInsuredBand: _toggleOption(
        state.selectedSumInsuredBand,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Pre Existing dropdown value.
  void togglePreExisting(FilterOption option) {
    state = state.copyWith(
      selectedPreExisting: _toggleOption(
        state.selectedPreExisting,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Occupancy dropdown value.
  void toggleOccupancy(FilterOption option) {
    state = state.copyWith(
      selectedOccupancy: _toggleOption(
        state.selectedOccupancy,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Sum Insured dropdown value.
  void toggleSumInsured(FilterOption option) {
    state = state.copyWith(
      selectedSumInsured: _toggleOption(
        state.selectedSumInsured,
        option,
        single: true,
      ),
    );
  }

  // Selects or clears the Life Group dropdown value.
  void toggleLifeGroup(FilterOption option) {
    state = state.copyWith(
      selectedLifeGroup: _toggleOption(
        state.selectedLifeGroup,
        option,
        single: true,
      ),
    );
  }

  void toggleRenewalYearCount(FilterOption renewalYearCount) {
    state = state.copyWith(
      selectedRenewalYearCounts: _toggleOption(
        state.selectedRenewalYearCounts,
        renewalYearCount,
      ),
    );
  }

  void toggleNcb(FilterOption ncb) {
    state = state.copyWith(
      selectedNcb: _toggleOption(state.selectedNcb, ncb, single: true),
    );
  }

  void togglePreferred(FilterOption preferred) {
    state = state.copyWith(
      selectedPreferred: _toggleOption(
        state.selectedPreferred,
        preferred,
        single: true,
      ),
    );
  }

  Future<void> clearFilters() async {
    state = const CalMstFilterState();
    await loadInitialFilters();
  }
}

class CalMstFilterArgs {
  final String userId;
  final String year;
  final String month;
  final bool isTeam;

  const CalMstFilterArgs({
    required this.userId,
    required this.year,
    required this.month,
    this.isTeam = false,
  });

  @override
  bool operator ==(Object other) {
    return other is CalMstFilterArgs &&
        other.userId == userId &&
        other.year == year &&
        other.month == month &&
        other.isTeam == isTeam;
  }

  @override
  int get hashCode => Object.hash(userId, year, month, isTeam);
}

final calMstFilterProvider =
    StateNotifierProvider.family<
      CalMstFilterNotifier,
      CalMstFilterState,
      CalMstFilterArgs
    >(
      (ref, args) => CalMstFilterNotifier(
        ref,
        userId: args.userId,
        year: args.year,
        month: args.month,
        isTeam: args.isTeam,
      ),
    );
