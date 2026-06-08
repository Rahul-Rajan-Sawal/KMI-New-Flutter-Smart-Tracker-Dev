import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bottom_nav/core/repository/calendar/calendar_repository.dart';

/// Repository Dependency Injection (DI layer)
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
}); 