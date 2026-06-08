import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/Calendar/filter_option.dart';

class FilterRepository {
  final dbHelper = DatabaseHelper.instance;

  // REGION First dropdown

  Future<List<FilterOption>> getRegions() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT DISTINCT Region
      FROM CalendarData_Mob
      WHERE Region IS NOT NULL AND Region != ''
      ORDER BY Region
    ''');

    return result.map((row) {
      final value = row['Region'].toString();
      return FilterOption(code: value, description: value);
    }).toList();
  }

  //ZONE Depends on Region

  Future<List<FilterOption>> getZones(String regionCode) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT Zone
      FROM CalendarData_Mob
      WHERE Region = ?
      AND Zone IS NOT NULL AND Zone != ''
      ORDER BY Zone
    ''',
      [regionCode],
    );

    return result.map((row) {
      final value = row['Zone'].toString();
      return FilterOption(code: value, description: value);
    }).toList();
  }

  // BRANCH Depends on Region + Zone
  Future<List<FilterOption>> getBranches({
    required String regionCode,
    required String zoneCode,
  }) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT SMBranchName
      FROM CalendarData_Mob
      WHERE Region = ?
      AND Zone = ?
      AND SMBranchName IS NOT NULL AND SMBranchName != ''
      ORDER BY SMBranchName
    ''',
      [regionCode, zoneCode],
    );

    return result.map((row) {
      final value = row['SMBranchName'].toString();
      return FilterOption(code: value, description: value);
    }).toList();
  }

  //  SM Depends on Region + Zone + Branch

  Future<List<FilterOption>> getSMs({
    required String regionCode,
    required String zoneCode,
    required String branchCode,
  }) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT SMName
      FROM CalendarData_Mob
      WHERE Region = ?
      AND Zone = ?
      AND SMBranchName = ?
      AND SMName IS NOT NULL AND SMName != ''
      ORDER BY SMName
    ''',
      [regionCode, zoneCode, branchCode],
    );

    return result.map((row) {
      final value = row['SMName'].toString();
      return FilterOption(code: value, description: value);
    }).toList();
  }

  //  AGENT (Depends on Region + Zone + Branch + SM)
  Future<List<FilterOption>> getAgents({
    required String regionCode,
    required String zoneCode,
    required String branchCode,
    required String smName,
  }) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT AgentName, AgentCode
      FROM CalendarData_Mob
      WHERE Region = ?
      AND Zone = ?
      AND SMBranchName = ?
      AND SMName = ?
      AND AgentName IS NOT NULL AND AgentName != ''
      ORDER BY AgentName
    ''',
      [regionCode, zoneCode, branchCode, smName],
    );

    return result.map((row) {
      return FilterOption(
        code: row['AgentCode'].toString(),
        description: row['AgentName'].toString(),
      );
    }).toList();
  }

  Future<Map<String, List<FilterOption>>> getAllLookupOptions() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
    SELECT LookUpCode, ParamDesc1, SortOrder
    FROM LookUpSU
    WHERE LookUpCode IS NOT NULL
    AND TRIM(LookUpCode) != ''
    AND ParamDesc1 IS NOT NULL
    AND TRIM(ParamDesc1) != ''
    AND UPPER(TRIM(ParamDesc1)) != 'NA'
    AND LOWER(TRIM(ParamDesc1)) != 'null'
    ORDER BY LookUpCode, CAST(SortOrder AS INTEGER)
  ''');

    final Map<String, List<FilterOption>> lookupCache = {};

    for (final row in result) {
      final lookupCode = row['LookUpCode']?.toString() ?? '';
      final value = row['ParamDesc1']?.toString() ?? '';

      if (lookupCode.isEmpty || value.isEmpty) continue;

      lookupCache.putIfAbsent(lookupCode, () => []);

      lookupCache[lookupCode]!.add(
        FilterOption(code: value, description: value),
      );
    }

    return lookupCache;
  }

  Future<List<FilterOption>> getVehicleMakes() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
    SELECT DISTINCT Make_ID_PK, Make_Name
    FROM Make_Master
    WHERE Make_Name IS NOT NULL
    AND TRIM(Make_Name) != ''
    AND UPPER(TRIM(Make_Name)) != 'NA'
    AND LOWER(TRIM(Make_Name)) != 'null'
    ORDER BY Make_Name ASC
  ''');

    return result.map((row) {
      return FilterOption(
        code: row['Make_ID_PK']?.toString() ?? '',
        description: row['Make_Name']?.toString() ?? '',
      );
    }).toList();
  }

  List<FilterOption> getCachedLookupOptions(
    Map<String, List<FilterOption>> lookupCache,
    String lookupCode,
  ) {
    return lookupCache[lookupCode] ?? [];
  }

  Map<String, List<FilterOption>> getDynamicProductDropdownsFromCache({
    required String productGroup,
    required Map<String, List<FilterOption>> lookupCache,
    required List<FilterOption> makeOptions,
  }) {
    final group = productGroup.trim().toLowerCase();

    switch (group) {
      case 'pvt':
        return {
          'nilDep': getCachedLookupOptions(lookupCache, 'NilDep'),
          'category': getCachedLookupOptions(lookupCache, 'CustomerCategory'),
          'fuelType': getCachedLookupOptions(lookupCache, 'FuelType'),
          'make': makeOptions,
          'vehicleAgeGroup': getCachedLookupOptions(
            lookupCache,
            'VehicleAgegrp',
          ),
        };

      case '2w':
        return {
          'nilDep': getCachedLookupOptions(lookupCache, 'NilDep'),
          'mopedType': getCachedLookupOptions(lookupCache, 'MopedType'),
          'make': makeOptions,
          'vehicleAgeGroup': getCachedLookupOptions(
            lookupCache,
            'VehicleAgegrp',
          ),
        };

      case 'pcv':
      case 'gcv':
        return {
          'nilDep': getCachedLookupOptions(lookupCache, 'NilDep'),
          'gvw': getCachedLookupOptions(lookupCache, 'GVWMaster'),
          'make': makeOptions,
          'vehicleAgeGroup': getCachedLookupOptions(
            lookupCache,
            'VehicleAgegrp',
          ),
          'seatingCapacity': getCachedLookupOptions(lookupCache, 'Seating'),
        };

      case 'retail health':
        return {
          'ageGroup': getCachedLookupOptions(lookupCache, 'AgegrpHealth'),
          'familySize': getCachedLookupOptions(lookupCache, 'FamilySize'),
          'sumInsuredBand': getCachedLookupOptions(
            lookupCache,
            'SuminsuredBandHealth',
          ),
          'preExisting': getCachedLookupOptions(lookupCache, 'Preexiting'),
        };

      case 'commercial lines':
        return {
          'occupancy': getCachedLookupOptions(lookupCache, 'Occupancy'),
          'sumInsured': getCachedLookupOptions(
            lookupCache,
            'SICommerciallines',
          ),
        };

      case 'gmc/gpa':
        return {'lifeGroup': getCachedLookupOptions(lookupCache, 'LifeGrp')};

      case 'others':
        return {
          'sumInsuredBand': getCachedLookupOptions(lookupCache, 'SIothers'),
        };

      default:
        return {};
    }
  }
}
