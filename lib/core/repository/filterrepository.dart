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

    final db = await dbHelper.database;

    //  String eproductGroups = CommonUtil.encryptIfNotEmpty(productGroups);
    if (productGroups.isEmpty) return [];

    final groups = productGroups.where((e) => e != 'All').toList();

    if (groups.isEmpty) {
      return [];
    }

    final eProductGroups = groups
        .map((e) => CommonUtil.encryptIfNotEmpty(e))
        .toList();

    final result = await db.rawQuery('''
      SELECT DISTINCT ParamValue, ParamDesc1, SortOrder
      FROM LookUpSU
      WHERE LookUpCode IN (${_placeholders(eProductGroups.length)})
      AND ${_valid('ParamValue')}
      AND ${_valid('ParamDesc1')}
      ORDER BY CAST(SortOrder AS INTEGER)
      ''', eProductGroups);

    //return _mapOptions(result, 'ParamValue', 'ParamDesc1', addAll: true);

    final options = result.map((row) {
      final paramValue = CommonUtil.decryptIfNotEmpty(
        row['ParamValue']?.toString() ?? '',
      );

      final paramDesc = CommonUtil.decryptIfNotEmpty(
        row['ParamDesc1']?.toString() ?? '',
      );

      return FilterOption(code: paramValue, description: paramDesc);
    }).toList();

    return [const FilterOption(code: 'All', description: 'All'), ...options];
  }

  Future<List<FilterOption>> getRenewalYearCounts() async {
    //final db = await dbHelper.database;
    final odb = await OfflineDBHelper.getDatabase();
    final result = await odb.rawQuery('''
      SELECT DISTINCT ParamValue, ParamDesc1, SortOrder
      FROM LookUpSU
      WHERE LookUpCode = 'RenewalYear'
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
}
