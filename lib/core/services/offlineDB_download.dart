import 'dart:io';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DBDownloadService {
  static Future<void> downloadDBsIfNeeded() async {
    final dbPath = await getDatabasesPath();

    List<String> dbFiles = [
      "OfflineDB.db",   //
      "ARTL_StatePin.db"
    ];

    for (String fileName in dbFiles) {
      final path = join(dbPath, fileName);
      final file = File(path);

      // ✅ SAME AS ANDROID (if not exists)
      if (await file.exists()) {
        print("$fileName already exists");
        continue;
      }

      try {
        print("Downloading $fileName...");

        final url = Uri.parse(StaticVariables.ContentURL! + fileName);
        final response = await http.get(url);

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          print("$fileName downloaded ✅");
        } else {
          print("Download failed: $fileName");
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }
}