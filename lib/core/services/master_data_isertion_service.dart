import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class MastersMappingInsertService {

  /// CBLMSChnlSourceMapping
  static Future<void> insertChnlSourceMapping(
      Transaction txn, List<dynamic> list) async {

    final batch = txn.batch();

    for (var item in list) {
      batch.insert(
        "CBLMSChnlSourceMapping",
        {
          "ChnlSrvcMapCode": EncryptionUtil.encrypt(item["ChnlSrvcMapCode"].toString()),
          "ReqChannelId": EncryptionUtil.encrypt(item["ReqChannelId"].toString()),
          "ReqChannelDesc": EncryptionUtil.encrypt(item["ReqChannelDesc"].toString()),
          "LeadSourceId": EncryptionUtil.encrypt(item["LeadSourceId"].toString()),
          "LeadSourceDesc": EncryptionUtil.encrypt(item["LeadSourceDesc"].toString()),
          "LeadSubSourceId": EncryptionUtil.encrypt(item["LeadSubSourceId"].toString()),
          "LeadSubSourceDesc": EncryptionUtil.encrypt(item["LeadSubSourceDesc"].toString()),
          "isActive": EncryptionUtil.encrypt(item["isActive"].toString()),
          "CreateBy": EncryptionUtil.encrypt(item["CreateBy"].toString()),
          "CreateDtim": EncryptionUtil.encrypt(item["CreateDtim"].toString()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  ///CBFrmLOBProdMapping
  static Future<void> insertLOBProdMapping(
      Transaction txn, List<dynamic> list) async {

    final batch = txn.batch();

    for (var item in list) {
      batch.insert(
        "CBFrmLOBProdMapping",
        {
          "LOBProdMapCode": EncryptionUtil.encrypt(item["LOBProdMapCode"].toString()),
          "LOBCode": EncryptionUtil.encrypt(item["LOBCode"].toString()),
          "ProdCode": EncryptionUtil.encrypt(item["ProdCode"].toString()),
          "BrochureURL": EncryptionUtil.encrypt(item["BrochureURL"].toString()),
          "WebQuoteURL": EncryptionUtil.encrypt(item["WebQuoteURL"].toString()),
          "isRequiredPreInsp": EncryptionUtil.encrypt(item["isRequiredPreInsp"].toString()),
          "CreatedBy": EncryptionUtil.encrypt(item["CreatedBy"].toString()),
          "CreateDTim": EncryptionUtil.encrypt(item["CreateDTim"].toString()),
          "IsRetail": EncryptionUtil.encrypt(item["IsRetail"].toString()),
          "RenewalRDLC": EncryptionUtil.encrypt(item["RenewalRDLC"].toString()),
          "RDLCURL": EncryptionUtil.encrypt(item["RDLCURL"].toString()),
          "RDLCServer": EncryptionUtil.encrypt(item["RDLCServer"].toString()),
          "IsActive": EncryptionUtil.encrypt(item["IsActive"].toString()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  ///CBLMSLeadActivityMapping
  static Future<void> insertLeadActivityMapping(
      Transaction txn, List<dynamic> list) async {

    final batch = txn.batch();

    for (var item in list) {
      batch.insert(
        "CBLMSLeadActivityMapping",
        {
          "ActMapCode": EncryptionUtil.encrypt(item["ActMapCode"].toString()),
          "LeadType": EncryptionUtil.encrypt(item["LeadType"].toString()),
          "Biztype": EncryptionUtil.encrypt(item["Biztype"].toString()),
          "Actvitycode": EncryptionUtil.encrypt(item["Actvitycode"].toString()),
          "IssActivity": EncryptionUtil.encrypt(item["IssActivity"].toString()),
          "CreatedBy": EncryptionUtil.encrypt(item["CreatedBy"].toString()),
          "CreateDTim": EncryptionUtil.encrypt(item["CreateDTim"].toString()),
          "LeadSourceId": EncryptionUtil.encrypt(item["LeadSourceId"].toString()),
          "ReqChannelId": EncryptionUtil.encrypt(item["ReqChannelId"].toString()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// CBFRMLmsReqChannelLeadSourceMaping
  static Future<void> insertReqChannelLeadSourceMapping(
      Transaction txn, List<dynamic> list) async {

    final batch = txn.batch();

    for (var item in list) {
      batch.insert(
        "CBFRMLmsReqChannelLeadSourceMaping",
        {
          "ReqChannelId": EncryptionUtil.encrypt(item["ReqChannelId"].toString()),
          "LeadSourceId": EncryptionUtil.encrypt(item["LeadSourceId"].toString()),
          "MstrModuleCode": EncryptionUtil.encrypt(item["MstrModuleCode"].toString()),
          "CreatedBy": EncryptionUtil.encrypt(item["CreatedBy"].toString()),
          "CreatedDate": EncryptionUtil.encrypt(item["CreatedDate"].toString()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  ///  CBFRMLmsReqChannelMaping
  static Future<void> insertReqChannelMapping(
      Transaction txn, List<dynamic> list) async {

    final batch = txn.batch();

    for (var item in list) {
      batch.insert(
        "CBFRMLmsReqChannelMaping",
        {
          "ReqChannelId": EncryptionUtil.encrypt(item["ReqChannelId"].toString()),
          "MstrModuleCode": EncryptionUtil.encrypt(item["MstrModuleCode"].toString()),
          "CreatedBy": EncryptionUtil.encrypt(item["CreatedBy"].toString()),
          "CreatedDate": EncryptionUtil.encrypt(item["CreatedDate"].toString()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }
}