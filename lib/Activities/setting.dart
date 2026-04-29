import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool wifiSync = true;
  bool mobileSync = true;
  bool notification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Searched Leads"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF090979), // same dark blue
                Color(0xFF00D4FF), // same cyan
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            /// NETWORK SETTINGS
            Card(
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

                    InkWell(
                      onTap: () {},

                      child: const Padding(
                        padding: EdgeInsets.all(8),

                        child: Text(
                          "Sync Now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// NOTIFICATION SETTINGS
            Card(
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
