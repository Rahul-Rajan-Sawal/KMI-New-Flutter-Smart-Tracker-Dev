
import 'package:flutter_bottom_nav/core/services/master_data_isertion_service.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/database/tables.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class MastersRepository {

  static Future<void> insertMasters(Map<String, dynamic> json) async {
    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {

      print("Masters Sync Started");

      // tables exist check
      await _createTables(txn);

      /// Delete old master data
      await _clearOldData(txn);

      /// Insert newdata
      await MastersMappingInsertService.insertChnlSourceMapping(
          txn, json['Table'] ?? []);

      await MastersMappingInsertService.insertLOBProdMapping(
          txn, json['Table1'] ?? []);

      await MastersMappingInsertService.insertLeadActivityMapping(
          txn, json['Table2'] ?? []);

      await MastersMappingInsertService.insertReqChannelLeadSourceMapping(
          txn, json['Table3'] ?? []);

      await MastersMappingInsertService.insertReqChannelMapping(
          txn, json['Table4'] ?? []);

      print("Masters Sync Completed Successfully");
    });
  }

  /// Create tables 
  static Future<void> _createTables(Transaction txn) async {
    await txn.execute(DbTables.createCBLMSChnlSourceMapping);
    await txn.execute(DbTables.createCBFrmLOBProdMapping);
    await txn.execute(DbTables.createCBLMSLeadActivityMapping);
    await txn.execute(DbTables.createReqChannelLeadSourceMap);
    await txn.execute(DbTables.createReqChannelMap);
  }

  /// Clear old data
  static Future<void> _clearOldData(Transaction txn) async {
    await txn.delete("CBLMSChnlSourceMapping");
    await txn.delete("CBFrmLOBProdMapping");
    await txn.delete("CBLMSLeadActivityMapping");
    await txn.delete("CBFRMLmsReqChannelLeadSourceMaping");
    await txn.delete("CBFRMLmsReqChannelMaping");
  }
}