import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/calendar_leaddetails.dart';
import 'package:flutter_bottom_nav/Activities/filteractivity_calendar.dart';
import 'package:flutter_bottom_nav/Providers/calendar_filter_provider.dart';
import 'package:flutter_bottom_nav/Providers/calendar_provider.dart';
import 'package:flutter_bottom_nav/Providers/calprovider.dart';
import 'package:flutter_bottom_nav/core/apicall/async_getDashboardParam.dart';
import 'package:flutter_bottom_nav/core/repository/commonrepo.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/models/Calendar/calendar_lead_args.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarScreenState();

  // @override
  // State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int _selectedButton = 1;
  String _currentDate = "Loading...";
  String _currentTiming = "Loading...";

  //  String selectedFilter = "Option1";

  DateTime normalize(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  late DateTime firstDate;
  late DateTime lastDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    firstDate = DateTime(now.year, now.month - 2, 1);
    lastDate = DateTime(now.year, now.month + 3, 0);

    _focusedDay = now;
  }

  void _refreshData() {
    //ref.invalidate(calendarDataProvider);
    //ref.watch(calendarProvider);
    ref.read(calendarProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(
      calendarProvider,
    ); // ref.watch(calendarDataProvider);
    final filterState = ref.watch(calendarFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),

        data: (data) {
          final Map<DateTime, int> dayCounts = {};
          final Map<DateTime, int> convertedMap = {};
          final Map<DateTime, int> wipMap = {};
          final Map<DateTime, int> lostMap = {};

          int totalLeads = 0;
          int convertedLeads = 0;
          int wipLeads = 0;
          int lostLeads = 0;

          for (final item in data) {
            final d = normalize(item.date);

            // Daily counts for calendar
            dayCounts[d] = (dayCounts[d] ?? 0) + item.totalLeads;

            convertedMap[d] = (convertedMap[d] ?? 0) + item.leadConverted;
            wipMap[d] = (wipMap[d] ?? 0) + item.wipLeads;
            lostMap[d] = (lostMap[d] ?? 0) + item.leadLost;

            // Global totals (for top card)
            totalLeads += item.totalLeads;
            convertedLeads += item.leadConverted;
            wipLeads += item.wipLeads;
            lostLeads += item.leadLost;
          }

          // ==========================================================
          // 🔥 UI START
          // ==========================================================

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 14),

                Card(
                  color: const Color(0xFFE9E9E9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCardItem("Showing Date", _currentDate),
                        _buildCardItem("Timing", _currentTiming),
                        _buildIcon(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // ===================== TOP SUMMARY CARD =====================
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF090979), Color(0xFF00D4FF)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Total Leads",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              totalLeads.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 2),

                            const Text(
                              "Total WIP renewal lead of selected month",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _statusText(
                                      "Converted",
                                      convertedLeads,
                                    ),
                                  ),

                                  Expanded(
                                    child: _statusText("WIP Lead", wipLeads),
                                  ),

                                  Expanded(
                                    child: _statusText("Lead Lost", lostLeads),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 1),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildRadioItem("All", 0),
                                _buildRadioItem("Contact", 1),
                                _buildRadioItem("Lead", 2),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Card(
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   elevation: 4,
                //   child: Container(
                //     padding: const EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       gradient: const LinearGradient(
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //         colors: [Color(0xFF090979), Color(0xFF00D4FF)],
                //       ),
                //       borderRadius: BorderRadius.circular(16),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         const Text(
                //           "Total Leads",
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontWeight: FontWeight.bold,
                //             fontSize: 16,
                //           ),
                //         ),

                //         const SizedBox(height: 8),

                //         Text(
                //           totalLeads.toString(),
                //           style: const TextStyle(
                //             color: Colors.white,
                //             fontSize: 30,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),

                //         const SizedBox(height: 8),

                //         const Text(
                //           "Total WIP renewal lead of selected month",
                //           textAlign: TextAlign.center,
                //           style: TextStyle(
                //             color: Colors.white70,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),

                //         const SizedBox(height: 16),

                //         Container(
                //           padding: const EdgeInsets.symmetric(
                //             vertical: 10,
                //             horizontal: 12,
                //           ),
                //           decoration: BoxDecoration(
                //             color: Colors.white.withOpacity(0.15),
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Expanded(
                //                 child: _statusText("Converted", convertedLeads),
                //               ),

                //               Expanded(
                //                 child: _statusText("WIP Lead", wipLeads),
                //               ),

                //               Expanded(
                //                 child: _statusText("Lead Lost", lostLeads),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // const SizedBox(height: 10),

                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     children: [
                //       _buildRadioItem("All", 1, ),
                //       _buildRadioItem("Contact", 2),
                //       _buildRadioItem("Lead", 3),
                //     ],
                //   ),

                // ),
                const SizedBox(height: 10),

                // Refresh Card
                Card(
                  color: const Color(0xFFE9E9E9),
                  child: InkWell(
                    onTap: _refreshData,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.loop, color: Colors.red[900], size: 30),
                          const SizedBox(width: 10),
                          const Text(
                            "Refresh",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // CALENDAR
                TableCalendar(
                  firstDay: firstDate,
                  lastDay: lastDate,
                  focusedDay: _focusedDay,

                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),

                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  // selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                  // onDaySelected: (selected, focused) {
                  //   setState(() {
                  //     _selectedDay = selected;
                  //     _focusedDay = focused;
                  //   });
                  // },
                  onDaySelected: (selectedDay, focusedDay) {
                    final normalizedDate = normalize(selectedDay);
                    final selectedDateCount = dayCounts[normalizedDate] ?? 0;

                    // Android also opens the page only when the date has leads.
                    if (selectedDateCount <= 0) {
                      return;
                    }

                    setState(() {
                      _focusedDay = focusedDay;
                    });

                    final currentFilters = ref.read(calendarFilterProvider);

                    final leadArgs = CalendarLeadArgs(
                      selectedDate: normalizedDate,
                      expectedCount: selectedDateCount,

                      // This calendar currently displays renewal leads.
                      businessType: 'R',

                      filters: currentFilters,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Leaddetails(args: leadArgs),
                      ),
                    );
                  },

                  // onPageChanged: (focusedDay) {
                  //   _focusedDay = focusedDay;
                  // },
                  onPageChanged: (focusedDay) {
                    final firstDateOfSelectedMonth = DateTime(
                      focusedDay.year,
                      focusedDay.month,
                      1,
                    );

                    _focusedDay = firstDateOfSelectedMonth;

                    ref.read(currentMonthProvider.notifier).state =
                        firstDateOfSelectedMonth;
                  },

                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final d = normalize(date);

                      final count = dayCounts[d];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${date.day}"),

                          if (count != null)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "$count",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: 30)
                , 
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedButton = 1;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedButton == 1
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "RENEWAL",
                            style: TextStyle(
                              color: _selectedButton == 1
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 76),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedButton = 2;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedButton == 2
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "FRESH LEAD",
                            style: TextStyle(
                              color: _selectedButton == 2
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===================== MINI WIDGET =====================
  Widget _miniStat(String title, int value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 5),
        Text(
          "$value",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF17479e),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _onFilterClick() async {
    print("Filter button clicked");

    // final now = DateTime.now();

    // final year = now.year.toString();
    // final month = now.month.toString().padLeft(2, '0');

    final selectedMonth = ref.read(currentMonthProvider);

    final year = selectedMonth.year.toString();
    final month = selectedMonth.month.toString().padLeft(2, '0');

    // needs to optimize to check db first
    final response = await GetDashboardParamApi.getData(
      sapCode: StaticVariables.mSAPCode,
      branchCode: '',
      smCode: '',
      agentCode: '',
      flag: 'ZRB', //RE,SM,AG,
      filterType: 'Self',
      year: year,
      month: month,
    );
    await CommonRepo().saveZoneRegionBranch(
      response: response,
      year: year,
      month: month,
    );

    if (!mounted) return;

    final applied = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarFilterActivity(
          userId: StaticVariables.mSAPCode,
          year: year,
          month: month,
          isTeam: false,
        ),
      ),
    );

    if (applied == true && mounted) {
      print("FILTER APPLIED, RELOADING CALENDAR");

      final latestFilters = ref.read(calendarFilterProvider);

      print("CALENDAR SCREEN AFTER POP");
      print("Zone: ${latestFilters.zone}");
      print("Region: ${latestFilters.region}");
      print("Branch: ${latestFilters.branch}");
      print("Agent: ${latestFilters.agent}");

      ref.read(calendarProvider.notifier).loadData(forceRefresh: false);
    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CalendarFilterActivity(
    //       userId: StaticVariables.mSAPCode,
    //       year: year,
    //       month: month,
    //       isTeam: false,
    //     ),
    //   ),
    // );
  }

  Widget _buildIcon() {
    return InkWell(
      onTap: _onFilterClick,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Filter",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF17479e),
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.filter_list, size: 20, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _statusText(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioItem(String title, int value) {
    final filterState = ref.watch(calendarFilterProvider);

    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: filterState.leadType,
          activeColor: Colors.white,
          onChanged: (val) {
            // Update filter state
            ref
                .read(calendarFilterProvider.notifier)
                .setFilters(filterState.copyWith(leadType: val!));

            // Refresh calendar data using new filter
            ref.read(calendarProvider.notifier).refresh();

            // ref
            //     .read(calendarFilterProvider.notifier)
            //     .setFilters(filterState.copyWith(leadType: val!));

            // refresh API automatically
            // ref.invalidate(calendarDataProvider);
          },
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
