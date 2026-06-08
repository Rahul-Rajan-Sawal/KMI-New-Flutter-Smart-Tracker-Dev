import 'package:flutter_bottom_nav/core/apicall/async_get_CalendarData.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/CalendarFilterState.dart';
import 'package:flutter_bottom_nav/models/calendardaycount.dart';

class CalendarRepository {
  final dbHelper = DatabaseHelper.instance;

  // 1️⃣ MAIN ENTRY POINT (USED BY PROVIDER)
  //
  // FLOW:
  // 1. Check DB for selected month
  // 2. If data exists → return directly (NO API)
  // 3. If empty → call API → save → return DB data
  //
  Future<List<CalendarDayCount>> getCalendarData({
    required DateTime monthStartDate,
    required CalendarFilterState filters,
    bool forceRefresh = false,
  }) async {
    // STEP 1: Try loading from DB first (FAST PATH)
    final dbData = await _getFromDB(monthStartDate, filters);

    // ✔ If DB already has data → return immediately
    // if (dbData.isNotEmpty) {
    //   return dbData;
    // }

    if (!forceRefresh && dbData.isNotEmpty) {
      
      return dbData;
    }

    // STEP 2: If DB is empty → fetch from API
    await _syncFromApi(monthStartDate);

    // STEP 3: After saving → read again from DB
    return await _getFromDB(monthStartDate, filters);
  }

  Future<void> _syncFromApi(DateTime month) async {
    final db = await dbHelper.database;

    // Format month: 2026-05-01
    final curMonth =
        "${month.year}-${month.month.toString().padLeft(2, '0')}-01";

    // 🔵 CALL API
    final apiData = await AsyncGetCalendardata().getCalendarData(
      SAPCode: StaticVariables.mSAPCode,
      curMonth: curMonth,
    );

    // =====================================================
    // DELETE OLD MONTH DATA (ANDROID STYLE BEHAVIOR)

    // IMPORTANT:
    // We remove only that month so other months stay safe
    //
    await db.delete(
      "CalendarData_Mob",
      where: "mdate LIKE ?",
      whereArgs: ["${month.year}-${month.month.toString().padLeft(2, '0')}%"],
    );

    final countResulttt = await db.rawQuery(
      'SELECT COUNT(*) as count FROM CalendarData_Mob',
    );
    print("TOTAL RECORDS IN DB: ${countResulttt.first['count']}");

    // INSERT FRESH API DATA INTO SQLITE
    for (final item in apiData) {
      await db.insert("CalendarData_Mob", {
        "UserId": item.userId,
        "AgentCode": item.agentCode,
        "AgentName": item.agentName,
        "date": item.date,
        "TotalLeads": item.totalLeads,
        "WIPLeads": item.wipLeads,
        "LeadConverted": item.leadConverted,
        "LeadLost": item.leadLost,
        "Zone": item.zone,
        "Region": item.region,
        "SMName": item.smName,
        "SMBranchName": item.smBranchName,
        "LeadType": item.leadType,
        "mdate": item.mdate,
        "SyncStatus": "1",
      });
    }
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM CalendarData_Mob',
    );
    print("TOTAL RECORDS IN DB: ${countResult.first['count']}");

    final result = await db.rawQuery(
      'SELECT DISTINCT LeadType FROM CalendarData_Mob',
    );

    for (final row in result) {
      print('LeadType: ${row['LeadType']}');
    }
  }

  //  READ FROM DATABASE (GROUPED BY DATE)

  // FLOW:
  // 1. Read raw rows from SQLite
  // 2. Group by date
  // 3. Aggregate counts per day
  // 4. Return List<CalendarDayCount>

  Future<List<CalendarDayCount>> _getFromDB(
    DateTime month,
    CalendarFilterState filters,
  ) async {
    final db = await dbHelper.database;

    // Load only selected month data
    //Commented for appplying the radio filters
    // final result = await db.query(
    //   "CalendarData_Mob",
    //   where: "mdate LIKE ?",
    //   whereArgs: ["${month.year}-${month.month.toString().padLeft(2, '0')}%"],
    // );

    //new added for radio filter
    // BASE MONTH FILTER
    String whereClause = "mdate LIKE ?";
    List<dynamic> whereArgs = [
      "${month.year}-${month.month.toString().padLeft(2, '0')}%",
    ];

    // 🔥 ADD RADIO FILTER
    if (filters.leadType == 1) {
      // LEADS selected
      whereClause += " AND LeadType != ?";
      whereArgs.add('L');
    } else if (filters.leadType == 2) {
      // CONTACT selected
      whereClause += " AND LeadType = ?";
      whereArgs.add('L');
    }

    // FINAL QUERY
    final result = await db.query(
      "CalendarData_Mob",
      where: whereClause,
      whereArgs: whereArgs,
    );

    // GROUPING LOGIC
    Map<DateTime, CalendarDayCount> grouped = {};

    for (final row in result) {
      final dateStr = row["date"] as String?;
      if (dateStr == null) continue;

      // Convert: 31-05-2026 → DateTime(2026, 5, 31)
      final parts = dateStr.split('-');

      final parsedDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      final key = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      // Parse values safely
      final totalLeads = int.tryParse(row["TotalLeads"].toString()) ?? 0;
      final wipLeads = int.tryParse(row["WIPLeads"].toString()) ?? 0;
      final leadConverted = int.tryParse(row["LeadConverted"].toString()) ?? 0;
      final leadLost = int.tryParse(row["LeadLost"].toString()) ?? 0;

      // If same date exists → ADD values
      if (grouped.containsKey(key)) {
        final old = grouped[key]!;

        grouped[key] = CalendarDayCount(
          date: key,

          // total count per day
          count: old.count + totalLeads,

          // full aggregation
          totalLeads: old.totalLeads + totalLeads,
          wipLeads: old.wipLeads + wipLeads,
          leadConverted: old.leadConverted + leadConverted,
          leadLost: old.leadLost + leadLost,
        );
      } else {
        // First entry for that date
        grouped[key] = CalendarDayCount(
          date: key,
          count: totalLeads,
          totalLeads: totalLeads,
          wipLeads: wipLeads,
          leadConverted: leadConverted,
          leadLost: leadLost,
        );
      }
    }

    return grouped.values.toList();
  }

  // 4️⃣ REFRESH FUNCTION (CALLED FROM UI BUTTON)
  // FLOW:
  // 1. Delete selected month data
  // 2. Call API
  // 3. Save fresh data
  //
  Future<void> refreshCalendarData(DateTime month) async {
    await _syncFromApi(month);
  }
}
