import 'package:flutter_bottom_nav/models/Calendar/filter_option.dart';

class CalMstFilterState {
  final bool isLoading;

  final List<FilterOption> zones;
  final List<FilterOption> regions;
  final List<FilterOption> agents;
  final List<FilterOption> references;
  final List<FilterOption> renewalYearCounts;

  final List<FilterOption> selectedZones;
  final List<FilterOption> selectedRegions;
  final List<FilterOption> selectedAgents;
  final List<FilterOption> selectedReferences;
  final List<FilterOption> selectedRenewalYearCounts;

  const CalMstFilterState({
    this.isLoading = false,
    this.zones = const [],
    this.regions = const [],
    this.agents = const [],
    this.references = const [],
    this.renewalYearCounts = const [],
    this.selectedZones = const [],
    this.selectedRegions = const [],
    this.selectedAgents = const [],
    this.selectedReferences = const [],
    this.selectedRenewalYearCounts = const [],
  });

  CalMstFilterState copyWith({
    bool? isLoading,
    List<FilterOption>? zones,
    List<FilterOption>? regions,
    List<FilterOption>? agents,
    List<FilterOption>? references,
    List<FilterOption>? renewalYearCounts,
    List<FilterOption>? selectedZones,
    List<FilterOption>? selectedRegions,
    List<FilterOption>? selectedAgents,
    List<FilterOption>? selectedReferences,
    List<FilterOption>? selectedRenewalYearCounts,
  }) {
    return CalMstFilterState(
      isLoading: isLoading ?? this.isLoading,
      zones: zones ?? this.zones,
      regions: regions ?? this.regions,
      agents: agents ?? this.agents,
      references: references ?? this.references,
      renewalYearCounts: renewalYearCounts ?? this.renewalYearCounts,
      selectedZones: selectedZones ?? this.selectedZones,
      selectedRegions: selectedRegions ?? this.selectedRegions,
      selectedAgents: selectedAgents ?? this.selectedAgents,
      selectedReferences: selectedReferences ?? this.selectedReferences,
      selectedRenewalYearCounts:
          selectedRenewalYearCounts ?? this.selectedRenewalYearCounts,
    );
  }
}