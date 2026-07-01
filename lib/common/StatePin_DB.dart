import 'package:flutter_bottom_nav/database/StatePinDB_helper.dart';

class StatePinDB {
  Future<List<String>> getStateID(String colName, String stateCode) async {
    final db = await StatePinDBHelper.getDatabase();

    final result = await db.query(
      'State',
      columns: ['state_id'],
      where: 'state_code=?',
      whereArgs: [stateCode],
    );

    if (result.isEmpty) {
      return [];
    }

    final stateId = result.first['state_id'].toString();

    return await getPin(stateId);
  }

  Future<int> getSelectedPinCnt(String pinCode) async {
    final db = await StatePinDBHelper.getDatabase();

    final result = await db.query(
      'Pincode',
      columns: ['pincode'],
      where: 'pincode=?',
      whereArgs: [pinCode],
    );

    return result.length;
  }

  Future<String> getStateCode(String stateId) async {
    final db = await StatePinDBHelper.getDatabase();

    final result = await db.query(
      'State',
      columns: ['state_code'],
      where: 'state_id=?',
      whereArgs: [stateId],
    );

    if (result.isEmpty) {
      return '';
    }
    return result.first['state_code'].toString().trim();
  }

  Future<int> getStateofPinCnt(String pinCode, String stateCode) async {
    final db = await StatePinDBHelper.getDatabase();
    final stateId = await getStateIDValue(stateCode);

    final pinResult = await db.query(
      'Pincode',
      columns: ['state_id'],
      where: 'pincode=? AND state_id=?',
      whereArgs: [pinCode, stateId],
    );

    if (pinResult.isEmpty) {
      return 0;
    }

    final stateResult = await db.query(
      'State',
      columns: ['state_id'],
      where: 'state_id=? AND state_code=?',
      whereArgs: [pinResult.first['state_id'].toString(), stateCode],
    );

    return stateResult.length;
  }

  Future<String> getStateIDValue(String stateCode) async {
    final db = await StatePinDBHelper.getDatabase();

    final result = await db.query(
      'State',
      columns: ['state_id'],
      where: 'state_code=?',
      whereArgs: [stateCode],
    );

    if (result.isEmpty) return '';

    return result.first['state_id'].toString();
  }

  Future<List<String>> getPin(String stateId) async {
    final db = await StatePinDBHelper.getDatabase();

    final result = await db.query(
      'Pincode',
      columns: ['pincode'],
      where: 'state_id=?',
      whereArgs: [stateId],
      orderBy: 'pincode ASC',
    );

    return result.map((e) => e['pincode'].toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getAllState() async {
    final db = await StatePinDBHelper.getDatabase();

    return await db.query('State', columns: ['state_id', 'state_code']);
  }

  Future<List<Map<String, dynamic>>> allPins() async {
    final db = await StatePinDBHelper.getDatabase();

    return await db.query('Pincode', columns: ['pincode', 'state_id']);
  }
}
