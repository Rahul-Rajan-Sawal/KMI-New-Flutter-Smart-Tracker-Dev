import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';

class LeadDetailsRepository {

  static Future<Map<String, dynamic>?> fetchLeadDetailsById(
    String leadId, {
    List<String>? columnsToDecrypt,
  }) async {

    try {

      final db = await DatabaseHelper.instance.database;
     final encryptedLeadId = CommonUtil.encryptIfNotEmpty(leadId);
      final rows = await db.query(
        "LeadDetails",
        where: "SrvcReqDtlCode = ?",
        whereArgs: [encryptedLeadId],
      );


      if (rows.isEmpty) return null;
      final decryptedRows = _decryptRows({
        "rows": rows,
        "columns": columnsToDecrypt ??
            [
              "Name",
              "ProdName",
              "SrvcReqDtlCode",
            ]
      });
      print(decryptedRows);

      return decryptedRows.first;

    } catch (e, stackTrace) {

      print("LeadDetailsRepository ERROR: $e");
      print("StackTrace: $stackTrace");

      return null;
    }
  }
}

/// Same decrypt logic reused
List<Map<String, dynamic>> _decryptRows(Map<String, dynamic> params) {

  try {

    final List<Map<String, dynamic>> rows =
        List<Map<String, dynamic>>.from(params["rows"]);

    final List<String> columns =
        List<String>.from(params["columns"]);

    return rows.map((row) {

      final Map<String, dynamic> decryptedRow = {};

      for (var key in row.keys) {

        try {

          decryptedRow[key] = columns.contains(key)
              ? CommonUtil.decryptIfNotEmpty(row[key])
              : row[key];

        } catch (e) {

          print("Decryption error for column: $key");
          print("Value: ${row[key]}");
          print("Error: $e");

          decryptedRow[key] = row[key];
        }

      }

      return decryptedRow;

    }).toList();

  } catch (e, stackTrace) {

    print("DecryptRows ERROR: $e");
    print("StackTrace: $stackTrace");

    return [];
  }
}