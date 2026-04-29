import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/searchedlead.dart';
import 'package:flutter_bottom_nav/common/CommonSnackbar.dart';
import 'package:flutter_bottom_nav/common/common_popup.dart';
import 'package:flutter_bottom_nav/common/common_singltbtn_popup.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/getLastActivityForLead.dart';
import 'package:flutter_bottom_nav/core/repository/activity_offline_repository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';
import 'package:http/http.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class LeadUpdateNew extends StatefulWidget {
  final Map<String, dynamic> lead;

  const LeadUpdateNew({Key? key, required this.lead}) : super(key: key);

  @override
  _LeadUpdateState createState() => _LeadUpdateState();
}

class _LeadUpdateState extends State<LeadUpdateNew> {
  List<String> activityDescList = [];
  List<String> activityCodeList = [];

  // Sub Activity
  List<String> subActivityDescList = [];
  List<String> subActivityCodeList = [];

  // Lookup
  List<String> instrumentTypeList = [];
  List<String> lostReasonList = [];
  List<String> competitorList = [];

  // Selected Values
  String? selectedActivity;
  String? selectedActivityCode;
  String? selectedSubActivity;
  String? selectedSubActivityCode;

  String? selectedInstrumentType;
  String? selectedLostReason;
  String? selectedCompetitor;

  //db
  late Database db, dbi;

  @override
  void initState() {
    super.initState();

    loadInitialData();
    LastActivity();
  }

  //Function for loading offline db data
  Future<void> loadInitialData() async {
    db = await OfflineDBHelper.getDatabase();
    dbi = await DatabaseHelper.instance.database;

    await printAllTables();
    setleadType();
    await checkIfParked();
    await fetchActivityMapping();
    await fetchActivityMaster();

    setState(() {});
  }

  //
  late String leadId;
  late String TempCode;
  late String leadType;
  late String bizType;
  late String reqChannelId;
  late String leadSourceId;
  late String activityCode;
  late String LeadTypeDesc;

  void setleadType() {
    leadId = widget.lead['SrvcReqDtlCode']?.toString() ?? "";
    TempCode = widget.lead['TempSrvcReqDtlCode']?.toString() ?? "";
    leadType = widget.lead['LeadType']?.toString() ?? "";
    bizType = widget.lead['BizType']?.toString() ?? "";
    reqChannelId = widget.lead['ReqChannelId']?.toString() ?? "";
    leadSourceId = widget.lead['LeadSource']?.toString() ?? "";
    activityCode = widget.lead['ActivityCode']?.toString() ?? "";
    LeadTypeDesc = widget.lead['LeadTypeDesc']?.toString() ?? "";

    String mLeadTypeDesc = CommonUtil.decryptIfNotEmpty(LeadTypeDesc);

    print(" lead type description is as this : ,$mLeadTypeDesc");

    if (mLeadTypeDesc.toLowerCase() == "lead") {
      leadType = "L";
    } else {
      leadType = "P";
    }
  }

  String parkedDate = "";

  Future<void> checkIfParked() async {
    final result = await dbi.query(
      "LMSLeadActivityTracker",
      columns: ["ParkedLead", "ParkedLeadDateTime"],
      where: "SrvcReqDtlCode= ?",
      whereArgs: [CommonUtil.encryptIfNotEmpty(leadId)],
    );

    if (result.isNotEmpty) {
      String parked = CommonUtil.decryptIfNotEmpty(
        result.first["ParkedLead"]?.toString() ?? "",
      );

      parkedDate = CommonUtil.decryptIfNotEmpty(
        result.first["ParkedLeadDateTime"]?.toString() ?? "",
      );

      print("Parked Lead ,$parked");
      print("Parked Lead Date,$parkedDate");

      if (parked == "Y" || parked == "1") {
        isParkedLead = true;
      } else {
        isParkedLead = false;
      }
    }
  }

  bool isParkedLead = false;

  Future<void> LastActivity() async {
    try {
      leadId = widget.lead['SrvcReqDtlCode']?.toString() ?? "";
      String srvcReqDtlCode = leadId;

      final Response = await GetLastActivityForLeadApi.getData(
        SAPCode: StaticVariables.mSAPCode,
        SrvcReqDtlCode: srvcReqDtlCode,
      );

      if (Response != null) {
        await saveLastActivity(Response);
      }
    } catch (e) {
      print("Exception for geting the Last activity data : $e");
    }
  }

  Future<void> printAllTables() async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    print("Tables in DB:");
    for (var row in result) {
      print(row['name']);
    }
  }

  Future<List<String>> fetchLookup(String type) async {
    final result = await db.query(
      'Lookupsu',
      where: 'Type = ?',
      whereArgs: [type],
    );

    // Convert DB rows → List<String>
    return result.map((e) => e['Value'].toString()).toList();
  }

  Future<void> fetchActivityMapping() async {
    try {
      // DECRYPT VALUES
      String leadSrcEncrypted = widget.lead['LeadSource']?.toString() ?? "";
      String reqChnlEncrypted = widget.lead['ReqChannelId']?.toString() ?? "";
      String leadType = widget.lead['LeadType']?.toString() ?? "";
      String bizType = widget.lead['BizType']?.toString() ?? "";
      String currentActivityCode =
          widget.lead['ActivityCode']?.toString() ?? "";

      String leadSourceId = CommonUtil.decryptIfNotEmpty(leadSrcEncrypted);
      String reqChannelId = CommonUtil.decryptIfNotEmpty(reqChnlEncrypted);

      // INITIAL CHECK
      var checkResult = await db.query(
        'CBLMSLeadActivityMapping',
        columns: ['Actvitycode'],
        where: 'ReqChannelId = ? AND LeadSourceId = ?',
        whereArgs: [reqChannelId, leadSourceId],
      );

      if (checkResult.isEmpty) {
        CommonSinglePopup(
          title: "Disposition Alert",
          message: "Lead disposition not available.",
          onOk: () {
            Navigator.pop(context);
          },
        );
        return;
      }

      List<Map<String, dynamic>> result = [];

      if (reqChannelId.isNotEmpty && bizType.isNotEmpty) {
        result = await db.query(
          'CBLMSLeadActivityMapping',
          columns: ['Actvitycode'],
          where:
              'ReqChannelId = ? AND LeadType = ? AND LeadSourceId = ? AND Biztype = ? AND IssActivity = ?',
          whereArgs: [reqChannelId, leadType, leadSourceId, bizType, 'Y'],
        );
      } else {
        result = await db.query(
          'CBLMSLeadActivityMapping',
          columns: ['Actvitycode'],
          where: 'ReqChannelId = ? AND LeadSourceId = ? AND IssActivity = ?',
          whereArgs: [reqChannelId, leadSourceId, 'Y'],
        );
      }

      activityCodeList.clear();

      for (var row in result) {
        activityCodeList.add(row['Actvitycode'].toString());
      }

      //Remove Duplicate records from list
      activityCodeList = activityCodeList.toSet().toList();

      // SPECIAL OVERRIDE
      if (currentActivityCode.isNotEmpty &&
          (currentActivityCode.trim() == "35" ||
              currentActivityCode.trim() == "38") &&
          activityCodeList.isNotEmpty) {
        activityCodeList.clear();
        activityCodeList.add(currentActivityCode);
      }

      print("Final activityCodeList: $activityCodeList");
    } catch (e) {
      print("Error in fetchActivityMapping: $e");
    }
  }

  Future<void> fetchActivityMaster() async {
    if (activityCodeList.isEmpty) return;

    final result = await db.query(
      'CBLMSMSTActivity',
      where:
          'ActivityCode IN (${List.filled(activityCodeList.length, '?').join(',')})',
      whereArgs: activityCodeList,
      orderBy: 'ActivityCode ASC',
    );

    activityDescList.clear();

    for (var row in result) {
      activityDescList.add(row['ActivityDesc1'].toString());
    }
  }

  Future<void> fetchSubActivity(String activityCode) async {
    String leadSrcEncrypted = widget.lead['LeadSource']?.toString() ?? "";
    String reqChnlEncrypted = widget.lead['ReqChannelId']?.toString() ?? "";
    String leadType = widget.lead['LeadType']?.toString() ?? "";
    String bizType = widget.lead['BizType']?.toString() ?? "";

    String leadSourceId = CommonUtil.decryptIfNotEmpty(leadSrcEncrypted);
    String reqChannelId = CommonUtil.decryptIfNotEmpty(reqChnlEncrypted);

    List<Map<String, dynamic>> result = [];

    if (reqChannelId.isNotEmpty && bizType.isNotEmpty) {
      result = await db.query(
        'CBLMSLeadActivityMapping',
        columns: ['ActivitySubCode'],
        where:
            'ReqChannelId = ? AND LeadType = ? AND LeadSourceId = ? AND Biztype = ? AND IssActivity = ? AND Actvitycode = ?',
        whereArgs: [
          reqChannelId,
          leadType,
          leadSourceId,
          bizType,
          'Y',
          activityCode,
        ],
      );
    } else {
      result = await db.query(
        'CBLMSLeadActivityMapping',
        columns: ['ActivitySubCode'],
        where:
            'ReqChannelId = ? AND LeadSourceId = ? AND IssActivity = ? AND Actvitycode = ?',
        whereArgs: [reqChannelId, leadSourceId, 'Y', activityCode],
      );
    }

    subActivityCodeList.clear();

    for (var row in result) {
      subActivityCodeList.add(row['ActivitySubCode'].toString());
    }

    await fetchSubActivityMaster();

    setState(() {});
  }

  Future<void> fetchSubActivityMaster() async {
    if (subActivityCodeList.isEmpty) return;

    final result = await db.query(
      'CBLMSMSTSubActivity',
      where:
          'ActivitySubCode IN (${List.filled(subActivityCodeList.length, '?').join(',')})',
      whereArgs: subActivityCodeList,
      orderBy: 'ActivitySubCode ASC',
    );

    subActivityDescList.clear();

    for (var row in result) {
      subActivityDescList.add(row['ActivityCodeDesc1'].toString());
    }
    print(subActivityDescList);
  }

  Future<void> fillDropdowns(String activityCode) async {
    // LEAD LOST (38)
    if (activityCode == "38") {
      // Competitor
      final competitorResult = await db.query(
        'LookUpSU',
        where: 'LookUpCode = ?',
        whereArgs: ['ComptitorID'],
        orderBy: 'CAST(SortOrder as INTEGER)',
      );

      competitorList = competitorResult
          .map((e) => e['ParamDesc1'].toString())
          .toList();

      // Lost Reason
      final lostResult = await db.query(
        'LookUpSU',
        where: 'LookUpCode = ?',
        whereArgs: ['LTCOM'],
        orderBy: 'CAST(SortOrder as INTEGER)',
      );

      lostReasonList = lostResult
          .map((e) => e['ParamDesc1'].toString())
          .toList();
    }

    // SALE CLOSED (36)
    if (activityCode == "36") {
      final instrumentResult = await db.query(
        'LookUpSU',
        where: 'LookUpCode = ?',
        whereArgs: ['INTTYP'],
        orderBy: 'CAST(SortOrder as INTEGER)',
      );

      instrumentTypeList = instrumentResult
          .map((e) => e['ParamDesc1'].toString())
          .toList();
    }

    setState(() {});
  }

  final TextEditingController policyNumberCtrl = TextEditingController();
  final TextEditingController instrumentNumberCtrl = TextEditingController();
  final TextEditingController instrumentAmountCtrl = TextEditingController();
  final TextEditingController competitorPolicyCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController callbackDateCrtl = TextEditingController();
  final TextEditingController appointDateCrtl = TextEditingController();
  final TextEditingController expclosdateCrtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = MediaQuery.of(context).size.height * 0.055;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Update Leads'),
        // backgroundColor: const Color(0xFF090979),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF090979), Color(0xFF00D4FF)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel('Activity *'),
            buildDropdown(
              'Activity *',
              fieldHeight,
              value: selectedActivity,
              items: activityDescList,
              onChanged: (val) async {
                setState(() {
                  selectedActivity = val;
                  int index = activityDescList.indexOf(val!);
                  selectedActivityCode = activityCodeList[index];

                  selectedSubActivity = null;
                  subActivityDescList.clear();
                });
                await fetchSubActivity(selectedActivityCode!);

                await fillDropdowns(selectedActivityCode!);
              },
            ),

            //Sub activity dropdown
            if (selectedActivity != null) ...[
              buildLabel('Sub Activity *'),
              buildDropdown(
                'Sub Activity *',
                fieldHeight,

                value: selectedSubActivity,
                items: subActivityDescList,
                onChanged: (val) {
                  selectedSubActivity = val;

                  int index = subActivityDescList.indexOf(val!);
                  selectedSubActivityCode = subActivityCodeList[index];

                  setState(() {});
                },
              ),
            ],
            const SizedBox(height: 8),
            buildDynamicSection(fieldHeight),
            buildButton('Save'),
          ],
        ),
      ),
    );
  }

  Widget buildDynamicSection(double fieldHeight) {
    switch (selectedActivity) {
      case 'Sale Closed':
        return buildSaleClosedUI(fieldHeight);

      case 'Lead Lost':
        return buildLeadLostUI(fieldHeight);

      case 'Lead Open':
        return buildLeadOpenUI(fieldHeight);

      default:
        return const SizedBox();
    }
  }

  Widget buildSaleClosedUI(double fieldHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel('Policy Number *'),
        buildTextField(fieldHeight, policyNumberCtrl, 'Policy Number *'),
        buildLabel('Instrument Type *'),
        buildDropdown(
          'Instrument Type *',
          fieldHeight,
          value: selectedInstrumentType,
          items: instrumentTypeList,
          onChanged: (val) {
            setState(() {
              selectedInstrumentType = val;
            });
          },
        ),
        buildLabel('Instrument Number *'),
        buildTextField(
          fieldHeight,
          instrumentNumberCtrl,
          'Instrument Number *',
        ),
        buildLabel('Instrument Amount *'),
        buildTextField(
          fieldHeight,
          instrumentAmountCtrl,
          'Instrument Amount *',
        ),
        buildLabel('Remark *'),
        buildTextField(fieldHeight, remarkCtrl, 'Remark *'),
      ],
    );
  }

  Widget buildLeadLostUI(double fieldHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel('Policy Number of Competitor'),
        buildTextField(
          fieldHeight,
          competitorPolicyCtrl,
          'Policy Number of Competitor',
        ),
        buildLabel('Company Name of Competitor'),
        buildDropdown(
          'Company Name of Competitor',
          fieldHeight,
          value: selectedCompetitor,
          items: competitorList,
          onChanged: (val) {
            setState(() {
              selectedCompetitor = val;
            });
          },
        ),
        buildLabel('New Policy Enrd Date'),
        buildDateField('New Policy Enrd Date', fieldHeight, dateCtrl),
        buildLabel('Remark *'),
        buildTextField(fieldHeight, remarkCtrl, 'Remark *'),
      ],
    );
  }

  Widget buildLeadOpenUI(double fieldHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedSubActivity == 'Call Back') ...[
          buildLabel('Call Back *'),
          buildDateField('Call Back *', fieldHeight, callbackDateCrtl),
          buildLabel('Expected Closure Date *'),
          buildDateField(
            'Expected Closure Date ',
            fieldHeight,
            expclosdateCrtl,
          ),
        ],
        if (selectedSubActivity == 'Appointment Fixed') ...[
          buildLabel('Appointment Date *'),
          buildDateField('Appointment Date *', fieldHeight, appointDateCrtl),
          buildLabel('Expected Closure Date *'),
          buildDateField(
            'Expected Closure Date *',
            fieldHeight,
            expclosdateCrtl,
          ),
        ],
        buildLabel('Remark *'),
        buildTextField(fieldHeight, remarkCtrl, 'Remark *'),
      ],
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget buildTextField(
    double height,
    TextEditingController controller,
    String hintText, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: SizedBox(
          height: maxLines == 1 ? height : height * 1.6,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.fromLTRB(12, 14, 12, 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(
    String hintText,
    double height, {
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: SizedBox(
          height: height,
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            items: items
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateField(
    String hintText,
    double height,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_today),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(12, 14, 12, 14),
              hintText: hintText,
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                controller.text = '${date.day}/${date.month}/${date.year}';
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17479E),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: () async {
            if (selectedActivity == null) {
              CommonSnackBar.show(context, "Please select Activity");
              return;
            }

            // Sub Activity
            if (selectedSubActivity == null) {
              CommonSnackBar.show(context, "Please select Sub Activity");
              return;
            }

            // SALE CLOSED
            if (selectedActivity == "Sale Closed") {
              if (policyNumberCtrl.text.trim().isEmpty) {
                CommonSnackBar.show(context, "Enter Policy Number");
                return;
              }
              if (selectedInstrumentType == null) {
                CommonSnackBar.show(context, "Select Instrument Type");
                return;
              }
              if (instrumentNumberCtrl.text.trim().isEmpty) {
                CommonSnackBar.show(context, "Enter Instrument Number");
                return;
              }
              if (instrumentAmountCtrl.text.trim().isEmpty) {
                CommonSnackBar.show(context, "Enter Instrument Amount");
                return;
              }
            }

            // LEAD LOST
            if (selectedActivity == "Lead Lost") {
              if (selectedCompetitor == null) {
                CommonSnackBar.show(context, "Select Competitor");
                return;
              }
              if (dateCtrl.text.trim().isEmpty) {
                CommonSnackBar.show(context, "Select Policy End Date");
                showError("");
                return;
              }
            }

            // LEAD OPEN
            if (selectedActivity == "Lead Open") {
              if (selectedSubActivity == "Call Back") {
                if (callbackDateCrtl.text.trim().isEmpty) {
                  CommonSnackBar.show(context, "Select Call Back Date");
                  return;
                }
                if (expclosdateCrtl.text.trim().isEmpty) {
                  CommonSnackBar.show(context, "Select Expected Closure Date");
                  return;
                }
              }

              if (selectedSubActivity == "Appointment Fixed") {
                if (appointDateCrtl.text.trim().isEmpty) {
                  CommonSnackBar.show(context, "Select Appointment Date");
                  return;
                }
                if (expclosdateCrtl.text.trim().isEmpty) {
                  CommonSnackBar.show(context, "Select Expected Closure Date");
                  return;
                }
              }
            }

            if (remarkCtrl.text.trim().isEmpty) {
              CommonSnackBar.show(context, "Enter Remark");
              return;
            }

            print("Validation Passed");

            await onSubmitPressed();
          },
          child: Text(text),
        ),
      ),
    );
  }

  //send data to repo
  Future<void> onSubmitPressed() async {
    String leadId = widget.lead['SrvcReqDtlCode']?.toString() ?? "";
    String cltCode = CommonUtil.decryptIfNotEmpty(
      widget.lead['CltCode']?.toString() ?? "",
    );
    String appointmentdate = appointDateCrtl.text;
    String policynumber = policyNumberCtrl.text;
    String InstrumentNumber = instrumentNumberCtrl.text;
    String InstrumentAmount = instrumentAmountCtrl.text;

    String competitorpolicy = competitorPolicyCtrl.text;
    String remark = remarkCtrl.text;
    String callbackDate = callbackDateCrtl.text;
    String followupdate = dateCtrl.text;
    String expclosdate = expclosdateCrtl.text;
    print(appointmentdate);

    await SaveActivityOfflineRepository.insertUpdateActivity({
      "SrvcReqDtlCode": leadId,
      "TempSrvcReqDtlCode": TempCode,
      "ActivityCode": selectedActivityCode!,
      "SubActivityCode": selectedSubActivityCode!,
      "CreateBy": StaticVariables.mSAPCode,
      "CltCode": cltCode,
      "Remark": remark,
      "BizType": bizType,
      "ExistingActivityCode": selectedActivityCode, // if available else ""
      "isParkedLead": isParkedLead,
      "ExpectedClosureDate": expclosdate,

      // Optional fields (send empty if not used)
      "InstType": "",
      "IssuedPolicyNo": "",
      "ChequeNo": "",
      "PremiumCollected": "",
      "PolicyAlreadyRenewedReason": "",
      "AppointmentDate": appointmentdate,
      "CallBackDate": callbackDate,
      "ParkedLeadDateTime": parkedDate,
      "FollowupDt": followupdate,
      "LstComDueTo": "",
      "ComptitorID": "",
      "NewPolEndDate": "",
    });

    Map<String, dynamic> activityData = {
      "CltCode": cltCode,
      "SrvcReqDtlCode": leadId,
      "CreateBy": StaticVariables.mSAPCode,
      "ActivityCode": selectedActivityCode,
      "SubActivityCode": selectedSubActivityCode,
      "AppReason": "",
      "SubReason": "",

      "IssuedPolicyNo": policynumber,
      "ChequeNo": InstrumentNumber,
      "PremiumCollected": InstrumentAmount,
      "PolicyAlreadyRenewedReason": competitorpolicy,
      "Remark": remark,
      "AppointmentDate": appointmentdate,
      "CallBackDate": callbackDate,
      "FollowupDt": followupdate,
      "ExpiryDate": expclosdate,
    };

    // await SaveActivityOfflineRepository.saveLeadActivityOffline(
    //   leadId: leadId,
    //   tempLeadId: TempCode,
    //   activityCode: selectedActivityCode!,
    //   subActivityCode: selectedSubActivityCode!,
    //   loginSAPCode: StaticVariables.mSAPCode,
    //   cltCode: cltCode,
    //   remark: remarkCtrl.text,
    //   bizType: bizType,
    //   isParkedLead: isParkedLead,
    //   expectedClosureDate: expclosdateCrtl.text,
    //   // ... other params
    // );
    // //await SaveActivityOfflineRepository.saveActivityOffline(activityData);

    //new changes
    try {
      //String acode = widget.lead['ActivityDesc']?.toString() ?? "";
      // String acodedes=widget.lead['ActivityDesc']?.toString() ?? "";

      //  var acdes = SaveActivityOfflineRepository.getActivityDesc(selectedActivityCode!);
      // print(acdes);

      var acdes = await SaveActivityOfflineRepository.getActivityDesc(
        selectedActivityCode!,
      );

      print(acdes);

      await showDialog(
        context: context,
        builder: (context) => CommonSinglePopup(
          title: "Activity Disposition",
          message:
              "Activity Disposition of lead number $leadId for lead open is updated for $acdes successfully",
          onOk: () {
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      print("Exception $e");
    }

    // try{
    //     CommonSinglePopup(
    //       title: "Activity Disposition",
    //       message:
    //           "Activity Disposition of lead number ,$leadId for lead open is updated successfully",
    //       onOk: () {
    //         Navigator.pop(context);
    //       },
    //     );
    // }catch(e){
    //   print("Exception $e");
    // }
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text("Activity saved offline")));
  }

  //end
  Future<void> saveLastActivity(Map<String, dynamic> response) async {
    try {
      List<dynamic> dataList = response['Table'] ?? [];

      if (dataList.isEmpty) return;

      for (var item in dataList) {
        await dbi.update(
          "Tbl_LeadDetails",
          {
            "ReqChannel": CommonUtil.encryptIfNotEmpty(
              item['ReqChannel']?.toString() ?? "",
            ),
            "LOBCode": CommonUtil.encryptIfNotEmpty(
              item['LOBCode']?.toString() ?? "",
            ),
            "CRMStatus": CommonUtil.encryptIfNotEmpty(
              item['CRMStatus']?.toString() ?? "",
            ),
            "ActivityStatus": CommonUtil.encryptIfNotEmpty(
              item['ActivityStatus']?.toString() ?? "",
            ),
            "OwnerName": CommonUtil.encryptIfNotEmpty(
              item['OwnerName']?.toString() ?? "",
            ),
            "SyncStatus": CommonUtil.encryptIfNotEmpty("Complete"),
          },
          where: "SrvcReqDtlCode = ?",
          whereArgs: [
            CommonUtil.encryptIfNotEmpty(
              item['SrvcReqDtlCode']?.toString() ?? "",
            ),
          ],
        );

        await dbi.delete(
          "LMSLeadActivityTracker",
          where: "SrvcReqDtlCode = ?",
          whereArgs: [
            CommonUtil.encryptIfNotEmpty(
              item['SrvcReqDtlCode']?.toString() ?? "",
            ),
          ],
        );

        await dbi.insert("LMSLeadActivityTracker", {
          "SrvcReqDtlCode": CommonUtil.encryptIfNotEmpty(
            item['SrvcReqDtlCode']?.toString() ?? "",
          ),
          "ActivityCode": CommonUtil.encryptIfNotEmpty(
            item['ActivityCode']?.toString() ?? "",
          ),
          "SubActivityCode": CommonUtil.encryptIfNotEmpty(
            item['SubActivityCode']?.toString() ?? "",
          ),
          "Remark": CommonUtil.encryptIfNotEmpty(
            item['TrackerRemark']?.toString() ?? "",
          ),
          "CreateDTim": CommonUtil.encryptIfNotEmpty(
            item['CreateDTim']?.toString() ?? "",
          ),
        });
      }
    } catch (e) {
      print("Error in saveLastActivity: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
