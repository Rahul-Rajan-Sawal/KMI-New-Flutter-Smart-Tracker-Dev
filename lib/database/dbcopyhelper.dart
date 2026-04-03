import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DatabaseCopyHelper {
  final BuildContext context;

  DatabaseCopyHelper(this.context);

  /// Automatically finds all .db files in the app's `databases` folder
  /// and copies them to the Downloads folder
  Future<void> copyDatabaseToDownloads() async {
    try {
      // Get the path to the app's databases folder
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbFolderPath = p.join(appDocDir.parent.path, 'databases'); // <-- fixed path
      Directory dbFolder = Directory(dbFolderPath);

      if (!await dbFolder.exists()) {
        print('Database folder not found at $dbFolderPath');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Database folder not found!')),
          );
        }
        return;
      }

      // List all files ending with .db
      List<FileSystemEntity> dbFiles = dbFolder
          .listSync()
          .where((f) => f.path.endsWith('.db'))
          .toList();

      if (dbFiles.isEmpty) {
        print('No database files found!');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No database files found!')),
          );
        }
        return;
      }

      // Copy each DB file to Downloads
      for (FileSystemEntity dbFile in dbFiles) {
        File file = File(dbFile.path);
        String fileName = file.uri.pathSegments.last;
        String newPath = '/storage/emulated/0/Download/$fileName';
        await file.copy(newPath);
        print('Database copied to $newPath');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dbFiles.length} DB file(s) copied!')),
        );
      }
    } catch (e) {
      print('Error copying database: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}