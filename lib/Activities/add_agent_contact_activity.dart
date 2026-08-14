// add_contact_screen.dart
// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/activity_add_contact.dart';
import 'package:flutter_bottom_nav/core/apicall/async_search_agent_contact.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';
// import 'package:sqflite_sqlcipher/sqflite.dart';

// ✅ Simple table name constant - no import headaches
const String TBL_AGENT_CNT_DTLS = 'TBL_AGENT_CNT_DTLS';

class AddAgentContactScreen extends StatefulWidget {
  @override
  _AddAgentContactScreenState createState() => _AddAgentContactScreenState();
}

class _AddAgentContactScreenState extends State<AddAgentContactScreen> {
  List<String> arrIMDTypeID = [];
  List<String> arrIMDTypeDesc = [];
  List<Map<String, dynamic>> ContactList = [];

  String? selectedType;
  TextEditingController valueController = TextEditingController();

  bool isLoading = false;
  bool hasSearched = false;

  String iAgentName = "";
  String iIntermediaryCode = "";
  String iMobileNo = "";
  bool showCard = false;

  @override
  void initState() {
    super.initState();
    getIntermediaryType();
  }

  Future<void> getIntermediaryType() async {
    final db = await OfflineDBHelper.getDatabase();
    final result = await db.query(
      "Lookupsu",
      columns: ["ParamValue", "ParamDesc1"],
      where: "LookupCode = ?",
      whereArgs: ["IMDType"],
      orderBy: "SortOrder ASC",
    );

    arrIMDTypeID.clear();
    arrIMDTypeDesc.clear();

    for (var row in result) {
      arrIMDTypeID.add(row["ParamValue"].toString());
      arrIMDTypeDesc.add(row["ParamDesc1"].toString());
    }
    setState(() {});
  }

  Future<void> _cleanupDuplicateContacts() async {
    final db = await DatabaseHelper.instance.database;
    await db.rawDelete('''
        DELETE FROM TBL_AGENT_CNT_DTLS 
        WHERE REC_ID NOT IN (
          SELECT MAX(REC_ID) 
          FROM TBL_AGENT_CNT_DTLS 
          GROUP BY IMD_CODE, MOBILE_NO, EMAIL_ID
        )
      ''');
    print("🧹 Cleaned up duplicate contacts");
  }

  Future<void> _handleSearch() async {
    if (selectedType == null || valueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select intermediary type and enter value"),
        ),
      );
      return;
    }

    await _cleanupDuplicateContacts(); // ✅ Run once, then remove

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      hasSearched = true;
      showCard = false;
      iAgentName = "";
      iIntermediaryCode = "";
      iMobileNo = "";
      ContactList = [];
    });

    try {
      final index = arrIMDTypeDesc.indexOf(selectedType!);
      final imdTypeToSend = arrIMDTypeID[index];

      // ✅ 1. CALL API
      final response = await searchAgentContact(
        sapCode: StaticVariables.mSAPCode,
        imdType: imdTypeToSend,
        imdValue: valueController.text.trim(),
      );

      final List table = response["Table"] ?? [];
      if (table.isEmpty) {
        setState(() => showCard = false);
        return;
      }

      final firstRecord = Map<String, dynamic>.from(table[0]);
      if (firstRecord.containsKey("ResponseCode")) {
        final code = firstRecord["ResponseCode"]?.toString();
        if (code == "1" || code == "2") {
          setState(() => showCard = false);
          return;
        }
      }

      String tempName = "";
      String tempCode = "";
      String tempMobile = "";
      //final db = await OfflineDBHelper.getDatabase();
      final db = await DatabaseHelper.instance.database;

      await db.transaction((txn) async {
        for (var item in table) {
          final record = Map<String, dynamic>.from(item);

          final imdCode = _safeString(record["IMDCode"]);
          final imdName = _safeString(record["IMDName"]);
          final mobileNo = _safeString(record["MobileNo"]);
          final emailId = _safeString(record["EmailID"]);
          //final isPrimary = _safeString(record["IsPrimary"]);
          final isPrimaryMobile = _safeString(record["IsPrimary"]);
          final isPrimaryEmail = _safeString(record["IsEmailPrimary"]);
          final src = _safeString(record["SRC"]);
          final createDTim = _safeString(record["CreateDTim"]);

          final dateInLong = createDTim.isEmpty
              ? 0
              : _convertDateToLong(createDTim);

          final dbData = {
            "IMD_CODE": imdCode,
            "IMD_NAME": imdName,
            "MOBILE_NO": mobileNo,
            "EMAIL_ID": emailId,
            //"IS_PRIMARY": isPrimary,
            "IS_PRIMARY_MOBILE": isPrimaryMobile,
            "IS_PRIMARY_EMAIL": isPrimaryEmail,
            "SRC": src,
            "CREATEDDTIME": createDTim,
            "DateInLong": dateInLong,
            "SyncStatus": "FromServer",
            "UserId": StaticVariables.mSAPCode ?? "",
            "CREATEDBY": StaticVariables.mSAPCode ?? "",
            "UPDATEDBY": StaticVariables.mSAPCode ?? "",
            "UPDATEDDTIME": createDTim,
          };

          // ✅ UPSERT (NO QUERY NEEDED)
          final existing = await txn.query(
            TBL_AGENT_CNT_DTLS,
            where: "IMD_CODE = ? AND MOBILE_NO = ? AND EMAIL_ID = ?",
            whereArgs: [imdCode, mobileNo, emailId],
          );

          if (existing.isNotEmpty) {
            await txn.update(
              TBL_AGENT_CNT_DTLS,
              dbData,
              where: "IMD_CODE = ? AND MOBILE_NO = ? AND EMAIL_ID = ?",
              whereArgs: [imdCode, mobileNo, emailId],
            );
          } else {
            await txn.insert(TBL_AGENT_CNT_DTLS, dbData);
          }

          // ✅ UI logic (unchanged)
          if (tempName.isEmpty) {
            tempName = imdName;
            tempCode = imdCode;
          }

          if ((src.toUpperCase() == "MAIN" ||
                  isPrimaryMobile.toUpperCase() == "Y") &&
              mobileNo.isNotEmpty) {
            tempMobile = mobileNo;
          }
        }
      });

      // ✅ 3. FETCH FROM LOCAL DB (Plain Text)
      final dbContacts = await _fetchContactsFromDB(tempCode);

      setState(() {
        iAgentName = tempName;
        iIntermediaryCode = tempCode;
        iMobileNo = tempMobile;
        ContactList = dbContacts;
        showCard = tempName.isNotEmpty || tempCode.isNotEmpty;
      });
    } catch (e) {
      print("❌ Search Error: $e");
      setState(() => showCard = false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ Fetch from DB (Plain Text)
  Future<List<Map<String, dynamic>>> _fetchContactsFromDB(
    String intermediaryCode,
  ) async {
    if (intermediaryCode.isEmpty) return [];

    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      TBL_AGENT_CNT_DTLS, // ✅ Simple constant
      where: "IMD_CODE = ?",
      whereArgs: [intermediaryCode],
      orderBy: "IS_PRIMARY_MOBILE DESC, MOBILE_NO ASC",
    );

    return result.map((row) {
      final isPrimaryRaw = row["IS_PRIMARY_MOBILE"]?.toString() ?? "";
      final contactType =
          (isPrimaryRaw.toUpperCase() == "Y" ||
              isPrimaryRaw.toUpperCase() == "MAIN" ||
              isPrimaryRaw.toUpperCase() == "DEFAULT")
          ? "Default"
          : "Alternate";
      return {
        "IMDCode": row["IMD_CODE"],
        "IMDName": row["IMD_NAME"],
        //added by rahul
        "isPrimaryMobile": (row["IS_PRIMARY_MOBILE"]?.toString() ?? "")
            .toUpperCase(),
        "isPrimaryEmail": (row["IS_PRIMARY_EMAIL"]?.toString() ?? "")
            .toUpperCase(),
        "SRC": row["SRC"],
        "mobile": row["MOBILE_NO"]?.toString() ?? "",
        "email": row["EMAIL_ID"]?.toString() ?? "",
        "isPrimary": isPrimaryRaw,
        "contactType": contactType,
      };
    }).toList();
  }

  int _convertDateToLong(String dateString) {
    try {
      return DateTime.parse(dateString).millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }

  String _safeString(dynamic value) {
    if (value == null) return "";
    final str = value.toString().trim();
    if (str.isEmpty ||
        str.toLowerCase() == "null" ||
        str.toLowerCase() == "not available" ||
        str.toLowerCase() == "n/a")
      return "";
    return str;
  }

  void _clear() {
    FocusScope.of(context).unfocus();
    setState(() {
      selectedType = null;
      valueController.clear();
      showCard = false;
      hasSearched = false;
      iAgentName = "";
      iIntermediaryCode = "";
      iMobileNo = "";
      ContactList = [];
    });
  }

  String maskMobile(String number) {
    if (number.isEmpty) return "N/A";
    if (number.length < 4) return "XXXXXX";
    return "XXXXXX${number.substring(number.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Add New Agent Contact",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF090979), Color(0xFF00D4FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: DropdownButtonFormField<String>(
                value: arrIMDTypeDesc.contains(selectedType)
                    ? selectedType
                    : null,
                hint: const Text("Intermediary Type"),
                isExpanded: true,
                decoration: const InputDecoration(border: InputBorder.none),
                items: arrIMDTypeDesc
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedType = value),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: TextField(
                controller: valueController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "Intermediary Value",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clear,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child:
                        // isLoading
                        //     ? const SizedBox(
                        //         height: 18,
                        //         width: 18,
                        //         child: CircularProgressIndicator(
                        //           color: Colors.white,
                        //           strokeWidth: 2,
                        //         ),
                        //       )
                        const Text(
                          "Search",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (showCard)
              buildCard()
            else if (hasSearched)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No Data Available",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "INTERMEDIARY NAME",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            iAgentName.isEmpty ? "N/A" : iAgentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "INTERMEDIARY CODE",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          iIntermediaryCode.isEmpty ? "N/A" : iIntermediaryCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "MOBILE NUMBER",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  maskMobile(iMobileNo),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (iAgentName.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddCustomerContactScreen(contactList: ContactList),
                ),
              );
            },
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "ADD CONTACT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
