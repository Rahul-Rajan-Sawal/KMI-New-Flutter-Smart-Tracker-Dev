import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../common/encryption_util.dart';
import '../core/static_variables.dart';

class OfflineDBHelper {
  static Database? _db;

  static get instance => null;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();

    // IMPORTANT: Use Offline DB name ONLY
    final path = join(dbPath, "OfflineDB.db");

    final password =
        EncryptionUtil.getHashValue(StaticVariables.dbKey!);

    _db = await openDatabase(
      path,
      password: password,
    );

    return _db!;
  }
}