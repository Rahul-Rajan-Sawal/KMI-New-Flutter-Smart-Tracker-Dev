import 'package:flutter_bottom_nav/Providers/calendarrepositoryprovider.dart';
import 'package:flutter_bottom_nav/Providers/calprovider.dart';
import 'package:flutter_bottom_nav/models/calendardaycount.dart';
import 'package:flutter_bottom_nav/providers/calendar_filter_provider.dart';
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
    ref.listen(calendarFilterProvider, (previous, next) {
       loadData();
    });

    // When month changes → call API again
    ref.listen(currentMonthProvider, (previous, next) {
      loadData();
    });
  }

  Future<void> loadData() async {
    try {
      final filters = ref.read(calendarFilterProvider);
      final monthStart = ref.read(currentMonthProvider);
      final repo = ref.read(calendarRepositoryProvider);

      final data = await repo.getCalendarData(
        monthStartDate: monthStart,
        filters: filters,
        forceRefresh: false,
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
