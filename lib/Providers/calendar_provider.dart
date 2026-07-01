import 'package:flutter_bottom_nav/Providers/calendar_filter_provider.dart';
import 'package:flutter_bottom_nav/Providers/calendarrepositoryprovider.dart';
import 'package:flutter_bottom_nav/Providers/calprovider.dart';
import 'package:flutter_bottom_nav/models/calendardaycount.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarNotifier
    extends StateNotifier<AsyncValue<List<CalendarDayCount>>> {
  final Ref ref;

  // CalendarNotifier(this.ref) : super(const AsyncLoading()) {
  //   loadData();
  // }
  //for filter
  CalendarNotifier(this.ref) : super(const AsyncLoading()) {
    // First time load when page opens
    loadData();

    // When radio filter changes db called


//commented by rahul one 25 June for filter state
    // ref.listen(calendarFilterProvider, (previous, next) {
    //   print("===== FILTER PROVIDER CHANGED =====");
    //   print("PREV Zone: ${previous?.zone}");
    //   print("NEXT Zone: ${next.zone}");
    //   print("NEXT Region: ${next.region}");
    //   print("NEXT Branch: ${next.branch}");
    //   loadData(forceRefresh: false);
    // });

    // // When month changes → call API again
    // ref.listen(currentMonthProvider, (previous, next) {
    //   loadData();
    // });

    //changed by rahul for getting the data for month switching
    ref.listen<DateTime>(currentMonthProvider, (previous, next) {
      if (previous?.year != next.year || previous?.month != next.month) {
        refresh();
      }
    });
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    try {
      final filters = ref.read(calendarFilterProvider);

      print("========== CALENDAR NOTIFIER ==========");
      print("Zone: ${filters.zone}");
      print("Region: ${filters.region}");
      print("Branch: ${filters.branch}");
      print("Agent: ${filters.agent}");
      print("LeadType: ${filters.leadType}");
      print("======================================");
      final monthStart = ref.read(currentMonthProvider);
      final repo = ref.read(calendarRepositoryProvider);

      final data = await repo.getCalendarData(
        monthStartDate: monthStart,
        filters: filters,
        forceRefresh: forceRefresh,
      );

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  //await loadData();
  Future<void> refresh() async {
    try {
      final filters = ref.read(calendarFilterProvider);
      print("========== REFRESH FILTERS ==========");
      print("Zone: ${filters.zone}");
      print("Region: ${filters.region}");
      print("Branch: ${filters.branch}");
      print("Agent: ${filters.agent}");
      print("LeadType: ${filters.leadType}");
      print("====================================");
      final monthStart = ref.read(currentMonthProvider);
      final repo = ref.read(calendarRepositoryProvider);

      final data = await repo.getCalendarData(
        monthStartDate: monthStart,
        filters: filters,
        forceRefresh: true,
      );

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, AsyncValue<List<CalendarDayCount>>>(
      (ref) => CalendarNotifier(ref),
    );
