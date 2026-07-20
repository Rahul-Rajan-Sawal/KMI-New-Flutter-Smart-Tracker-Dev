import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/core/services/update_activity_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool wifiSync = true;
  bool mobileSync = true;
  bool notification = true;
  bool isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            /// NETWORK SETTINGS
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: const [
                        Icon(Icons.wifi),
                        SizedBox(width: 10),
                        Text(
                          "Network Settings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// WIFI SYNC
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Sync Over Wi-Fi",
                          style: TextStyle(fontSize: 16),
                        ),

                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: wifiSync,
                            onChanged: (value) {
                              setState(() {
                                wifiSync = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    /// MOBILE DATA SYNC
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Sync Over Mobile Data",
                          style: TextStyle(fontSize: 16),
                        ),

                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: mobileSync,
                            onChanged: (value) {
                              setState(() {
                                mobileSync = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSyncing
                            ? null
                            : () async {
                                setState(() => isSyncing = true);

                                try {
                                  final result =
                                      await UpdateActivitySyncService.syncPendingActivities();

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.total == 0
                                            ? "No pending activities found."
                                            : "Sync completed: ${result.success} successful, "
                                                  "${result.failed} failed.",
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => isSyncing = false);
                                  }
                                }
                              },
                        icon: isSyncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(isSyncing ? "Syncing..." : "Sync Now"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton.icon(
                    //     onPressed: () {
                    //       // TODO: Sync logic
                    //     },
                    //     icon: const Icon(Icons.sync),
                    //     label: const Text("Sync Now"),
                    //     style: ElevatedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(vertical: 14),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // InkWell(
                    //   onTap: () {},

                    //   child: const Padding(
                    //     padding: EdgeInsets.all(8),

                    //     child: Text(
                    //       "Sync Now",
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.blue,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// NOTIFICATION SETTINGS
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: const [
                        Icon(Icons.notifications_active),
                        SizedBox(width: 10),
                        Text(
                          "Notification Access",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Allow Notification",
                          style: TextStyle(fontSize: 16),
                        ),

                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: notification,
                            onChanged: (value) {
                              setState(() {
                                notification = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// USER ACCOUNT
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text(
                          "User Account",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Current User : ",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () {},

                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// VERSION INFO
            const Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.phone_android_rounded),
                title: Text("Version Info"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(""),
                    Text("A Product of Krish Mark Infotech India Pvt Ltd"),
                    Text(""),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
