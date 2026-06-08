class CalendarDayCount {
  final DateTime date;
  final int count;
  final int totalLeads;
  final int wipLeads;
  final int leadConverted;
  final int leadLost;

  CalendarDayCount({
    required this.date,
    required this.count,
    required this.totalLeads,
    required this.wipLeads,
    required this.leadConverted,
    required this.leadLost,
  });
}
