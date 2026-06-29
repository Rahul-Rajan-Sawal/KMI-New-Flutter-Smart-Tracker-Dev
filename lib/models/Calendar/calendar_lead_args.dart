import 'package:flutter_bottom_nav/models/CalendarFilterState.dart';

class CalendarLeadArgs {
  final DateTime selectedDate;
  final int expectedCount;
  final String businessType;
  final CalendarFilterState filters;

  const CalendarLeadArgs({
    required this.selectedDate,
    required this.expectedCount,
    required this.businessType,
    required this.filters,
  });
}
