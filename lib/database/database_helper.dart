import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'tables.dart';

class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, StaticVariables.DbName);

    final dbPassword = EncryptionUtil.getHashValue(StaticVariables.dbKey!);

    return await openDatabase(
      path,
      password: dbPassword,
      version: StaticVariables.DbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DbTables.createUserTable);
    try {
      print("Tables creation initiated");
      await db.execute(DbTables.ceadDetails);
      await db.execute(DbTables.createTbl_DashboardData_Mob);
      await db.execute(DbTables.createTbl_TeamDashboardData_Mob);
      await db.execute(DbTables.CreateTbl_CBFrmMSTLOB);
      await db.execute(DbTables.CreateTbl_CBFrmMSTProduct);      
      await db.execute(DbTables.CreateTBL_CUSTOMER_CNT_DTLS);
      print("**********************Tables Created---------------------------@@");
    } catch (e) {
      print("exception catched :  $e");
    }

    // ACTIVITY TRACKER TABLE
    await db.execute(DbTables.lmsLeadActivityTracker);
  }

Future<void> resetLeadTables() async {
  final db = await database;

  try {
    await db.transaction((txn) async {
      // 1. Drop tables
      await txn.execute(DbTables.dropLeadDetails);
      await txn.execute(DbTables.dropLMSLeadActivityTracker);

      // 2. Recreate tables
      await txn.execute(DbTables.ceadDetails); // LeadDetails
      await txn.execute(DbTables.lmsLeadActivityTracker);
    });

    print("Lead tables reset successfully ");
  } catch (e) {
    print("Error resetting lead tables : $e");
  }
}


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute(DbTables.dropUserTable);
    await db.execute(DbTables.dropLeadDetails);
    await db.execute(DbTables.dropLMSLeadActivityTracker);
    await db.execute(DbTables.dropDashboardData_Mob);
    await db.execute(DbTables.dropCalendarData_Mob);
    await db.execute(DbTables.dropTeamDashboardData_Mob);
    await db.execute(DbTables.dropTBL_CUSTOMER_CNT_DTLS);
    await _onCreate(db, newVersion);
  }

  Future<Map<String, dynamic>?> getUserByUserId(String sapCode) async {
    final db = await database;

    final encryptedUserId = EncryptionUtil.encrypt(sapCode.toUpperCase());

    final result = await db.query(
      'iUser',
      where: 'UserId = ?',
      whereArgs: [encryptedUserId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first; 
    }
    return null;
  }

}
