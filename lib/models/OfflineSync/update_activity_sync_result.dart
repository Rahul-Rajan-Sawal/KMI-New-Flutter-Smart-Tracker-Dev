class UpdateActivitySyncResult {
  final int total;
  final int success;
  final int failed;

  const UpdateActivitySyncResult({
    required this.total,
    required this.success,
    required this.failed,
  });
}

// class UpdateActivitySyncService {
//   UpdateActivitySyncService._();

//   static bool isSyncing = false;

//   static Future<UpdateActivitySyncResult> syncPendingActivities() async {
//     if (isSyncing) {
//       return const UpdateActivitySyncResult(total: 0, success: 0, failed: 0);
//     }

//     isSyncing = true;

//     try {
//       return const UpdateActivitySyncResult(total: 0, success: 0, failed: 0);
//     } finally {
//       isSyncing = false;
//     }
//   }
// }
