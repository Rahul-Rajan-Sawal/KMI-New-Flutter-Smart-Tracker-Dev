import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/common/StatePin_DB.dart';
import 'package:flutter_bottom_nav/common/common_singltbtn_popup.dart';
import 'package:flutter_bottom_nav/core/apicall/async_CreateLead.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen>
    with SingleTickerProviderStateMixin {
  int selectedTabIndex = 0;
  late TabController _tabController;
  String? selectedRequestChannel;
  String? selectedLeadSource;
  String? selectedSubLeadSource;
  final StatePinDB statePinDB = StatePinDB();

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController mobile = TextEditingController();

  TextEditingController addr1 = TextEditingController();
  TextEditingController addr2 = TextEditingController();
  TextEditingController addr3 = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final FocusNode pincodeFocusNode = FocusNode();
  String? selectedState;
  String? selectedStateId;

  String? BussinessType, LOB, Product, SaleType, LeadQueue;
  String? productCode;
  TextEditingController Remark = TextEditingController();

  List<String> arrReqChannel = [];
  List<String> arrLeadSource = [];
  List<String> arrSubLeadSource = [];

  List<String> arrReqChannelId = [];
  List<String> arrLeadSourceId = [];
  List<String> arrSubLeadSourceId = [];

  List<String> arrStateID = [];
  List<String> arrDistrictID = [];
  List<String> arrCityID = [];
  List<String> arrAreaID = [];

  List<Map<String, dynamic>> stateList = [];
  List<String> arrState = [];
  List<String> arrDistrict = [];
  List<String> arrCity = [];
  List<String> arrArea = [];

  List<String> arrBusinessType = [];
  List<String> arrBusinessTypeID = [];

  List<String> arrLOB = [];
  List<String> arrLOBCode = [];

  List<String> arrProduct = [];
  List<String> arrProductCode = [];

  List<String> arrSaleType = [];
  List<String> arrSaleTypeID = [];

  List<String> arrLeadQueue = [];
  List<String> arrLeadQueueID = [];

  List<String> arrPinCode = [];

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  Future<Database> getMainDb() async {
    final db = await dbHelper.database;
    return db;
  }

  String dbValue(dynamic value) {
    return value?.toString() ?? "";
  }

  String makePlaceholders(int len) {
    if (len < 1) {
      return "?";
    } else {
      return List.filled(len, '?').join(',');
    }
  }

  Future<String> offlineLeadIdGeneration({
    required String name,
    required String mobileNo,
  }) async {
    int offlineLeadNo = 100000;
    String strOfflineLeadNo = "";

    final db = await getMainDb();
    final String sysDate = dbDateTimeWithMillis(DateTime.now());

    // Change table name only if your DB table name is different
    const String tableName = "OfflineLeadIdsCounter";

    try {
      // Android logic:
      // SELECT MAX(CounterID) FROM OfflineLeadIdsCounter
      final maxCounterResult = await db.rawQuery(
        "SELECT MAX(CounterID) AS MaxCounterID FROM $tableName WHERE TempIdFor = ?",
        ["Lead"],
      );

      final dynamic maxCounterId = maxCounterResult.isNotEmpty
          ? maxCounterResult.first["MaxCounterID"]
          : null;

      List<Map<String, dynamic>> counterRows = [];

      if (maxCounterId != null && maxCounterId.toString().trim().isNotEmpty) {
        counterRows = await db.query(
          tableName,
          columns: ["LeadCounter", "LeadId"],
          where: "TempIdFor = ? AND CounterID = ?",
          whereArgs: ["Lead", maxCounterId],
          limit: 1,
        );
      } else {
        counterRows = await db.query(
          tableName,
          columns: ["LeadCounter", "LeadId"],
          where: "TempIdFor = ?",
          whereArgs: ["Lead"],
          limit: 1,
        );
      }

      if (counterRows.isNotEmpty) {
        final String tempCounter =
            counterRows.first["LeadCounter"]?.toString() ?? "";

        if (tempCounter.trim().isNotEmpty &&
            tempCounter.toLowerCase() != "null") {
          offlineLeadNo = int.tryParse(tempCounter) ?? 100000;
          offlineLeadNo = offlineLeadNo + 1;
        }

        strOfflineLeadNo = "T$offlineLeadNo";
      } else {
        strOfflineLeadNo = "T$offlineLeadNo";
      }

      // Check if generated LeadId already exists
      final existingLead = await db.query(
        tableName,
        where: "LeadId = ?",
        whereArgs: [strOfflineLeadNo],
        limit: 1,
      );

      if (existingLead.isEmpty) {
        final Map<String, dynamic> data = {
          "LeadCounter": dbValue(offlineLeadNo),
          "LeadId": dbValue(strOfflineLeadNo),
          "Name": dbValue(name),
          "MobileNo": dbValue(mobileNo),
          "TempIdFor": dbValue("Lead"),
          "IDCreateDTime": dbValue(sysDate),
          "IMEI_Number": dbValue(""), // Android used getIMEINumber(context)
        };

        final filteredData = await filterExistingColumns(db, tableName, data);

        await db.insert(tableName, filteredData);

        print("Offline Lead ID generated: $strOfflineLeadNo");
      } else {
        // Safer than Android recursion
        offlineLeadNo = offlineLeadNo + 1;
        strOfflineLeadNo = "T$offlineLeadNo";

        final Map<String, dynamic> data = {
          "LeadCounter": dbValue(offlineLeadNo),
          "LeadId": dbValue(strOfflineLeadNo),
          "Name": dbValue(name),
          "MobileNo": dbValue(mobileNo),
          "TempIdFor": dbValue("Lead"),
          "IDCreateDTime": dbValue(sysDate),
          "IMEI_Number": dbValue(""),
        };

        final filteredData = await filterExistingColumns(db, tableName, data);

        await db.insert(tableName, filteredData);

        print(
          "Duplicate found, new Offline Lead ID generated: $strOfflineLeadNo",
        );
      }
    } catch (e) {
      print("offlineLeadIdGeneration Error: $e");

      // Fallback like Android default
      strOfflineLeadNo = "T$offlineLeadNo";
    }

    return strOfflineLeadNo;
  }

  Future<Map<String, dynamic>> filterExistingColumns(
    Database db,
    String tableName,
    Map<String, dynamic> data,
  ) async {
    final columnsInfo = await db.rawQuery("PRAGMA table_info ($tableName)");

    final validColumns = columnsInfo.map((e) => e["name"].toString()).toSet();

    return Map.fromEntries(
      data.entries.where((entry) => validColumns.contains(entry.key)),
    );
  }

  String twoDigit(int value) => value.toString().padLeft(2, "0");

  String dbDateTimeWithMillis(DateTime date) {
    return "${date.year}-${twoDigit(date.month)}-${twoDigit(date.day)} "
        "${twoDigit(date.hour)}:${twoDigit(date.minute)}:${twoDigit(date.second)}."
        "${date.millisecond.toString().padLeft(3, "0")}";
  }

  String dbDateTime(DateTime date) {
    return "${date.year}-${twoDigit(date.month)}-${twoDigit(date.day)} "
        "${twoDigit(date.hour)}:${twoDigit(date.minute)}:${twoDigit(date.second)}";
  }

  String dbDateOnly(DateTime date) {
    return "${twoDigit(date.day)}-${twoDigit(date.month)}-${date.year}";
  }

  Future<void> getReqChannelDataFrmMST() async {
    try {
      List<String> arrReqChannelIdMap = [];

      final db = await OfflineDBHelper.getDatabase();

      final reqresult = await db.query(
        'CBFRMLmsReqChannelMaping',
        where: 'ReqChannelId=?',
        whereArgs: ['RQ17'],
      );

      if (reqresult.isNotEmpty) {
        for (var row in reqresult) {
          arrReqChannelIdMap.add(row['ReqChannelId'].toString());
        }
      }

      int length = arrReqChannelIdMap.length;

      //Addd IsActive and IsVisible values
      arrReqChannelIdMap.insert(0, 'Y');
      arrReqChannelIdMap.insert(1, 'Y');

      //Create placeholders
      String placeholders = List.filled(length, '?').join(',');

      final result = await db.query(
        'MstReqChannel',
        columns: ['ReqChannelId', 'ReqChannelDesc'],
        distinct: true,
        where:
            'IsActive = ? AND IsVisible = ? AND ReqChannelId IN ($placeholders)',
        whereArgs: arrReqChannelIdMap,
        orderBy: 'ReqChannelDesc',
      );

      arrReqChannelId.clear();
      arrReqChannel.clear();

      if (result.isNotEmpty) {
        for (var row in result) {
          arrReqChannelId.add(row['ReqChannelId'].toString());
          arrReqChannel.add(row['ReqChannelDesc'].toString());
        }
      }

      setState(() {});

      print('Req Channel IDS: $arrReqChannelId');
      print('Req Channel Desc: $arrReqChannel');
    } catch (e) {
      print("Error $e");
    }
  }

  Future<bool> insertCreateLeadLocal({
    required String uniqueRef,
    required String reqChannelId,
    required String reqChannelDesc,
    required String leadSource,
    required String leadSourceDesc,
    required String leadSubSource,
    required String leadSubSourceDesc,
    required String businessType,
    required String businessTypeDesc,
    required String lobCode,
    required String lobDesc,
    required String prodCode,
    required String prodName,
    required String saleType,
    required String saleTypeDesc,
    required String leadQueue,
    required String leadQueueDesc,
    required String name,
    required String mobileTel,
    required String addr1,
    required String addr2,
    required String addr3,
    required String stateCode,
    required String districtCode,
    required String cityCode,
    required String area,
    required String pinCode,
    required String remark,
    required String userId,
    required String userName,
  }) async {
    try {
      final db = await getMainDb();
      final now = DateTime.now();

      final String offlineLeadId = await offlineLeadIdGeneration(
        name: name,
        mobileNo: mobileTel,
      );

      const String leadTable = "LeadDetails";

      final Map<String, dynamic> leadData = {
        "SrvcReqDtlCode": dbValue(offlineLeadId),

        "ReqChannel": dbValue(reqChannelDesc),
        "ReqChannelId": dbValue(reqChannelId),

        "LeadSource": dbValue(leadSource),
        "LeadSourceDesc": dbValue(leadSourceDesc),

        "LeadSubSource": dbValue(leadSubSource),
        "LeadSubSourceDesc": dbValue(leadSubSourceDesc),

        "Name": dbValue(name),
        "MobileTel": dbValue(mobileTel),

        "Addr1": dbValue(addr1),
        "Addr2": dbValue(addr2),
        "Addr3": dbValue(addr3),

        "StateCode": dbValue(stateCode),
        "DistrictCode": dbValue(districtCode),
        "CityCode": dbValue(cityCode),
        "Area": dbValue(area),
        "PinCode": dbValue(pinCode),

        "BusinessType": dbValue(businessType),
        "BusinessTypeDesc": dbValue(businessTypeDesc),

        "LOBCode": dbValue(lobCode),
        "LOB": dbValue(lobDesc),

        "ProdCode": dbValue(prodCode),
        "ProdName": dbValue(prodName),

        "SaleType": dbValue(saleType),
        "SaleTypeDesc": dbValue(saleTypeDesc),

        "LeadQueue": dbValue(leadQueue),
        "LeadQueueDesc": dbValue(leadQueueDesc),

        "Remark": dbValue(remark),

        "SyncStatus": dbValue("Pending"),
        "TempSrvcReqDtlCode": dbValue(uniqueRef),
        "CreateDTim": dbValue(dbDateTimeWithMillis(now)),

        "UserId": dbValue(userId),
        "isOwner": dbValue(userId),
        "OwnerName": dbValue(userName),
        "AssignedTo": dbValue(userId),
        "AssignedToName": dbValue(userName),

        "WFStatus": dbValue("1"),
        "WFStatDesc": dbValue("WIP"),
        "CRMStatus": dbValue("2"),
        "LMSStatusDesc": dbValue("ASSIGNED TO SALES MANAGER"),

        "LeadAging": dbValue(dbDateTimeWithMillis(now)),
      };

      final filteredData = await filterExistingColumns(db, leadTable, leadData);

      final existing = await db.query(
        leadTable,
        where: "TempSrvcReqDtlCode = ?",
        whereArgs: [dbValue(uniqueRef)],
        limit: 1,
      );

      int result = 0;

      if (existing.isNotEmpty) {
        result = await db.update(
          leadTable,
          filteredData,
          where: "TempSrvcReqDtlCode = ?",
          whereArgs: [dbValue(uniqueRef)],
        );
      } else {
        result = await db.insert(leadTable, filteredData);
      }

      final check = await db.query(
        leadTable,
        where: "TempSrvcReqDtlCode = ?",
        whereArgs: [dbValue(uniqueRef)],
        limit: 1,
      );

      if (check.isNotEmpty) {
        await insertIntoCalendarTblLocal(
          referenceNo: uniqueRef,
          lobCode: lobCode,
          prodCode: prodCode,
          userId: userId,
        );
        return true;
      }

      return false;
    } catch (e) {
      print("insertCreateLeadLocal Error: $e");
      return false;
    }
  }

  Future<void> insertIntoCalendarTblLocal({
    required String referenceNo,
    required String lobCode,
    required String prodCode,
    required String userId,
  }) async {
    try {
      final db = await getMainDb();
      final now = DateTime.now();

      const String calendarTable = "CalendarData_Mob";

      final String mDate = "${now.year}-${now.month}";

      final Map<String, dynamic> calendarData = {
        "UserId": dbValue(userId),
        "date": dbValue(dbDateOnly(now)),

        "AgentCode": dbValue(""),
        "AgentName": dbValue(""),
        "HNINCode": dbValue(""),
        "HNINName": dbValue(""),

        "LOBCode": dbValue(lobCode),
        "ProdCode": dbValue(prodCode),

        "NCBFlag": dbValue(""),

        "TotalLeads": dbValue("1"),
        "WIPLeads": dbValue("1"),
        "LeadConverted": dbValue("0"),
        "LeadLost": dbValue("0"),

        "LeadType": dbValue("L"),
        "BizType": dbValue("N"),

        "CreatedBy": dbValue(userId),
        "CreateDTime": dbValue(dbDateTime(now)),
        "mdate": dbValue(mDate),

        "ReferenceNo": dbValue(referenceNo),
        "SyncStatus": dbValue("Pending"),
      };

      final filteredData = await filterExistingColumns(
        db,
        calendarTable,
        calendarData,
      );

      final existing = await db.query(
        calendarTable,
        where: "ReferenceNo = ?",
        whereArgs: [dbValue(referenceNo)],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        await db.delete(
          calendarTable,
          where: "ReferenceNo = ?",
          whereArgs: [dbValue(referenceNo)],
        );
      }

      await db.insert(calendarTable, filteredData);

      print("Calendar local row inserted for ReferenceNo: $referenceNo");
    } catch (e) {
      print("insertIntoCalendarTblLocal Error: $e");
    }
  }

  Future<int> insertIntoNotificationDetailsLocal({
    required String notification,
    required String remark1,
    required String dateTime,
    required String userId,
    required String module,
  }) async {
    try {
      final db = await getMainDb();

      // Change this table name only if your Flutter DB table name is different.
      const String notificationTable = "NotificationDetails";

      final Map<String, dynamic> notificationData = {
        "Notification": dbValue(notification),
        "Remark1": dbValue(remark1),
        "DateTime": dbValue(dateTime),
        "UserId": dbValue(userId),
        "Module": dbValue(module),
      };

      final filteredData = await filterExistingColumns(
        db,
        notificationTable,
        notificationData,
      );

      if (filteredData.isEmpty) {
        print("No matching columns found for table: $notificationTable");
        return -1;
      }

      final int insertedId = await db.insert(notificationTable, filteredData);

      print("Notification inserted ID: $insertedId");
      return insertedId;
    } catch (e) {
      print("insertIntoNotificationDetailsLocal Error: $e");
      return -1;
    }
  }

  Future<void> updateLeadAfterApiSuccess({
    required String leadId,
    required String uniqueRef,
  }) async {
    try {
      final db = await getMainDb();

      const String leadTable = "LeadDetails";

      final Map<String, dynamic> updateData = {
        "SrvcReqDtlCode": dbValue(leadId),
        "SyncStatus": dbValue("Completed"),
        "isInserted": dbValue("Y"),
      };

      final filteredData = await filterExistingColumns(
        db,
        leadTable,
        updateData,
      );

      final count = await db.update(
        leadTable,
        filteredData,
        where: "TempSrvcReqDtlCode = ?",
        whereArgs: [dbValue(uniqueRef)],
      );

      print("LeadDetails success update count: $count");
    } catch (e) {
      print("updateLeadAfterApiSuccess Error: $e");
    }
  }

  Future<void> updateCalendarAfterApiSuccess({
    required String uniqueRef,
  }) async {
    try {
      final db = await getMainDb();

      const String calendarTable = "CalendarData_Mob";

      final Map<String, dynamic> updateData = {
        "SyncStatus": dbValue("Completed"),
        "ReferenceNo": dbValue(""),
      };

      final filteredData = await filterExistingColumns(
        db,
        calendarTable,
        updateData,
      );

      final count = await db.update(
        calendarTable,
        filteredData,
        where: "ReferenceNo = ?",
        whereArgs: [dbValue(uniqueRef)],
      );

      print("Calendar success update count: $count");
    } catch (e) {
      print("updateCalendarAfterApiSuccess Error: $e");
    }
  }

  Future<void> getReqChnlSourceMappingFrmMST(String reqChnlId) async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      List<String> arrMappingLeadSourceId = [];

      final result = await db.query(
        'CBFRMLmsReqChannelLeadSourceMaping',
        columns: ['LeadSourceId'],
      );

      arrMappingLeadSourceId.clear();

      if (result.isNotEmpty) {
        for (var row in result) {
          arrMappingLeadSourceId.add(row['LeadSourceId'].toString());
        }
      }

      if (arrMappingLeadSourceId.isNotEmpty) {
        int length = arrMappingLeadSourceId.length;

        //Add isActive and ReqChannelId values
        arrMappingLeadSourceId.insert(0, 'Y');
        arrMappingLeadSourceId.insert(1, reqChnlId);

        //Create Placeholders
        String placeholders = List.filled(length, '?').join(',');

        final resultls = await db.query(
          'CBLMSChnlSourceMapping',
          distinct: true,
          columns: ['LeadSourceId', 'LeadSourceDesc'],
          where:
              'isActive=? AND ReqChannelId=? AND LeadSourceId IN ($placeholders)',
          whereArgs: arrMappingLeadSourceId,
        );

        arrLeadSourceId.clear();
        arrLeadSource.clear();

        if (resultls.isNotEmpty) {
          for (var row in resultls) {
            String desc = row['LeadSourceDesc']?.toString().trim() ?? '';

            if (desc.isNotEmpty && desc.toLowerCase() != 'null') {
              arrLeadSourceId.add(row['LeadSourceId'].toString());

              arrLeadSource.add(desc);
            }
          }
        }
        setState(() {});
      }
      print("LeadSource IDs : $arrLeadSourceId");
      print("LeadSource Desc : $arrLeadSource");
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> getLeadSubSourceDataFrmMST(String subLeadSrcId) async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      final result = await db.query(
        'CBLMSChnlSourceMapping',
        distinct: true,
        columns: ['LeadSubSourceId', 'LeadSubSourceDesc'],
        where: 'LeadSourceId=? AND isActive=?',
        whereArgs: [subLeadSrcId, 'Y'],
      );

      arrSubLeadSourceId.clear();
      arrSubLeadSource.clear();

      if (result.isNotEmpty) {
        for (var row in result) {
          String desc = row['LeadSubSourceDesc']?.toString().trim() ?? '';

          if (desc.isNotEmpty && desc.toLowerCase() != 'null') {
            arrSubLeadSourceId.add(row['LeadSubSourceId'].toString());

            arrSubLeadSource.add(desc);
          }
        }
      }

      setState(() {});
      print("SubLead Source IDs: $arrSubLeadSourceId");
      print("SubLead Source Desc: $arrSubLeadSource");
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> getMSTLOBDataFrmMST() async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      final result = await db.query(
        'CBFrmMSTLOB',
        distinct: true,
        columns: ['LOBCode', 'LOBDesc1'],
      );

      arrLOBCode.clear();
      arrLOB.clear();

      if (result.isNotEmpty) {
        for (var row in result) {
          arrLOBCode.add(row['LOBCode'].toString());

          arrLOB.add(row['LOBDesc1'].toString());
        }
      }

      setState(() {});

      print("LOB Codes: $arrLOBCode");
      print("LOB Desc: $arrLOB");
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> getMSTProductData(String lobCode) async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      //First Query
      final mappingquery = await db.query(
        'CBFrmLOBProdMapping',
        columns: ['LOBCode', 'ProdCode'],
        where: 'LOBCode=? AND ProdCode!=?',
        whereArgs: [lobCode, '0'],
      );

      arrProductCode.clear();

      if (mappingquery.isNotEmpty) {
        for (var row in mappingquery) {
          arrProductCode.add(row['ProdCode'].toString());
        }
      }

      //Second Query
      int length = arrProductCode.length;

      if (length > 0) {
        List<String> prodArgs = List.from(arrProductCode);

        prodArgs.insert(0, '');

        String placeholders = List.filled(length, '?').join(',');

        final productResult = await db.query(
          'CBFrmMSTProduct',
          columns: ['ProdDesc1', 'ProdCode'],
          where: 'ProdDesc1 != ? AND ProdCode IN ($placeholders)',
          whereArgs: prodArgs,
        );

        arrProduct.clear();
        arrProductCode.clear();

        if (productResult.isNotEmpty) {
          for (var row in productResult) {
            arrProduct.add(row['ProdDesc1'].toString());

            arrProductCode.add(row['ProdCode'].toString());
          }
        }
      }
      setState(() {});

      print("Product Code $arrProductCode");
      print("Products: $arrProduct");
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> loadStates() async {
    stateList = await statePinDB.getAllState();

    arrState.clear();
    arrStateID.clear();

    for (var state in stateList) {
      arrState.add(state['state_code'].toString());
      arrStateID.add(state['state_id'].toString());
    }

    setState(() {});
  }

  Future<void> loadPins(String stateId) async {
    try {
      final result = await statePinDB.getPin(stateId);

      setState(() {
        arrPinCode.clear();
        pincode.clear();

        // result is already List<String>
        arrPinCode.addAll(result);
      });

      print("Selected State ID: $stateId");
      print("Pincodes: $arrPinCode");
    } catch (e) {
      print("Error loading pincodes: $e");
    }
  }

  Future<void> getBusinessTypeDataFrmMST() async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      final result = await db.query(
        'LookUpSU',
        columns: ['ParamValue', 'ParamDesc1'],
        where: 'LookupCode=?',
        whereArgs: ['BusinessTyp'],
        orderBy: 'SortOrder ASC',
      );

      arrBusinessType.clear();
      arrBusinessTypeID.clear();

      if (result.isNotEmpty) {
        for (final row in result) {
          final businessTypeId = row['ParamValue']?.toString().trim() ?? '';
          final businessTypeDesc = row['ParamDesc1']?.toString().trim() ?? '';

          if (businessTypeId.isNotEmpty &&
              businessTypeDesc.isNotEmpty &&
              businessTypeDesc.toLowerCase() != 'null') {
            arrBusinessTypeID.add(businessTypeId);
            arrBusinessType.add(businessTypeDesc);
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
      print('Bussiness Type IDs: $arrBusinessTypeID');
      print('Business Type Description $arrBusinessType');
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> getSalesTypeDataFrmMST() async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      final result = await db.query(
        'LookUpSU', // Use your actual table name if different
        columns: ['ParamValue', 'ParamDesc1'],
        where: 'LookupCode = ?',
        whereArgs: ['SaleType'],
        orderBy: 'SortOrder ASC',
      );

      arrSaleType.clear();
      arrSaleTypeID.clear();

      if (result.isNotEmpty) {
        for (final row in result) {
          final saleTypeId = row['ParamValue']?.toString().trim() ?? '';
          final saleTypeDesc = row['ParamDesc1']?.toString().trim() ?? '';

          if (saleTypeId.isNotEmpty &&
              saleTypeDesc.isNotEmpty &&
              saleTypeDesc.toLowerCase() != 'null') {
            arrSaleTypeID.add(saleTypeId);
            arrSaleType.add(saleTypeDesc);
          }
        }
      }

      if (mounted) {
        setState(() {});
      }

      print('Sales Type IDs: $arrSaleTypeID');
      print('Sales Type Descriptions: $arrSaleType');
    } catch (e) {
      print('Sales Type loading error: $e');
    }
  }

  Future<void> getLeadQueueDataFrmMST() async {
    try {
      final db = await OfflineDBHelper.getDatabase();

      final result = await db.query(
        'LookUpSU', // Replace only if your Flutter DB table name is different
        columns: ['ParamValue', 'ParamDesc1'],
        where: 'LookupCode = ? AND IsActive = ?',
        whereArgs: ['LeadQueue', 'Y'],
        orderBy: 'SortOrder ASC',
      );

      arrLeadQueue.clear();
      arrLeadQueueID.clear();

      if (result.isNotEmpty) {
        for (final row in result) {
          final leadQueueId = row['ParamValue']?.toString().trim() ?? '';
          final leadQueueDesc = row['ParamDesc1']?.toString().trim() ?? '';

          if (leadQueueId.isNotEmpty &&
              leadQueueDesc.isNotEmpty &&
              leadQueueDesc.toLowerCase() != 'null') {
            arrLeadQueueID.add(leadQueueId);
            arrLeadQueue.add(leadQueueDesc);
          }
        }
      }

      if (mounted) {
        setState(() {});
      }

      print('Lead Queue IDs: $arrLeadQueueID');
      print('Lead Queue Descriptions: $arrLeadQueue');
    } catch (e) {
      print('Lead Queue loading error: $e');
    }
  }

  void onProductSelected(String? selectedValue) {
    if (selectedValue == null) return;

    final index = arrProduct.indexOf(selectedValue);

    if (index == -1 || index >= arrProductCode.length) {
      print('Product code not found for: $selectedValue');
      return;
    }

    setState(() {
      Product = selectedValue; // Product description
      productCode = arrProductCode[index]; // Matching Product code
    });

    print('Selected Product: $Product');
    print('Selected Product Code: $productCode');
  }

  void onPersonalDetailsClick() {
    if (selectedRequestChannel == null ||
        selectedRequestChannel!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Request Channel")),
      );
      return;
    }

    if (selectedLeadSource == null || selectedLeadSource!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Source")),
      );
      return;
    }

    if (selectedSubLeadSource == null ||
        selectedSubLeadSource!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Sub Source")),
      );
      return;
    }

    _tabController.animateTo(1);
  }

  void validateLeadSourceAndMoveNext() {
    if (selectedRequestChannel == null ||
        selectedRequestChannel!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Request Channel")),
      );
      return;
    }

    if (selectedLeadSource == null || selectedLeadSource!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Source")),
      );
      return;
    }

    if (selectedSubLeadSource == null ||
        selectedSubLeadSource!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Sub Source")),
      );
      return;
    }

    _tabController.animateTo(1);
  }

  void validatePersonalAndMoveNext() {
    final String first = firstName.text.trim();
    final String last = lastName.text.trim();
    final String mobileNo = mobile.text.trim();

    if (first.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First name can't be blank")),
      );
      return;
    }

    if (last.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Last name can't be blank")));
      return;
    }

    if (mobileNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobile No. can't be blank")),
      );
      return;
    }

    if (mobileNo.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobile Number should have 10 digits")),
      );
      return;
    }

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobileNo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mobile Number should start with digit 9 or 8 or 7 or 6",
          ),
        ),
      );
      return;
    }

    _tabController.animateTo(2);
  }

  void validateAddressAndMoveNext() {
    final String address1 = addr1.text.trim();
    final String address2 = addr2.text.trim();
    final String pin = pincode.text.trim();

    if (address1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address line 1 can't be blank")),
      );
      return;
    }

    if (address2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address line 2 can't be blank")),
      );
      return;
    }

    if (selectedState == null || selectedState!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select State")));
      return;
    }

    if (pin.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pin code can't be blank")));
      return;
    }

    if (!arrPinCode.contains(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select valid Pin Code.")),
      );
      return;
    }

    _tabController.animateTo(3);
  }

  Future<void> validateBusinessAndSubmit() async {
    if (BussinessType == null || BussinessType!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Business Type")),
      );
      return;
    }

    if (LOB == null || LOB!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select LOB")));
      return;
    }

    if (Product == null || Product!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select Product")));
      return;
    }

    if (SaleType == null || SaleType!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select Sale Type")));
      return;
    }

    if (LeadQueue == null || LeadQueue!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select Lead Queue")));
      return;
    }

    if (Remark.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Remark can't be blank")));
      return;
    }

    final int businessIndex = arrBusinessType.indexOf(BussinessType!);

    final String businessTypeId =
        businessIndex >= 0 && businessIndex < arrBusinessTypeID.length
        ? arrBusinessTypeID[businessIndex]
        : "";

    if (businessTypeId == "3") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Renewal lead creation is not allowed from mobile app.",
          ),
        ),
      );
      return;
    }

    await submitLead();
  }

  void handleClear() {
    if (selectedTabIndex == 0) {
      selectedRequestChannel = null;
      selectedLeadSource = null;
      selectedSubLeadSource = null;
    } else if (selectedTabIndex == 1) {
      firstName.clear();
      lastName.clear();
      mobile.clear();
    } else if (selectedTabIndex == 2) {
      addr1.clear();
      addr2.clear();
      addr3.clear();
      pincode.clear();
      selectedState = null;
      selectedStateId = null;
      arrPinCode.clear();
    } else if (selectedTabIndex == 3) {
      BussinessType = null;
      LOB = null;
      Product = null;
      SaleType = null;
      LeadQueue = null;
      Remark.clear();
    }
    setState(() {});
  }

  void handleNextorFinish() async {
    if (selectedTabIndex == 0) {
      validateLeadSourceAndMoveNext();
    } else if (selectedTabIndex == 1) {
      validatePersonalAndMoveNext();
    } else if (selectedTabIndex == 2) {
      validateAddressAndMoveNext();
    } else if (selectedTabIndex == 3) {
      await validateBusinessAndSubmit();
    }
  }

  Future<void> handleCreateLeadApiResponse({
    required Map<String, dynamic> response,
    required String uniqueRef,
  }) async {
    String message = "";
    String title = "";
    bool navigateToDashboard = false;

    try {
      final List<dynamic> table = response["Table"] ?? [];

      if (table.isNotEmpty) {
        for (int index = 0; index < table.length; index++) {
          final Map<String, dynamic> result = Map<String, dynamic>.from(
            table[index],
          );

          if (result.containsKey("message") &&
              result["message"]?.toString() == "Success") {
            final String leadId = result["LeadId"]?.toString() ?? "";

            final String apiUniqueRef =
                result["UniqueRef"]?.toString() ?? uniqueRef;

            title = "Lead Creation Success";
            message =
                "Lead has been created successfully.\n\nLead Number : $leadId";

            navigateToDashboard = true;

            await updateLeadAfterApiSuccess(
              leadId: leadId,
              uniqueRef: apiUniqueRef,
            );

            final String msg =
                "Lead has been created successfully.\nLead Number : $leadId";

            await insertIntoNotificationDetailsLocal(
              notification: "Lead Creation",
              remark1: msg,
              dateTime: dbDateTime(DateTime.now()),
              userId: StaticVariables.mSAPCode,
              module: "Create Lead",
            );

            await updateCalendarAfterApiSuccess(uniqueRef: apiUniqueRef);
          } else if (result.containsKey("ResponseCode")) {
            title = "Alert";
            message =
                result["ErrorDescription"]?.toString() ??
                "Lead Creation Failure";

            navigateToDashboard = false;

            final String msg = "Lead creation failed due to $message";

            await insertIntoNotificationDetailsLocal(
              notification: "Lead Creation Failed",
              remark1: msg,
              dateTime: dbDateTime(DateTime.now()),
              userId: StaticVariables.mSAPCode,
              module: "Create Lead",
            );
          } else {
            title = "Alert";
            message = "Lead Creation Failure";
            navigateToDashboard = false;
          }
        }
      } else {
        title = "Alert";
        message = "Lead Creation Failure";
        navigateToDashboard = false;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CommonSinglePopup(
            title: title,
            message: message,
            onOk: () async {
              // Navigator.pop(context);

              // if (navigateToDashboard) {
              //   Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(builder: (_) => const DashboardScreen()),
              //     (route) => false,
              //   );
              // }
              Navigator.of(context, rootNavigator: true).pop();

              // 2. Wait for popup to close
              await Future.delayed(const Duration(milliseconds: 100));

              if (!mounted) return;

              // 3. If success, pop CreateLeadScreen and go back to dashboard
              if (navigateToDashboard) {
                Navigator.of(context).pop();
              }
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   if (!mounted) return;

              //   if (navigateToDashboard) {
              //     Navigator.of(context).pushAndRemoveUntil(
              //       MaterialPageRoute(builder: (_) => const DashboardScreen()),
              //       (route) => false,
              //     );
              //   }
              // }
              // );
            },
          );
        },
      );

      print("$title : $message");
    } catch (e) {
      print("handleCreateLeadApiResponse Error: $e");

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CommonSinglePopup(
            title: "Alert",
            message: "Lead Creation Failure",
            onOk: () {
              Navigator.pop(context);
            },
          );
        },
      );
    }
  }

  // void submitLead() {
  //   print("Submit API called");
  // }

  Future<void> submitLead() async {
    // if (!isValidateBusinessDetails()) {
    //   return;
    // }

    print("Submit API called ");

    try {
      final String uniqueRef = DateTime.now().millisecondsSinceEpoch.toString();

      final String reqChannelId =
          arrReqChannelId[arrReqChannel.indexOf(selectedRequestChannel!)];

      final String leadSource =
          arrLeadSourceId[arrLeadSource.indexOf(selectedLeadSource!)];

      final String leadSubSource =
          arrSubLeadSourceId[arrSubLeadSource.indexOf(selectedSubLeadSource!)];

      final String businessType =
          arrBusinessTypeID[arrBusinessType.indexOf(BussinessType!)];

      final String LOBCode = arrLOBCode[arrLOB.indexOf(LOB!)];

      final String prodCode = productCode ?? "";

      final String saleType = arrSaleTypeID[arrSaleType.indexOf(SaleType!)];

      final String leadQueue = arrLeadQueueID[arrLeadQueue.indexOf(LeadQueue!)];

      final String name = "${firstName.text.trim()} ${lastName.text.trim()}";

      final String mobileTel = mobile.text.trim();

      final String address1 = addr1.text.trim();
      final String address2 = addr2.text.trim();
      final String address3 = addr3.text.trim();

      final String stateCode = selectedStateId ?? "";

      final String pinCode = pincode.text.trim();

      final String cityCode = "";
      final String districtCode = "";
      final String area = "";
      final String tempSrvcReqDtlCode = uniqueRef;

      final bool isLocalSaved = await insertCreateLeadLocal(
        uniqueRef: uniqueRef,

        reqChannelId: reqChannelId,
        reqChannelDesc: selectedRequestChannel ?? "",

        leadSource: leadSource,
        leadSourceDesc: selectedLeadSource ?? "",

        leadSubSource: leadSubSource,
        leadSubSourceDesc: selectedSubLeadSource ?? "",

        businessType: businessType,
        businessTypeDesc: BussinessType ?? "",

        lobCode: LOBCode,
        lobDesc: LOB ?? "",

        prodCode: prodCode,
        prodName: Product ?? "",

        saleType: saleType,
        saleTypeDesc: SaleType ?? "",

        leadQueue: leadQueue,
        leadQueueDesc: LeadQueue ?? "",

        name: name,
        mobileTel: mobileTel,

        addr1: address1,
        addr2: address2,
        addr3: address3,

        stateCode: stateCode,
        districtCode: districtCode,
        cityCode: cityCode,
        area: area,
        pinCode: pinCode,

        remark: Remark.text.trim(),

        userId: StaticVariables.mSAPCode,
        userName: StaticVariables.mUserName ?? "",
      );

      if (!isLocalSaved) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lead local save failed")));
        return;
      }

      final response = await createLeadFromMob(
        sapCode: StaticVariables.mSAPCode,
        reqChannelId: reqChannelId,
        leadSource: leadSource,
        leadSubSource: leadSubSource,
        businessType: businessType,
        LOBCode: LOBCode,
        prodCode: prodCode,
        saleType: saleType,
        LeadQueue: leadQueue,
        name: name,
        mobileTel: mobileTel,
        addr1: address1,
        addr2: address2,
        addr3: address3,
        cityCode: cityCode,
        districtCode: districtCode,
        stateCode: stateCode,
        pinCode: pinCode,
        area: area,
        TempSrvcReqDtlCode: tempSrvcReqDtlCode,
        callerId: StaticVariables.callerId!,
        callerPass: StaticVariables.callerPass!,
        tokenId: StaticVariables.TokenId,
      );

      print("Create Lead Response: $response");

      await handleCreateLeadApiResponse(
        response: response,
        uniqueRef: uniqueRef,
      );
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getReqChannelDataFrmMST(); // <-- call here
    // getReqChnlSourceMappingFrmMST();
    getBusinessTypeDataFrmMST();
    loadStates();
    getMSTLOBDataFrmMST();
    getLeadQueueDataFrmMST();
    getSalesTypeDataFrmMST();

    _tabController = TabController(length: 4, initialIndex: 0, vsync: this);

    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        // automaticallyImplyLeading: false,
        //title: const Text("Create Lead"),
        bottom: ButtonsTabBar(
          controller: _tabController,
          backgroundColor: Colors.blue,
          unselectedBackgroundColor: Colors.white,
          borderWidth: 1.5,
          borderColor: Colors.black,

          height: 70,

          // contentPadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(icon: Icon(Icons.menu, size: 30)),
            Tab(icon: Icon(Icons.person, size: 30)),
            Tab(icon: Icon(Icons.location_on, size: 30)),
            Tab(icon: Icon(Icons.work, size: 30)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          leadSourceTab(),
          personalDetailsTab(),
          addressTab(),
          businessDetailsTab(),
        ],
      ),
    );
  }

  Widget bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                handleClear();
              },
              child: const Text("Clear"),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                handleNextorFinish();
              },
              child: Text(selectedTabIndex == 3 ? "Submit" : "Next"),
            ),
          ),
        ],
      ),
    );
  }

  Widget leadSourceTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // DropdownButtonFormField(
              //   value: selectedRequestChannel,
              //   items: [],
              //   onChanged: (v) => setState(() => selectedRequestChannel = v),
              //   decoration: const InputDecoration(labelText: "Request Channel"),
              // ),
              DropdownButtonFormField<String>(
                value: selectedRequestChannel,
                items: arrReqChannel.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? v) {
                  setState(() {
                    selectedRequestChannel = v;
                  });
                  int index = arrReqChannel.indexOf(v!);

                  if (index != -1) {
                    getReqChnlSourceMappingFrmMST(arrReqChannelId[index]);
                  }
                },
                decoration: const InputDecoration(labelText: "Request Channel"),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedLeadSource,
                items: arrLeadSource.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? v) {
                  setState(() {
                    selectedLeadSource = v;
                  });

                  int index = arrLeadSource.indexOf(v!);

                  if (index != -1) {
                    getLeadSubSourceDataFrmMST(arrLeadSourceId[index]);
                  }
                },
                decoration: const InputDecoration(labelText: "Lead Source"),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedSubLeadSource,
                items: arrSubLeadSource.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (String? v) {
                  setState(() {
                    selectedSubLeadSource = v;
                  });
                },
                decoration: const InputDecoration(labelText: "Sub Lead Source"),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        bottomButtons(),
      ],
    );
  }

  Widget personalDetailsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: firstName,
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: mobile,
                decoration: const InputDecoration(labelText: "Mobile Number"),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),

        bottomButtons(),
      ],
    );
  }

  Widget addressTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: addr1,
                decoration: const InputDecoration(labelText: "Address Line 1"),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: addr2,
                decoration: const InputDecoration(labelText: "Address Line 2"),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: addr3,
                decoration: const InputDecoration(labelText: "Address Line 3"),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(labelText: "State"),
                items: arrState.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),

                // onChanged: (String? v) async {
                //   if (v == null) return;

                //   final index = arrState.indexOf(v);

                //   selectedState = v;
                //   selectedStateId = arrStateID[index];

                //   loadPins(selectedStateId!);

                //   setState(() {
                //     selectedState = v;
                //   });
                // },
                //changed by rahul
                onChanged: (String? v) async {
                  if (v == null) return;

                  final index = arrState.indexOf(v);

                  if (index == -1) return;

                  setState(() {
                    selectedState = v;
                    selectedStateId = index >= 0 ? arrStateID[index] : null;
                    //selectedStateId = arrStateID[index];

                    // Remove previous state's pincode data
                    pincode.clear();
                    arrPinCode.clear();
                  });
                  if (selectedStateId != null && selectedStateId!.isNotEmpty) {
                    await loadPins(selectedStateId!);
                  }

                  // await loadPins(selectedStateId!);
                  print("Selected State: $selectedState");
                  print("Selected State Code/Id: $selectedStateId");
                },
              ),
              const SizedBox(height: 14),

              RawAutocomplete<String>(
                textEditingController: pincode,
                focusNode: pincodeFocusNode,

                optionsBuilder: (TextEditingValue textEditingValue) {
                  final typedValue = textEditingValue.text.trim();

                  if (typedValue.length < 1) {
                    return const Iterable<String>.empty();
                  }

                  return arrPinCode.where((pin) {
                    return pin.startsWith(typedValue);
                  });
                },

                onSelected: (String selectedPin) {
                  setState(() {
                    pincode.text = selectedPin;
                  });
                  print("Selected pincode: $selectedPin");
                },

                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController controller,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Pincode",
                          hintText: "Type pincode",
                        ),
                      );
                    },

                optionsViewBuilder:
                    (
                      BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options,
                    ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 5,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 32,
                            height: 200,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final pin = options.elementAt(index);

                                return ListTile(
                                  title: Text(pin),
                                  onTap: () => onSelected(pin),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
              ),
            ],
          ),
        ),
        bottomButtons(),
      ],
    );
  }

  Widget businessTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: const [
              // Business fields
            ],
          ),
        ),
        bottomButtons(),
      ],
    );
  }

  Widget address() {
  Widget businessDetailsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                value: BussinessType,
                items: arrBusinessType.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (String? v) {
                  setState(() {
                    BussinessType = v;
                  });
                },
                decoration: const InputDecoration(labelText: "Business Type"),
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: LOB,
                items: arrLOB.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (String? v) async {
                  if (v == null) return;

                  final int index = arrLOB.indexOf(v);
                  if (index == -1 || index >= arrLOBCode.length) {
                    print("LOB code not found for: $v");
                    return;
                  }
                  final String selectLobCode = arrLOBCode[index];
                  setState(() {
                    LOB = v;

                    //Reset the old value
                    Product = null;
                    productCode = null;
                    arrProduct.clear();
                    arrProductCode.clear();
                  });

                  print("Selected LOB: $LOB");
                  print("Selected LOB Code: $selectLobCode");

                  await getMSTProductData(selectLobCode);
                },
                decoration: const InputDecoration(labelText: "LOB"),
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: Product,
                items: arrProduct.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                // onChanged: onProductSelected,
                onChanged: (String? v) {
                  if (v == null) return;

                  final index = arrProduct.indexOf(v);

                  setState(() {
                    Product = v;
                    productCode = index >= 0 ? arrProductCode[index] : null;
                  });
                },
                decoration: const InputDecoration(labelText: "Product"),
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: SaleType,
                items: arrSaleType.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (String? v) {
                  setState(() {
                    SaleType = v;
                  });
                },
                decoration: const InputDecoration(labelText: "Sales Type"),
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: LeadQueue,
                items: arrLeadQueue.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (String? v) {
                  setState(() {
                    LeadQueue = v;
                  });
                },
                decoration: const InputDecoration(labelText: "Lead Queue"),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: Remark,
                decoration: const InputDecoration(labelText: "Remark"),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        bottomButtons(),
      ],
    );
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    mobile.dispose();

    addr1.dispose();
    addr2.dispose();
    addr3.dispose();
    pincode.dispose();
    pincodeFocusNode.dispose();
    Remark.dispose();

    _tabController.dispose();

    super.dispose();
  }
}
