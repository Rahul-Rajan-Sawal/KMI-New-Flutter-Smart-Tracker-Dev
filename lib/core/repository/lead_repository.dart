import 'package:flutter/foundation.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
// import 'package:flutter_application_1/common/common_util.dart';
// import 'package:flutter_application_1/database/database_helper.dart';
 
class LeadRepository {
  /// Fetch leads from DB and decrypt only required columns
  // static Future<List<Map<String, dynamic>>> fetchDecryptedLeads(
  //     {List<String>? columnsToDecrypt}) async {
  //   final db = await DatabaseHelper.instance.database;
  //   final rows = await db.query("LeadDetails");
 
  //   // Use compute only for the columns you want decrypted
  //   return compute(_decryptRows, {
  //     "rows": rows,
  //     "columns": columnsToDecrypt ??
  //         ["Name", "ProdName", "SrvcReqDtlCode"] // default columns
  //   });
  // }
  
  static Future<List<Map<String, dynamic>>> fetchDecryptedLeads(
      {List<String>? columnsToDecrypt}) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query("LeadDetails");
 
    return _decryptRows({
      "rows": rows,
      "columns": columnsToDecrypt ?? ["Name", "ProdName", "SrvcReqDtlCode"]
    });
  }
}
 
/// 🔹 Top-level function needed for compute()
List<Map<String, dynamic>> _decryptRows(Map<String, dynamic> params) {
  final List<Map<String, dynamic>> rows =
      List<Map<String, dynamic>>.from(params["rows"]);
  final List<String> columns = List<String>.from(params["columns"]);
 
  return rows.map((row) {
    final Map<String, dynamic> decryptedRow = {};
    for (var key in row.keys) {
    //  print("Key: $key | Value: ${row[key]} | Type: ${row[key].runtimeType}");
 
      decryptedRow[key] = columns.contains(key)
          ? CommonUtil.decryptIfNotEmpty(row[key])
          : row[key];
    }
    //print(decryptedRow);
    return decryptedRow;
  }).toList();
}
 
 