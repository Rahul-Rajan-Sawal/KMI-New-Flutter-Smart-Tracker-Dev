import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/async_getDashboardParam.dart';
import 'package:flutter_bottom_nav/core/repository/commonrepo.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';
import 'package:flutter_bottom_nav/models/Calendar/filter_option.dart';
import 'package:path/path.dart' as selectedBranches;

class FilterRepository {
  final dbHelper = DatabaseHelper.instance;
  final OdbHelper = OfflineDBHelper.getDatabase();
  String get currentYear => DateTime.now().year.toString();

  String get currentMonth => DateTime.now().month.toString().padLeft(2, '0');

  String get currentDate {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _placeholders(int count) => List.filled(count, '?').join(',');

  String _valid(String column) {
    return '''
      $column IS NOT NULL
      AND TRIM($column) != ''
      AND LOWER(TRIM($column)) != 'null'
      AND UPPER(TRIM($column)) != 'NA'
    ''';
  }

  List<FilterOption> _mapOptions(
    List<Map<String, Object?>> rows,
    String codeColumn,
    String descColumn, {
    bool addAll = false,
  }) {
    final options = <FilterOption>[];

    if (addAll) {
      options.add(const FilterOption(code: 'All', description: 'All'));
    }

    for (final row in rows) {
      final code = row[codeColumn]?.toString().trim() ?? '';
      final desc = row[descColumn]?.toString().trim() ?? code;

      if (code.isEmpty || desc.isEmpty) continue;
      if (code.toLowerCase() == 'null' || desc.toLowerCase() == 'null') {
        continue;
      }
      if (code.toUpperCase() == 'NA' || desc.toUpperCase() == 'NA') {
        continue;
      }

      if (!options.any((e) => e.code == code)) {
        options.add(FilterOption(code: code, description: desc));
      }
    }

    return options;
  }

  Future<List<FilterOption>> getZones({
    required String userId,
    required String year,
    required String month,
  }) async {
    final db = await dbHelper.database;

    final resultts = await db.rawQuery('''SELECT DISTINCT Zone
      FROM Tbl_ZoneRegionBranch''');
    print(resultts);

    final encryptedUserId = CommonUtil.encryptIfNotEmpty(userId);
    final encryptedYear = CommonUtil.encryptIfNotEmpty(year);
    final encryptedMonth = CommonUtil.encryptIfNotEmpty(month);

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT Zone
      FROM Tbl_ZoneRegionBranch
      WHERE RMCode = ?
      AND Year = ?
      AND Month = ?
      AND ${_valid('Zone')}
      ORDER BY Zone
      ''',
      [encryptedUserId, encryptedYear, encryptedMonth],

      //[userId, year, month],
    );
    print(" Zones Print : $result");
    print(result);

    //    CommonUtil.decryptIfNotEmpty(result);
    final decryptedZones = result.map((row) {
      final encryptedZone = row['Zone']?.toString() ?? '';
      final zone = CommonUtil.decryptIfNotEmpty(encryptedZone);

      return {'Zone': zone};
    }).toList();

    print("Decrypted Zones Print: $decryptedZones");

    return _mapOptions(decryptedZones, 'Zone', 'Zone', addAll: true);

    //return _mapOptions(result, 'Zone', 'Zone', addAll: true);
  }

  Future<List<FilterOption>> getRegions({
    required String userId,
    required String year,
    required String month,
    required List<String> selectedZones,
  }) async {
    if (selectedZones.isEmpty) return [];

    final zones = selectedZones.where((e) => e != 'All').toList();
    final db = await dbHelper.database;

    final encryptedUserId = CommonUtil.encryptIfNotEmpty(userId);
    final encryptedYear = CommonUtil.encryptIfNotEmpty(year);
    final encryptedMonth = CommonUtil.encryptIfNotEmpty(month);

    final result = zones.isEmpty
        ? await db.rawQuery(
            '''
            SELECT DISTINCT Region
            FROM Tbl_ZoneRegionBranch
            WHERE RMCode = ?
            AND Year = ?
            AND Month = ?
            AND ${_valid('Region')}
            ORDER BY Region
            ''',

            ///[userId, year, month],
            [encryptedUserId, encryptedYear, encryptedMonth],
          )
        : await db.rawQuery(
            '''
            SELECT DISTINCT Region
            FROM Tbl_ZoneRegionBranch
            WHERE RMCode = ?
            AND Year = ?
            AND Month = ?
            AND Zone IN (${_placeholders(zones.length)})
            AND ${_valid('Region')}
            ORDER BY Region
            ''',
            [
              encryptedUserId,
              encryptedYear,
              encryptedMonth,
              ...zones.map((zone) => CommonUtil.encryptIfNotEmpty(zone)),
            ],
            //[userId, year, month, ...zones],
          );
    final decryptedRegions = result.map((row) {
      final encryptedRegion = row['Region']?.toString() ?? '';
      final region = CommonUtil.decryptIfNotEmpty(encryptedRegion);

      return {'Region': region};
    }).toList();

    print("Decrypted Regions Print: $decryptedRegions");

    return _mapOptions(decryptedRegions, 'Region', 'Region', addAll: true);

    //return _mapOptions(result, 'Region', 'Region', addAll: true);
  }

  Future<List<FilterOption>> getBranches({
    required String userId,
    required String year,
    required String month,
    required List<String> selectedRegions,
    bool isTeam = false,
  }) async {
    if (selectedRegions.isEmpty) return [];

    final regions = selectedRegions.where((e) => e != 'All').toList();
    final db = await dbHelper.database;

    final encryptedUserId = CommonUtil.encryptIfNotEmpty(userId);
    final encryptedYear = CommonUtil.encryptIfNotEmpty(year);
    final encryptedMonth = CommonUtil.encryptIfNotEmpty(month);

    final result = regions.isEmpty
        ? await db.rawQuery(
            '''
            SELECT DISTINCT BranchCode, BranchName
            FROM Tbl_ZoneRegionBranch
            WHERE RMCode = ?
            AND Year = ?
            AND Month = ?
            AND ${_valid('BranchCode')}
            AND ${_valid('BranchName')}
            ORDER BY BranchName
            ''',
            [encryptedUserId, encryptedYear, encryptedMonth],
          )
        : await db.rawQuery(
            '''
            SELECT DISTINCT BranchCode, BranchName
            FROM Tbl_ZoneRegionBranch
            WHERE RMCode = ?
            AND Year = ?
            AND Month = ?
            AND Region IN (${_placeholders(regions.length)})
            AND ${_valid('BranchCode')}
            AND ${_valid('BranchName')}
            ORDER BY BranchName
            ''',
            [
              encryptedUserId,
              encryptedYear,
              encryptedMonth,
              ...regions.map((region) => CommonUtil.encryptIfNotEmpty(region)),
            ],
          );

    final decryptedBranches = result.map((row) {
      final branchCode = CommonUtil.decryptIfNotEmpty(
        row['BranchCode']?.toString() ?? '',
      );

      final branchName = CommonUtil.decryptIfNotEmpty(
        row['BranchName']?.toString() ?? '',
      );

      return {'BranchCode': branchCode, 'BranchName': branchName};
    }).toList();

    print("Decrypted Branches Print: $decryptedBranches");

    return _mapOptions(
      decryptedBranches,
      'BranchCode',
      'BranchName',
      addAll: isTeam,
    );
    //return _mapOptions(result, 'BranchCode', 'BranchName', addAll: isTeam);
  }

  // call api and repo function for api data for Sales Manager

  Future<List<FilterOption>> getSalesManagers({
    required String userId,
    required List<String> selectedBranches,
    bool isTeam = false,
  }) async {
    final response = await GetDashboardParamApi.getData(
      sapCode: StaticVariables.mSAPCode,
      branchCode: selectedBranches.join(','),
      smCode: '',
      agentCode: '',
      flag: 'SM',
      filterType: 'Self',
      year: currentYear,
      month: currentMonth,
    );
    print(response);
    await CommonRepo().saveSalesManager(response: response);
    print(
      "--------------------Getting and saving managers----------------------------",
    );

    if (selectedBranches.isEmpty) return [];

    final branches = selectedBranches.where((e) => e != 'All').toList();
    final db = await dbHelper.database;

    final encryptedUserId = CommonUtil.encryptIfNotEmpty(userId);

    final result = branches.isEmpty
        ? await db.rawQuery(
            '''
            SELECT DISTINCT SMCode, SMName
            FROM Tbl_SalesManager
            WHERE RMCode = ?
            AND ${_valid('SMCode')}
            AND ${_valid('SMName')}
            ORDER BY SMName
            ''',
            [encryptedUserId],
          )
        : await db.rawQuery(
            '''
            SELECT DISTINCT SMCode, SMName
            FROM Tbl_SalesManager
            WHERE RMCode = ?
            AND BranchCode IN (${_placeholders(branches.length)})
            AND ${_valid('SMCode')}
            AND ${_valid('SMName')}
            ORDER BY SMName
            ''',
            [
              encryptedUserId,
              ...branches.map((branch) => CommonUtil.encryptIfNotEmpty(branch)),
            ],
          );

    final decryptedSalesManagers = result.map((row) {
      final smCode = CommonUtil.decryptIfNotEmpty(
        row['SMCode']?.toString() ?? '',
      );

      final smName = CommonUtil.decryptIfNotEmpty(
        row['SMName']?.toString() ?? '',
      );

      return {'SMCode': smCode, 'SMName': smName};
    }).toList();

    print("Decrypted Sales Managers Print: $decryptedSalesManagers");

    return _mapOptions(
      decryptedSalesManagers,
      'SMCode',
      'SMName',
      addAll: isTeam,
    );
    //return _mapOptions(result, 'SMCode', 'SMName', addAll: isTeam);
  }

  Future<List<FilterOption>> getAgents({
    required String userId,
    required List<String> selectedSalesManagers,
  }) async {
    final response = await GetDashboardParamApi.getData(
      sapCode: StaticVariables.mSAPCode,
      branchCode: selectedBranches.join(','),
      smCode: '',
      agentCode: '',
      flag: 'AG',
      filterType: 'Self',
      year: currentYear,
      month: currentMonth,
    );
    print(response);

    CommonRepo().saveAgents(response: response);
    print(
      "--------------------Getting and saving agents----------------------------",
    );
    if (selectedSalesManagers.isEmpty) return [];

    final sms = selectedSalesManagers.where((e) => e != 'All').toList();
    final db = await dbHelper.database;

    final encryptedUserId = CommonUtil.encryptIfNotEmpty(userId);

    final result = sms.isEmpty
        ? await db.rawQuery(
            '''
            SELECT DISTINCT AgentCode, AgentName
            FROM Tbl_Agent
            WHERE UserId = ?
            AND ${_valid('AgentCode')}
            AND ${_valid('AgentName')}
            ORDER BY AgentName
            ''',
            [encryptedUserId],
          )
        : await db.rawQuery(
            '''
            SELECT DISTINCT AgentCode, AgentName
            FROM Tbl_Agent
            WHERE UserId = ?
            AND SMCode IN (${_placeholders(sms.length)})
            AND ${_valid('AgentCode')}
            AND ${_valid('AgentName')}
            ORDER BY AgentName
            ''',
            [
              encryptedUserId,
              ...sms.map((smCode) => CommonUtil.encryptIfNotEmpty(smCode)),
            ],
          );

    final decryptedAgents = result.map((row) {
      final agentCode = CommonUtil.decryptIfNotEmpty(
        row['AgentCode']?.toString() ?? '',
      );

      final agentName = CommonUtil.decryptIfNotEmpty(
        row['AgentName']?.toString() ?? '',
      );

      return {'AgentCode': agentCode, 'AgentName': agentName};
    }).toList();

    print("Decrypted Agents Print: $decryptedAgents");

    return _mapOptions(decryptedAgents, 'AgentCode', 'AgentName', addAll: true);
    //return _mapOptions(result, 'AgentCode', 'AgentName', addAll: true);
  }

  Future<List<FilterOption>> getReferences({
    required String userId,
    required List<String> selectedAgents,
  }) async {
    final response = await GetDashboardParamApi.getData(
      sapCode: StaticVariables.mSAPCode,
      branchCode: '',
      smCode: '',
      agentCode: '',
      flag: 'RE', //ZRB,SM,AG,
      filterType: 'Self',
      year: currentYear,
      month: currentMonth,
    );

    print(response);
    CommonRepo().saveReference(response: response);
    print("------------------Response for reference-----------------------");

    if (selectedAgents.isEmpty) return [];

    final agents = selectedAgents.where((e) => e != 'All').toList();
    final db = await dbHelper.database;

    final encryptedUserId = CommonUtil.encryptIfNotEmpty(userId);

    final encryptedAgents = agents
        .map((e) => CommonUtil.encryptIfNotEmpty(e))
        .toList();

    final result = encryptedAgents.isEmpty
        ? await db.rawQuery(
            '''
            SELECT DISTINCT ReferenceCode, ReferenceName
            FROM Tbl_Reference
            WHERE UserId = ?
            AND ${_valid('ReferenceCode')}
            AND ${_valid('ReferenceName')}
            ORDER BY ReferenceName
            ''',
            [encryptedUserId],
          )
        : await db.rawQuery(
            '''
            SELECT DISTINCT ReferenceCode, ReferenceName
            FROM Tbl_Reference
            WHERE UserId = ?
            AND AgentCode IN (${_placeholders(agents.length)})
            AND ${_valid('ReferenceCode')}
            AND ${_valid('ReferenceName')}
            ORDER BY ReferenceName
            ''',
            [encryptedUserId, ...encryptedAgents],
          );

    return result.map((row) {
      final referenceCode = CommonUtil.decryptIfNotEmpty(
        row['ReferenceCode']?.toString() ?? '',
      );

      final referenceName = CommonUtil.decryptIfNotEmpty(
        row['ReferenceName']?.toString() ?? '',
      );

      return FilterOption(code: referenceCode, description: referenceName);
    }).toList();
    //   return _mapOptions(result, 'ReferenceCode', 'ReferenceName', addAll: true);
  }

  Future<List<FilterOption>> getLobs() async {
    //final db = await dbHelper.database;
    final odb = await OfflineDBHelper.getDatabase();
    print("================================================================");
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    final select = await odb.rawQuery(
      '''select distinct LOBCode, LOBDesc1 from CBFrmMSTLOB''',
    );
    print("LOBS");
    print(select);
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    print("================================================================");

    final result = await odb.rawQuery('''
      SELECT DISTINCT LOBCode, LOBDesc1
      FROM CBFrmMSTLOB
      WHERE ${_valid('LOBCode')}
      AND ${_valid('LOBDesc1')}
      ORDER BY LOBDesc1
    ''');

    return _mapOptions(result, 'LOBCode', 'LOBDesc1');
  }

  Future<List<FilterOption>> getProductGroups({required String lobCode}) async {
    final db = await dbHelper.database;
    String enclob = CommonUtil.encryptIfNotEmpty(lobCode);
    final result = await db.rawQuery(
      '''
      SELECT DISTINCT ProdCategory
      FROM CBFrmLOBProdMapping
      WHERE LOBCode = ?
      AND ${_valid('ProdCategory')}
      ORDER BY ProdCategory
      ''',
      [enclob],
    );

    //return _mapOptions(result, 'ProdCategory', 'ProdCategory');
    final options = result.map((row) {
      final prodCategory = CommonUtil.decryptIfNotEmpty(
        row['ProdCategory']?.toString() ?? '',
      );

      return FilterOption(code: prodCategory, description: prodCategory);
    }).toList();

    return options;
  }

  Future<List<FilterOption>> getProducts({
    required String lobCode,
    required String productGroup,
  }) async {
    // final db = await dbHelper.database;
    //Rahul changes
    final db = await OfflineDBHelper.getDatabase();

    String enclob = lobCode;
    String eproductGroup = productGroup;

    //String enclob = CommonUtil.encryptIfNotEmpty(lobCode);
    //String eproductGroup = CommonUtil.encryptIfNotEmpty(productGroup);

    print("Lob and Prod Group : " + lobCode + productGroup);

    final result = await db.rawQuery(
      '''
      SELECT DISTINCT p.ProdCode, p.ProdDesc1
      FROM CBFrmMSTProduct p
      INNER JOIN CBFrmLOBProdMapping m
        ON p.ProdCode = m.ProdCode
      WHERE m.LOBCode = ?
      AND m.ProdCategory = ?
      AND ${_valid('p.ProdCode')}
      AND ${_valid('p.ProdDesc1')}
      ORDER BY p.ProdDesc1
      ''',
      [enclob, eproductGroup],
    );

    print("PRODUCT CODE ROWS COUNT: ${result.length}");
    print("PRODUCT CODE ROWS: $result");

    // return _mapOptions(result, 'ProdCode', 'ProdDesc1', addAll: true);
    //change here
    // final options = result.map((row) {
    //   final prodCode = CommonUtil.decryptIfNotEmpty(
    //     row['ProdCode']?.toString() ?? '',
    //   );
    final options = result.map((row) {
      final prodCode = row['ProdCode']?.toString() ?? '';

      // final prodName = CommonUtil.decryptIfNotEmpty(
      //   row['ProdDesc1']?.toString() ?? '',
      // );
      final prodName = row['ProdDesc1']?.toString() ?? '';

      return FilterOption(code: prodCode, description: prodName);
    }).toList();

    options.sort((a, b) => a.description.compareTo(b.description));

    return [const FilterOption(code: 'All', description: 'All'), ...options];
  }


Future<List<FilterOption>> getProductSubCategories({
  required List<String> productGroups,
}) async {
  if (productGroups.isEmpty) return [];

  final db = await OfflineDBHelper.getDatabase();

  // Android uses Product Group description as LookupCode.
  // So provider should send selectedProductGroups.map((e) => e.description).
  final groups = productGroups
      .where((e) => e.trim().isNotEmpty && e != 'All')
      .toList();

  if (groups.isEmpty) return [];

  final result = await db.rawQuery(
    '''
    SELECT DISTINCT ParamValue, ParamDesc1, SortOrder
    FROM Lookupsu
    WHERE LookupCode IN (${_placeholders(groups.length)})
    AND ${_valid('ParamValue')}
    AND ${_valid('ParamDesc1')}
    ORDER BY CAST(SortOrder AS INTEGER)
    ''',
    groups,
  );

  final options = result
      .map((row) {
        final paramValue = row['ParamValue']?.toString().trim() ?? '';
        final paramDesc = row['ParamDesc1']?.toString().trim() ?? '';

        return FilterOption(
          code: paramValue,
          description: paramDesc,
        );
      })
      .where((option) =>
          option.code.isNotEmpty && option.description.isNotEmpty)
      .toList();

  return [
    const FilterOption(code: 'All', description: 'All'),
    ...options,
  ];
}
  // Future<List<FilterOption>> getProductSubCategories({
  //   required List<String> productGroups,
  // }) async {
  //   if (productGroups.isEmpty) return [];

  //   // final db = await dbHelper.database;
  //   final db = await OfflineDBHelper.getDatabase();

  //   //  String eproductGroups = CommonUtil.encryptIfNotEmpty(productGroups);
  //   if (productGroups.isEmpty) return [];

  //   final groups = productGroups.where((e) => e != 'All').toList();

  //   if (groups.isEmpty) {
  //     return [];
  //   }

  //   final eProductGroups = groups;
  //   // final eProductGroups = groups
  //   //     .map((e) => CommonUtil.encryptIfNotEmpty(e))
  //   //     .toList();

  //   final result = await db.rawQuery('''
  //     SELECT DISTINCT ParamValue, ParamDesc1, SortOrder
  //     FROM Lookupsu
  //     WHERE LookupCode IN (${_placeholders(eProductGroups.length)})
  //     AND ${_valid('ParamValue')}
  //     AND ${_valid('ParamDesc1')}
  //     ORDER BY CAST(SortOrder AS INTEGER)
  //     ''', eProductGroups);

  //   //return _mapOptions(result, 'ParamValue', 'ParamDesc1', addAll: true);

  //   final options = result.map((row) {
  //     final paramValue = CommonUtil.decryptIfNotEmpty(
  //       row['ParamValue']?.toString() ?? '',
  //     );

  //     final paramDesc = CommonUtil.decryptIfNotEmpty(
  //       row['ParamDesc1']?.toString() ?? '',
  //     );

  //     return FilterOption(code: paramValue, description: paramDesc);
  //   }).toList();

  //   return [const FilterOption(code: 'All', description: 'All'), ...options];
  // }

  Future<List<FilterOption>> getRenewalYearCounts() async {
    //final db = await dbHelper.database;
    final odb = await OfflineDBHelper.getDatabase();
    // final result = await odb.rawQuery('''
    //   SELECT DISTINCT ParamValue, ParamDesc1, SortOrder
    //   FROM LookUpSU
    //   WHERE LookUpCode = 'RenewalYear'
    //   AND ${_valid('ParamValue')}
    //   AND ${_valid('ParamDesc1')}
    //   ORDER BY CAST(SortOrder AS INTEGER)
    // ''');
    final result = await odb.rawQuery('''
  SELECT DISTINCT ParamValue, ParamDesc1, SortOrder
  FROM Lookupsu
  WHERE LookupCode = 'RenewalYear'
  AND ${_valid('ParamValue')}
  AND ${_valid('ParamDesc1')}
  ORDER BY CAST(SortOrder AS INTEGER)
''');

    return _mapOptions(result, 'ParamValue', 'ParamDesc1', addAll: true);
  }

  List<FilterOption> getNcbOptions() {
    return const [
      FilterOption(code: 'Y', description: 'Yes'),
      FilterOption(code: 'N', description: 'No'),
      FilterOption(code: 'All', description: 'All'),
    ];
  }

  List<FilterOption> getPreferredOptions() {
    return const [
      FilterOption(code: 'Y', description: 'Yes'),
      FilterOption(code: 'N', description: 'No'),
      FilterOption(code: 'All', description: 'All'),
    ];
  }

  Future<Map<String, List<FilterOption>>> getAllLookupOptions() async {
    final db = await OfflineDBHelper.getDatabase();

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    print("ALL OFFLINE TABLES: $tables");

    final lookupCount = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM LookUpSU",
    );
    print("LookUpSU ROW COUNT: $lookupCount");

    final lookupSample = await db.rawQuery("SELECT * FROM LookUpSU LIMIT 10");
    print("LookUpSU SAMPLE: $lookupSample");
    //   final result = await db.rawQuery('''
    //   SELECT LookUpCode, ParamDesc1, SortOrder
    //   FROM LookUpSU
    //   WHERE LookUpCode IS NOT NULL
    //   AND TRIM(LookUpCode) != ''
    //   AND ParamDesc1 IS NOT NULL
    //   AND TRIM(ParamDesc1) != ''
    //   AND UPPER(TRIM(ParamDesc1)) != 'NA'
    //   AND LOWER(TRIM(ParamDesc1)) != 'null'
    //   ORDER BY LookUpCode, CAST(SortOrder AS INTEGER)
    // ''');

    final result = await db.rawQuery('''
  SELECT LookupCode, ParamDesc1, SortOrder
  FROM Lookupsu
  WHERE LookupCode IS NOT NULL
  AND TRIM(LookupCode) != ''
  AND ParamDesc1 IS NOT NULL
  AND TRIM(ParamDesc1) != ''
  AND UPPER(TRIM(ParamDesc1)) != 'NA'
  AND LOWER(TRIM(ParamDesc1)) != 'null'
  ORDER BY LookupCode, CAST(SortOrder AS INTEGER)
''');

    final Map<String, List<FilterOption>> lookupCache = {};

    for (final row in result) {
      //final lookupCode = row['LookUpCode']?.toString().trim() ?? '';
      final lookupCode = row['LookupCode']?.toString().trim() ?? '';
      final value = row['ParamDesc1']?.toString().trim() ?? '';

      if (lookupCode.isEmpty || value.isEmpty) continue;

      lookupCache.putIfAbsent(lookupCode, () => []);

      if (!lookupCache[lookupCode]!.any((e) => e.code == value)) {
        lookupCache[lookupCode]!.add(
          FilterOption(code: value, description: value),
        );
      }
    }

    print("LOOKUP CACHE LOADED KEYS: ${lookupCache.keys.toList()}");

    return lookupCache;
  }

  Future<List<FilterOption>> getVehicleMakes() async {
    final db = await OfflineDBHelper.getDatabase();

    final result = await db.rawQuery('''
    SELECT DISTINCT Make_ID_PK, Make_Name
    FROM Make_Master
    WHERE Make_Name IS NOT NULL
    AND TRIM(Make_Name) != ''
    AND UPPER(TRIM(Make_Name)) != 'NA'
    AND LOWER(TRIM(Make_Name)) != 'null'
    ORDER BY Make_Name ASC
  ''');

    final options = result
        .map((row) {
          final makeId = row['Make_ID_PK']?.toString().trim() ?? '';
          final makeName = row['Make_Name']?.toString().trim() ?? '';

          return FilterOption(code: makeId, description: makeName);
        })
        .where((e) => e.code.isNotEmpty && e.description.isNotEmpty)
        .toList();

    print("MAKE OPTIONS COUNT: ${options.length}");

    return options;
  }

  // List<FilterOption> getCachedLookupOptions(
  //   Map<String, List<FilterOption>> lookupCache,
  //   String lookupCode,
  // ) {
  //   return lookupCache[lookupCode] ?? [];
  // }
  //change added by rahul
  List<FilterOption> getCachedLookupOptions(
    Map<String, List<FilterOption>> lookupCache,
    String lookupCode,
  ) {
    final normalizedLookupCode = lookupCode.trim().toLowerCase();

    for (final entry in lookupCache.entries) {
      if (entry.key.trim().toLowerCase() == normalizedLookupCode) {
        return entry.value;
      }
    }

    print("LOOKUP NOT FOUND: [$lookupCode]");
    print("AVAILABLE LOOKUP KEYS: ${lookupCache.keys.toList()}");

    return [];
  }

  Map<String, List<FilterOption>> getDynamicProductDropdownsFromCache({
    required String productGroup,
    required Map<String, List<FilterOption>> lookupCache,
    required List<FilterOption> makeOptions,
  }) {
    final group = productGroup.trim().toLowerCase();

    print("DYNAMIC PRODUCT GROUP RECEIVED: [$productGroup]");
    print("NORMALIZED PRODUCT GROUP: [$group]");

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
        print("NO DYNAMIC DROPDOWN MATCH FOUND FOR PRODUCT GROUP: [$group]");
        return {};
    }
  }
}
