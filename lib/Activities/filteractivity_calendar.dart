// import 'package:flutter/material.dart';
// import 'package:flutter_bottom_nav/Providers/CalendarFilter/cal_mst_filter_provider.dart';
// import 'package:flutter_bottom_nav/Providers/calendar_filter_provider.dart';
// import 'package:flutter_bottom_nav/models/Calendar/filter_option.dart';
// import 'package:flutter_bottom_nav/models/CalendarFilter/Mstcalendarfiterstate.dart';
// import 'package:flutter_bottom_nav/models/CalendarFilterState.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class CalendarFilterActivity extends ConsumerStatefulWidget {
//   final String userId;
//   final String year;
//   final String month;
//   final bool isTeam;

//   const CalendarFilterActivity({
//     super.key,
//     required this.userId,
//     required this.year,
//     required this.month,
//     this.isTeam = false,
//   });
//   @override
//   ConsumerState<CalendarFilterActivity> createState() =>
//       _CalendarFilterActivityState();
// }

// class _CalendarFilterActivityState
//     extends ConsumerState<CalendarFilterActivity> {
//   int selectedIndex = 0;

//   List<String> zoneList = ["North", "South", "East", "West"];
//   List<String> regionList = ["Region A", "Region B", "Region C"];
//   List<String> branchList = ["Branch 1", "Branch 2", "Branch 3"];

//   final List<String> filterCategories = [
//     "Period",
//     "Zone",
//     "Region",
//     "Branch",
//     "Sales Manager",
//     "Agent",
//     "Reference",
//     "LOB",
//     "Product Group",
//     "Product",
//     "Product Sub Category",
//     "Renewal Year Count",
//     "NCB",
//     "Preferred",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final filterState = ref.watch(calendarFilterProvider);
//     final filterNotifier = ref.read(calendarFilterProvider.notifier);
//     // final filterState = ref.watch(filterProvider);
//     // final filterNotifier = ref.read(filterProvider.notifier);
//     // final filterState = ref.watch(calendarFilterProvider);

//     // final filterNotifier = ref.read(calendarFilterProvider.notifier);
//     final mstArgs = CalMstFilterArgs(
//       userId: widget.userId,
//       year: widget.year,
//       month: widget.month,
//       isTeam: widget.isTeam,
//     );

//     final mstState = ref.watch(calMstFilterProvider(mstArgs));
//     final mstNotifier = ref.read(calMstFilterProvider(mstArgs).notifier);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: const Text("Filter"),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               //ref.read(calendarFilterProvider.notifier).clearFilters();
//               ref.read(calendarFilterProvider.notifier).clearFilters();
//               await ref
//                   .read(calMstFilterProvider(mstArgs).notifier)
//                   .clearFilters();
//             },
//             child: const Text(
//               "Clear Filters",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 /// LEFT CATEGORY LIST
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.35,
//                   color: Colors.blue,
//                   child: ListView.builder(
//                     itemCount: filterCategories.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedIndex = index;
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 16,
//                             horizontal: 12,
//                           ),
//                           color: selectedIndex == index
//                               ? Colors.red
//                               : Colors.blue,
//                           child: Text(
//                             filterCategories[index],
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 /// RIGHT OPTIONS PANEL
//                 Expanded(
//                   child: Container(
//                     color: Colors.grey[200],
//                     padding: const EdgeInsets.all(12),
//                     //child: _buildRightPanel(filterState, filterNotifier),
//                     child: mstState.isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : _buildRightPanel(
//                             filterState,
//                             filterNotifier,
//                             mstState,
//                             mstNotifier,
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// BOTTOM BUTTONS
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[300],
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text(
//                       "Cancel",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context, filterState);
//                       // Navigator.pop(context);
//                     },
//                     child: const Text("Apply"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// TEMP RIGHT PANEL (Static UI for now)
//   Widget _buildRightPanel(
//     CalendarFilterState filterState,
//     CalendarFilterNotifier filterNotifier,
//     CalMstFilterState mstState,
//     CalMstFilterNotifier mstNotifier,
//   ) {
//     String selectedCategory = filterCategories[selectedIndex];

//     // PERIOD (Radio Buttons)
//     if (selectedCategory == "Period") {
//       List<String> months = _generateMonthList();

//       return ListView(
//         children: months.map((month) {
//           return RadioListTile<String>(
//             value: month,
//             groupValue: filterState.period.isNotEmpty
//                 ? filterState.period.first
//                 : null,
//             onChanged: (value) {
//               setState(() {
//                 filterNotifier.setPeriod(value!);
//               });
//             },
//             title: Text(month),
//           );
//         }).toList(),
//       );
//     }

//     else if (selectedCategory == "Zone") {
//   return _buildCheckboxOptions(
//     options: mstState.zones,
//     selectedOptions: mstState.selectedZones,
//     onToggle: (option) async {
//       await mstNotifier.toggleZone(option);
//     },
//   );
// }
//     // ZONE (Checkbox)
//     // else if (selectedCategory == "Zone") {
//     //   return ListView(
//     //     children: zoneList.map((zone) {
//     //       return CheckboxListTile(
//     //         value: filterState.zone.contains(zone),
//     //         onChanged: (_) {
//     //           filterNotifier.toggleZone(zone);
//     //         },
//     //         title: Text(zone),
//     //       );
//     //     }).toList(),
//     //   );
//     // }
//     // REGION (Checkbox)
//     else if (selectedCategory == "Region") {
//       return ListView(
//         children: regionList.map((region) {
//           return CheckboxListTile(
//             value: filterState.region.contains(region),
//             onChanged: (_) {
//               filterNotifier.toggleRegion(region);
//             },
//             title: Text(region),
//           );
//         }).toList(),
//       );
//     }
//     // BRANCH (Radio Button)
//     else if (selectedCategory == "Branch") {
//       return ListView(
//         children: branchList.map((branch) {
//           return RadioListTile<String>(
//             value: branch,
//             groupValue: filterState.branch.isNotEmpty
//                 ? filterState.branch.first
//                 : null,
//             onChanged: (value) {
//               filterNotifier.setBranch(value!);
//               setState(() {});
//             },
//             title: Text(branch),
//           );
//         }).toList(),
//       );
//     }
//     // NO DATA AVAILABLE
//     else {
//       return const Center(
//         child: Text(
//           "No data available",
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       );
//     }
//   }

//   List<String> _generateMonthList() {
//     DateTime now = DateTime.now();
//     List<String> months = [];

//     for (int i = -2; i <= 2; i++) {
//       DateTime date = DateTime(now.year, now.month + i);
//       months.add("${_monthName(date.month)} ${date.year}");
//     }

//     return months;
//   }

//   String _monthName(int month) {
//     const monthNames = [
//       "January",
//       "February",
//       "March",
//       "April",
//       "May",
//       "June",
//       "July",
//       "August",
//       "September",
//       "October",
//       "November",
//       "December",
//     ];
//     return monthNames[month - 1];
//   }

//   //checkboxes builder
//   Widget _buildCheckboxOptions({
//   required List<FilterOption> options,
//   required List<FilterOption> selectedOptions,
//   required void Function(FilterOption option) onToggle,
// }) {
//   if (options.isEmpty) {
//     return const Center(
//       child: Text(
//         "No data available",
//         style: TextStyle(fontSize: 16, color: Colors.grey),
//       ),
//     );
//   }

//   return ListView.builder(
//     itemCount: options.length,
//     itemBuilder: (context, index) {
//       final option = options[index];

//       return CheckboxListTile(
//         value: selectedOptions.any((item) => item.code == option.code),
//         onChanged: (_) => onToggle(option),
//         title: Text(option.description),
//       );
//     },
//   );
// }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Providers/CalendarFilter/cal_mst_filter_provider.dart';
import 'package:flutter_bottom_nav/Providers/calendar_filter_provider.dart';
import 'package:flutter_bottom_nav/models/Calendar/filter_option.dart';
import 'package:flutter_bottom_nav/models/CalendarFilter/Mstcalendarfiterstate.dart';
import 'package:flutter_bottom_nav/models/CalendarFilterState.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarFilterActivity extends ConsumerStatefulWidget {
  final String userId;
  final String year;
  final String month;
  final bool isTeam;

  const CalendarFilterActivity({
    super.key,
    required this.userId,
    required this.year,
    required this.month,
    this.isTeam = false,
  });

  @override
  ConsumerState<CalendarFilterActivity> createState() =>
      _CalendarFilterActivityState();
}

class _CalendarFilterActivityState
    extends ConsumerState<CalendarFilterActivity> {
  int selectedIndex = 0;

  final List<String> filterCategories = [
    "Period",
    "Zone",
    "Region",
    "Branch",
    "Sales Manager",
    "Agent",
    "Reference",
    "LOB",
    "Product Group",
    "Product",
    "Product Sub Category",
    "Renewal Year Count",
    "NCB",
    "Preferred",
  ];

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(calendarFilterProvider);
    final filterNotifier = ref.read(calendarFilterProvider.notifier);

    final mstArgs = CalMstFilterArgs(
      userId: widget.userId,
      year: widget.year,
      month: widget.month,
      isTeam: widget.isTeam,
    );

    final mstState = ref.watch(calMstFilterProvider(mstArgs));
    final mstNotifier = ref.read(calMstFilterProvider(mstArgs).notifier);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Filter"),
        actions: [
          TextButton(
            onPressed: () async {
              ref.read(calendarFilterProvider.notifier).clearFilters();
              await ref
                  .read(calMstFilterProvider(mstArgs).notifier)
                  .clearFilters();
            },
            child: const Text(
              "Clear Filters",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  color: Colors.blue,
                  child: ListView.builder(
                    itemCount: filterCategories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          color: selectedIndex == index
                              ? Colors.red
                              : Colors.blue,
                          child: Text(
                            filterCategories[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(12),
                    child: mstState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildRightPanel(
                            filterState,
                            filterNotifier,
                            mstState,
                            mstNotifier,
                          ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      final latestMstState = ref.read(
                        calMstFilterProvider(mstArgs),
                      );

                      final appliedState = filterState.copyWith(
                        zone: latestMstState.selectedZones
                            .map((e) => e.code)
                            .toList(),
                        region: latestMstState.selectedRegions
                            .map((e) => e.code)
                            .toList(),
                        branch: latestMstState.selectedBranches
                            .map((e) => e.code)
                            .toList(),
                        salesManager: latestMstState.selectedSalesManagers
                            .map((e) => e.code)
                            .toList(),
                        agent: latestMstState.selectedAgents
                            .map((e) => e.code)
                            .toList(),
                        reference: latestMstState.selectedReferences
                            .map((e) => e.code)
                            .toList(),
                        lob: latestMstState.selectedLobs
                            .map((e) => e.code)
                            .toList(),
                        productGroup: latestMstState.selectedProductGroups
                            .map((e) => e.code)
                            .toList(),
                        product: latestMstState.selectedProducts
                            .map((e) => e.code)
                            .toList(),
                        productSubCategory: latestMstState
                            .selectedProductSubCategories
                            .map((e) => e.code)
                            .toList(),
                        renewalYearCount: latestMstState
                            .selectedRenewalYearCounts
                            .map((e) => e.code)
                            .toList(),
                        ncb: latestMstState.selectedNcb
                            .map((e) => e.code)
                            .toList(),
                        preferred: latestMstState.selectedPreferred
                            .map((e) => e.code)
                            .toList(),
                      );

                      ref
                          .read(calendarFilterProvider.notifier)
                          .setFilters(appliedState);

                      Navigator.pop(context, appliedState);
                    },
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(
    CalendarFilterState filterState,
    CalendarFilterNotifier filterNotifier,
    CalMstFilterState mstState,
    CalMstFilterNotifier mstNotifier,
  ) {
    final selectedCategory = filterCategories[selectedIndex];

    if (selectedCategory == "Period") {
      final months = _generateMonthList();

      return ListView(
        children: months.map((month) {
          return RadioListTile<String>(
            value: month,
            groupValue: filterState.period.isNotEmpty
                ? filterState.period.first
                : null,
            onChanged: (value) {
              filterNotifier.setPeriod(value!);
            },
            title: Text(month),
          );
        }).toList(),
      );
    } else if (selectedCategory == "Zone") {
      return _buildCheckboxOptions(
        options: mstState.zones,
        selectedOptions: mstState.selectedZones,
        onToggle: (option) async {
          await mstNotifier.toggleZone(option);
        },
      );
    } else if (selectedCategory == "Region") {
      return _buildCheckboxOptions(
        options: mstState.regions,
        selectedOptions: mstState.selectedRegions,
        onToggle: (option) async {
          await mstNotifier.toggleRegion(option);
        },
      );
    } else if (selectedCategory == "Branch") {
      return _buildCheckboxOptions(
        options: mstState.branches,
        selectedOptions: mstState.selectedBranches,
        onToggle: (option) async {
          await mstNotifier.toggleBranch(option);
        },
      );
    } else if (selectedCategory == "Sales Manager") {
      return _buildCheckboxOptions(
        options: mstState.salesManagers,
        selectedOptions: mstState.selectedSalesManagers,
        onToggle: (option) async {
          await mstNotifier.toggleSalesManager(option);
        },
      );
    } else if (selectedCategory == "Agent") {
      return _buildCheckboxOptions(
        options: mstState.agents,
        selectedOptions: mstState.selectedAgents,
        onToggle: (option) async {
          await mstNotifier.toggleAgent(option);
        },
      );
    } else if (selectedCategory == "Reference") {
      return _buildCheckboxOptions(
        options: mstState.references,
        selectedOptions: mstState.selectedReferences,
        onToggle: (option) {
          mstNotifier.toggleReference(option);
        },
      );
    } else if (selectedCategory == "LOB") {
      return _buildCheckboxOptions(
        options: mstState.lobs,
        selectedOptions: mstState.selectedLobs,
        onToggle: (option) async {
          await mstNotifier.toggleLob(option);
        },
      );
    } else if (selectedCategory == "Product Group") {
      return _buildCheckboxOptions(
        options: mstState.productGroups,
        selectedOptions: mstState.selectedProductGroups,
        onToggle: (option) async {
          await mstNotifier.toggleProductGroup(option);
        },
      );
    } else if (selectedCategory == "Product") {
      return _buildProductDropdownSection(mstState, mstNotifier);
    }
    //  else if (selectedCategory == "Product") {
    //   return _buildCheckboxOptions(
    //     options: mstState.products,
    //     selectedOptions: mstState.selectedProducts,
    //     onToggle: (option) {
    //       mstNotifier.toggleProduct(option);
    //     },
    //   );
    // }
    else if (selectedCategory == "Product Sub Category") {
      return _buildCheckboxOptions(
        options: mstState.productSubCategories,
        selectedOptions: mstState.selectedProductSubCategories,
        onToggle: (option) {
          mstNotifier.toggleProductSubCategory(option);
        },
      );
    } else if (selectedCategory == "Renewal Year Count") {
      return _buildCheckboxOptions(
        options: mstState.renewalYearCounts,
        selectedOptions: mstState.selectedRenewalYearCounts,
        onToggle: (option) {
          mstNotifier.toggleRenewalYearCount(option);
        },
      );
    } else if (selectedCategory == "NCB") {
      return _buildCheckboxOptions(
        options: mstState.ncbOptions,
        selectedOptions: mstState.selectedNcb,
        onToggle: (option) {
          mstNotifier.toggleNcb(option);
        },
      );
    } else if (selectedCategory == "Preferred") {
      return _buildCheckboxOptions(
        options: mstState.preferredOptions,
        selectedOptions: mstState.selectedPreferred,
        onToggle: (option) {
          mstNotifier.togglePreferred(option);
        },
      );
    }

    return const Center(
      child: Text(
        "No data available",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildCheckboxOptions({
    required List<FilterOption> options,
    required List<FilterOption> selectedOptions,
    required void Function(FilterOption option) onToggle,
  }) {
    if (options.isEmpty) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];

        return CheckboxListTile(
          value: selectedOptions.any((item) => item.code == option.code),
          onChanged: (_) => onToggle(option),
          title: Text(option.description),
        );
      },
    );
  }

  List<String> _generateMonthList() {
    final now = DateTime.now();
    final months = <String>[];

    for (int i = -2; i <= 2; i++) {
      final date = DateTime(now.year, now.month + i);
      months.add("${_monthName(date.month)} ${date.year}");
    }

    return months;
  }

  String _monthName(int month) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return monthNames[month - 1];
  }

  Widget _buildSingleDropdown({
  required String label,
  required List<FilterOption> options,
  required List<FilterOption> selectedOptions,
  required void Function(FilterOption option) onChanged,
}) {
  final selectedCode =
      selectedOptions.isNotEmpty ? selectedOptions.first.code : null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      value: options.any((item) => item.code == selectedCode)
          ? selectedCode
          : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option.code,
          child: Text(
            option.description,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: options.isEmpty
          ? null
          : (value) {
              if (value == null) return;

              final selectedOption = options.firstWhere(
                (item) => item.code == value,
              );

              onChanged(selectedOption);
            },
    ),
  );
}

Widget _buildCheckboxGroup({
  required String title,
  required List<FilterOption> options,
  required List<FilterOption> selectedOptions,
  required void Function(FilterOption option) onToggle,
}) {
  if (options.isEmpty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        "$title options not available",
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),

        ...options.map((option) {
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: selectedOptions.any((item) => item.code == option.code),
            onChanged: (_) => onToggle(option),
            title: Text(option.description),
          );
        }),
      ],
    ),
  );
}

Widget _buildProductDropdownSection(
  CalMstFilterState mstState,
  CalMstFilterNotifier mstNotifier,
) {
  if (mstState.selectedProductGroups.isEmpty) {
    return const Center(
      child: Text( 
        
        "Product group selection is mandatory before Product selection.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  final productGroup = mstState.selectedProductGroups.first.code
      .trim()
      .toLowerCase();

  return ListView(
    children: [
      _buildCheckboxGroup(
        title: "Product",
        options: mstState.products,
        selectedOptions: mstState.selectedProducts,
        onToggle: mstNotifier.toggleProduct,
      ),

      if (productGroup == "pvt") ...[
        _buildSingleDropdown(
          label: "Nil Dep",
          options: mstState.nilDepOptions,
          selectedOptions: mstState.selectedNilDep,
          onChanged: mstNotifier.toggleNilDep,
        ),
        _buildSingleDropdown(
          label: "Category",
          options: mstState.categoryOptions,
          selectedOptions: mstState.selectedCategory,
          onChanged: mstNotifier.toggleCategory,
        ),
        _buildSingleDropdown(
          label: "Fuel Type",
          options: mstState.fuelTypeOptions,
          selectedOptions: mstState.selectedFuelType,
          onChanged: mstNotifier.toggleFuelType,
        ),
        _buildSingleDropdown(
          label: "Make",
          options: mstState.makeOptions,
          selectedOptions: mstState.selectedMake,
          onChanged: mstNotifier.toggleMake,
        ),
        _buildSingleDropdown(
          label: "Vehicle Age Group",
          options: mstState.vehicleAgeGroupOptions,
          selectedOptions: mstState.selectedVehicleAgeGroup,
          onChanged: mstNotifier.toggleVehicleAgeGroup,
        ),
      ],

      if (productGroup == "2w") ...[
        _buildSingleDropdown(
          label: "Nil Dep",
          options: mstState.nilDepOptions,
          selectedOptions: mstState.selectedNilDep,
          onChanged: mstNotifier.toggleNilDep,
        ),
        _buildSingleDropdown(
          label: "Moped Type",
          options: mstState.mopedTypeOptions,
          selectedOptions: mstState.selectedMopedType,
          onChanged: mstNotifier.toggleMopedType,
        ),
        _buildSingleDropdown(
          label: "Make",
          options: mstState.makeOptions,
          selectedOptions: mstState.selectedMake,
          onChanged: mstNotifier.toggleMake,
        ),
        _buildSingleDropdown(
          label: "Vehicle Age Group",
          options: mstState.vehicleAgeGroupOptions,
          selectedOptions: mstState.selectedVehicleAgeGroup,
          onChanged: mstNotifier.toggleVehicleAgeGroup,
        ),
      ],

      if (productGroup == "pcv" || productGroup == "gcv") ...[
        _buildSingleDropdown(
          label: "Nil Dep",
          options: mstState.nilDepOptions,
          selectedOptions: mstState.selectedNilDep,
          onChanged: mstNotifier.toggleNilDep,
        ),
        _buildSingleDropdown(
          label: "GVW",
          options: mstState.gvwOptions,
          selectedOptions: mstState.selectedGvw,
          onChanged: mstNotifier.toggleGvw,
        ),
        _buildSingleDropdown(
          label: "Make",
          options: mstState.makeOptions,
          selectedOptions: mstState.selectedMake,
          onChanged: mstNotifier.toggleMake,
        ),
        _buildSingleDropdown(
          label: "Vehicle Age Group",
          options: mstState.vehicleAgeGroupOptions,
          selectedOptions: mstState.selectedVehicleAgeGroup,
          onChanged: mstNotifier.toggleVehicleAgeGroup,
        ),
        _buildSingleDropdown(
          label: "Seating Capacity",
          options: mstState.seatingCapacityOptions,
          selectedOptions: mstState.selectedSeatingCapacity,
          onChanged: mstNotifier.toggleSeatingCapacity,
        ),
      ],

      if (productGroup == "retail health") ...[
        _buildSingleDropdown(
          label: "Age Group",
          options: mstState.ageGroupOptions,
          selectedOptions: mstState.selectedAgeGroup,
          onChanged: mstNotifier.toggleAgeGroup,
        ),
        _buildSingleDropdown(
          label: "Family Size",
          options: mstState.familySizeOptions,
          selectedOptions: mstState.selectedFamilySize,
          onChanged: mstNotifier.toggleFamilySize,
        ),
        _buildSingleDropdown(
          label: "Sum Insured Band",
          options: mstState.sumInsuredBandOptions,
          selectedOptions: mstState.selectedSumInsuredBand,
          onChanged: mstNotifier.toggleSumInsuredBand,
        ),
        _buildSingleDropdown(
          label: "Pre Existing",
          options: mstState.preExistingOptions,
          selectedOptions: mstState.selectedPreExisting,
          onChanged: mstNotifier.togglePreExisting,
        ),
      ],

      if (productGroup == "commercial lines") ...[
        _buildSingleDropdown(
          label: "Occupancy",
          options: mstState.occupancyOptions,
          selectedOptions: mstState.selectedOccupancy,
          onChanged: mstNotifier.toggleOccupancy,
        ),
        _buildSingleDropdown(
          label: "Sum Insured",
          options: mstState.sumInsuredOptions,
          selectedOptions: mstState.selectedSumInsured,
          onChanged: mstNotifier.toggleSumInsured,
        ),
      ],

      if (productGroup == "gmc/gpa") ...[
        _buildSingleDropdown(
          label: "Life Group",
          options: mstState.lifeGroupOptions,
          selectedOptions: mstState.selectedLifeGroup,
          onChanged: mstNotifier.toggleLifeGroup,
        ),
      ],

      if (productGroup == "others") ...[
        _buildSingleDropdown(
          label: "Sum Insured Band",
          options: mstState.sumInsuredBandOptions,
          selectedOptions: mstState.selectedSumInsuredBand,
          onChanged: mstNotifier.toggleSumInsuredBand,
        ),
      ],
    ],
  );
}
}
