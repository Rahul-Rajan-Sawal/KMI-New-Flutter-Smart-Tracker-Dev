import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';


class OfflineRepository {

  /// 🔹 LOB LIST
  static Future<Map<String, List<String>>> getLOBList() async {
    try {
   // final db = await OfflineDBHelper.instance.database;
  final db = await OfflineDBHelper.getDatabase(); 
    final result = await db.rawQuery(
        "SELECT LOBDesc1, LOBCode FROM CBFrmMSTLOB");

      print(await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'"));


    List<String> arrLOBDesc = [];
    List<String> arrLOBCode = [];

    for (var row in result) {
      arrLOBDesc.add(row['LOBDesc1'].toString());
      arrLOBCode.add(row['LOBCode'].toString());
    }

    return {
      "desc": arrLOBDesc,
      "code": arrLOBCode
    };
     } catch (e, stackTrace) {
    print("Error : $e");
    print(stackTrace);

    return {
      "desc": [],
      "code": []
    };}
  }



static Future<Map<String, List<String>>> getProductList(String lobCode) async {
  try {
    final db = await OfflineDBHelper.getDatabase();

    // 🔹 Step 1: Get product codes from mapping table
    final mappingResult = await db.rawQuery(
      "SELECT ProdCode FROM CBFrmLOBProdMapping WHERE LOBCode = ?",
      [lobCode],
    );

    final prodCodes = mappingResult
        .map((e) => e['ProdCode'].toString())
        .toList();

    if (prodCodes.isEmpty) {
      return {"desc": [], "code": []};
    }

    // 🔹 Step 2: Create placeholders (?, ?, ?)
    final placeholders = List.filled(prodCodes.length, '?').join(',');

    // 🔹 Step 3: Fetch actual product details
    final result = await db.rawQuery(
      "SELECT ProdDesc1, ProdCode FROM CBFrmMSTProduct WHERE ProdCode IN ($placeholders)",
      prodCodes,
    );

    List<String> arrProductDesc = [];
    List<String> arrProductCode = [];

    for (var row in result) {
      arrProductDesc.add(row['ProdDesc1']?.toString() ?? '');
      arrProductCode.add(row['ProdCode']?.toString() ?? '');
    }

    return {
      "desc": arrProductDesc,
      "code": arrProductCode
    };

  } catch (e, stackTrace) {
    print("Error: $e");
    print(stackTrace);

    return {"desc": [], "code": []};
  }
}

}