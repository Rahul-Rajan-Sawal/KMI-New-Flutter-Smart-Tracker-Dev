import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/login_activity.dart';
import 'package:flutter_bottom_nav/core/apicall/async_get_api_values.dart';
import 'package:flutter_bottom_nav/core/services/offlineDB_download.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashscreenActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashscreenActivity> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AsyncGetApiValues(
      callback: (result) async {
        if (result == "Success") {
          await readPrefAndContinue();

         await DBDownloadService.downloadDBsIfNeeded();

          // ✅ ADDED: SAME AS ANDROID → initialize/open DB
          await OfflineDBHelper.getDatabase();


          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginActivity()),
          );
        } else {
          _showError();
        }
      },
    ).execute();
  }

  Future<void> readPrefAndContinue() async {
    final prefs = await SharedPreferences.getInstance();

    StaticVariables.cipherServer = prefs.getString("server");
    StaticVariables.pkcs5Padding = prefs.getString("pad");
    StaticVariables.apiKey = prefs.getString("api_key");
    StaticVariables.cipher = prefs.getString("shared_key");
    StaticVariables.dbKey = prefs.getString("dbKey");
    StaticVariables.authorization = prefs.getString("Authorization");
    StaticVariables.callerPass = prefs.getString("shared_key");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double scaleFont(double size) {
      return size * screenWidth / 400;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.03),
              Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: scaleFont(22),
                  fontWeight: FontWeight.w400,
                ),
              ),

              Text(
                "Sign in to your account",
                style: TextStyle(fontSize: scaleFont(12)),
              ),

              SizedBox(height: screenHeight * 0.02),

              Image.asset(
                "assets/indusind_logo.png",
                height: screenHeight * 0.08,
                fit: BoxFit.contain,
              ),

              SizedBox(height: screenHeight * 0.04),

              Text(
                "Smart Tracker",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: .bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: screenHeight * 0.06),

              Image.asset(
                "assets/loader_01.gif",
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),

              SizedBox(height: screenHeight * 0.06),

              Image.asset(
                "assets/login_bg.png",
                height: screenHeight * 0.30,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Initialization failed")));
  }
}
