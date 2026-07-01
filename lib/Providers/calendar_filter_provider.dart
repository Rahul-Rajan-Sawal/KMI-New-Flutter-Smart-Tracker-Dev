import 'package:flutter_bottom_nav/models/CalendarFilterState.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarFilterNotifier extends StateNotifier<CalendarFilterState> {
  CalendarFilterNotifier() : super(const CalendarFilterState());

  /// Apply button  replace entire filter state
  void setFilters(CalendarFilterState newFilters) {
    print("SET FILTERS CALLED");
    print(newFilters.zone);
    print(newFilters.region);
    print(newFilters.branch);
    state = newFilters;
    print("PROVIDER STATE AFTER SET");
    print(state.zone);
    print(state.region);
    print(state.branch);
  }

  /// Reset button → clear all filters
  void clearFilters() {
    state = const CalendarFilterState();
  }

  void updateLeadType(int type) {
    state = state.copyWith(leadType: type);
  }

  /// Optional helpers to update single filters
  void updateZone(List<String> zones) {
    state = state.copyWith(zone: zones);
  }

  void updateRegion(List<String> regions) {
    state = state.copyWith(region: regions);
  }

  void updateBranch(List<String> branches) {
    state = state.copyWith(branch: branches);
  }

  void updateAgent(List<String> agents) {
    state = state.copyWith(agent: agents);
  }

  void updateProduct(List<String> products) {
    state = state.copyWith(product: products);
  }

  //added for not methods errors in filter calendar activity

  void setPeriod(String value) {
    state = state.copyWith(period: [value]);
  }

  void toggleZone(String zoneValue) {
    final updated = [...state.zone];

    if (updated.contains(zoneValue)) {
      updated.remove(zoneValue);
    } else {
      updated.add(zoneValue);
    }

    state = state.copyWith(zone: updated);
  }

  void toggleRegion(String regionValue) {
    final updated = [...state.region];

    if (updated.contains(regionValue)) {
      updated.remove(regionValue);
    } else {
      updated.add(regionValue);
    }

    state = state.copyWith(region: updated);
  }

  void setBranch(String value) {
    state = state.copyWith(branch: [value]);
  }
}

/// Global provider accessible from entire app
final calendarFilterProvider =
    StateNotifierProvider<CalendarFilterNotifier, CalendarFilterState>(
      (ref) => CalendarFilterNotifier(),
    );
