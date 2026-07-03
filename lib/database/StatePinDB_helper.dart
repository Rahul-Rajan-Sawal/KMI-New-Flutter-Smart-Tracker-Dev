import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class StatePinDBHelper {
  static Database? _db;
  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, "ARTL_StatePin.db");

    final password = EncryptionUtil.getHashValue(StaticVariables.dbKey!);

    _db = await openDatabase(path, password: password);

    return _db!;
  }
}
