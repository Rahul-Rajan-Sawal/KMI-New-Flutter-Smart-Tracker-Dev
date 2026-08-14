import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/lead_update_activity.dart';
import 'package:flutter_bottom_nav/Activities/lead_update_newactivity.dart';
import 'package:flutter_bottom_nav/Activities/login_activity.dart';
import 'package:flutter_bottom_nav/Activities/upcoming_activity_row.dart';
import 'package:flutter_bottom_nav/Activities/view_details.dart';
import 'package:flutter_bottom_nav/common/common_popup.dart';
import 'package:flutter_bottom_nav/common/common_singltbtn_popup.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/async_get_single_lead_details.dart';
import 'package:flutter_bottom_nav/core/apicall/async_search_customer_contact.dart';
import 'package:flutter_bottom_nav/core/repository/schedules/schedule_repository.dart';
import 'package:flutter_bottom_nav/core/repository/view_details_repository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/database/offline_DB_helper.dart';
import 'package:intl/intl.dart';
// import 'package:path/path.dart';  commented for the context error

class UpcomingEventActivity extends StatefulWidget {
  const UpcomingEventActivity({super.key});

  @override
  State<StatefulWidget> createState() => _UpcomingEventActivity();
}

class _UpcomingEventActivity extends State<UpcomingEventActivity> {
  String getFirstDayOfMonth() {
    final now = DateTime.now();

    return "01/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  final String lsd = "";
  List<Map<String, dynamic>> leadList = [];
  List<Map<String, dynamic>> scheduleList = [];
  List<Map<String, dynamic>> filteredList = [];
  List<String> productList = [];
  List<String> productCodeList = [];
  String selectedProductCode = "";
  final ScheduleRepository repository = ScheduleRepository();
  final ViewDetailsRepository callRepository = ViewDetailsRepository();

  String bridgeCallToTime = "";
  String bridgeCallFromTime = "";
  String bridgeCallDownTime = "";

  bool _isCallInProgress = false;

  Future<void> loadBridgeCallTime() async {
    final data = await callRepository.getBridgeCallTimes(
      StaticVariables.mSAPCode,
    );

    if (!mounted) return;

    if (data != null) {
      setState(() {
        bridgeCallToTime = data["BridgeCallToTime"] ?? "";
        bridgeCallFromTime = data["BridgeCallFromTime"] ?? "";
        bridgeCallDownTime = data["BridgeCallDownTime"] ?? "";
      });

      debugPrint(
        "Bridge Call Time: "
        "$bridgeCallFromTime to $bridgeCallToTime, "
        "downtime: $bridgeCallDownTime",
      );
    }
  }

  bool isWithinWorkingHours(int fromHour, int toHour) {
    final now = DateTime.now();

    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = fromHour * 60;
    final endMinutes = toHour * 60;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }

    // Supports a time range that crosses midnight.
    return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
  }

  Future<void> handleLeadCall(Map<String, dynamic> item) async {
    if (_isCallInProgress) return;

    final String leadId = item["SrvcReqDtlCode"]?.toString().trim() ?? "";

    final String policyNumber = item["PolicyNo"]?.toString().trim() ?? "";

    final String customerName = item["Name"]?.toString().trim() ?? "";

    if (leadId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lead ID not available")));
      return;
    }

    _isCallInProgress = true;
    bool loaderVisible = false;

    try {
      // Working-hours validation.
      final int? fromHour = int.tryParse(bridgeCallFromTime);
      final int? toHour = int.tryParse(bridgeCallToTime);

      if (fromHour != null && toHour != null) {
        final bool isWithinTime = isWithinWorkingHours(fromHour, toHour);

        if (!isWithinTime) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Calling is allowed only between "
                "$fromHour:00 and $toHour:00",
              ),
            ),
          );

          return;
        }
      }

      // Check whether another call can currently be initiated.
      final bool canInitiateCall = await callRepository.isDownTime(
        sapCode: StaticVariables.mSAPCode,
        srvcReqDtlCode: leadId,
      );

      if (!mounted) return;

      if (!canInitiateCall) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return CommonSinglePopup(
              title: "Unable to make call",
              message:
                  "You cannot initiate a call within "
                  "$bridgeCallDownTime minutes",
              onOk: () {
                Navigator.pop(dialogContext);
              },
            );
          },
        );

        // Important: stop the call process.
        return;
      }

      CommonUtil.show(
        context,
        message: "Searching For Customer Contact Please wait..",
      );
      loaderVisible = true;

      // Fetch contacts and store them in the local database.
      final result = await searchCustomerContact(
        sapCode: StaticVariables.mSAPCode,
        leadNo: leadId,
        policyNo: policyNumber,
      );

      if (!mounted) return;

      if (result["errorFlag"] != "success") {
        if (loaderVisible) {
          CommonUtil.hide(context);
          loaderVisible = false;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to fetch customer contact details"),
          ),
        );

        return;
      }

      // Read real mobile numbers saved by searchCustomerContact().
      final List<String> numbers = await callRepository
          .getCustomerMobileNumbers(leadId);

      if (!mounted) return;

      if (loaderVisible) {
        CommonUtil.hide(context);
        loaderVisible = false;
      }

      if (numbers.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Number Not Available")));

        return;
      }

      if (numbers.length == 1) {
        await CommonUtil.makeCall(
          numbers.first,
          leadId,
          policyNumber,
          customerName,
        );

        return;
      }

      await showCallNumberSelection(
        numbers: numbers,
        leadId: leadId,
        uniqueNo: policyNumber,
        customerName: customerName,
      );
    } catch (e, stackTrace) {
      debugPrint("Lead call error: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (mounted && loaderVisible) {
        CommonUtil.hide(context);
        loaderVisible = false;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong while making the call"),
          ),
        );
      }
    } finally {
      _isCallInProgress = false;
    }
  }

  Future<void> showCallNumberSelection({
    required List<String> numbers,
    required String leadId,
    required String uniqueNo,
    required String customerName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),

                const Text(
                  "Select Number",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const Divider(),

                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: numbers.length,
                    itemBuilder: (context, index) {
                      final number = numbers[index];

                      return ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(number),
                        onTap: () async {
                          Navigator.pop(bottomSheetContext);

                          await CommonUtil.makeCall(
                            number,
                            leadId,
                            uniqueNo,
                            customerName,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final Map<String, String> _activityDescriptionCache = {};
  @override
  void initState() {
    super.initState();

    loadBridgeCallTime();

    setScheduleDates();
    getLeadDetails().then((_) async {
      await leadUpcomingSchedules();
      applyFilter();
    });
    // getProductList();
  }

  //getting activity desc from activity status code
  Future<String> getActivityDescription(String activityCode) async {
    final code = activityCode.trim();

    if (code.isEmpty || code == "Not Available") {
      return "Not Available";
    }

    // Return already-loaded description.
    if (_activityDescriptionCache.containsKey(code)) {
      return _activityDescriptionCache[code]!;
    }

    try {
      final db = await OfflineDBHelper.getDatabase();

      final result = await db.query(
        "CBLMSMSTActivity",
        columns: ["ActivityDesc1"],
        where: "ActivityCode = ?",
        whereArgs: [code],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final description =
            result.first["ActivityDesc1"]?.toString().trim() ?? "";

        if (description.isNotEmpty) {
          _activityDescriptionCache[code] = description;
          return description;
        }
      }
    } catch (e) {
      debugPrint("Error getting activity description for $code: $e");
    }

    _activityDescriptionCache[code] = "Not Available";
    return "Not Available";
  }

  String getActivityTrackerDate(
    Map<String, dynamic> row,
    String activityCode,
    String subActivityCode,
  ) {
    String activityDate = "";

    if (activityCode == "1") {
      activityDate = row["AppointmentDate"]?.toString() ?? "";
    } else if (activityCode == "2") {
      activityDate = row["RescheduleDate"]?.toString() ?? "";
    } else if (activityCode == "19") {
      activityDate = row["CallBackDate"]?.toString() ?? "";
    } else if (activityCode == "20") {
      activityDate = row["AppointmentDate"]?.toString() ?? "";
    } else if (activityCode == "21") {
      activityDate = row["CallBackDate"]?.toString() ?? "";
    } else if (activityCode == "27") {
      activityDate = row["AppointmentDate"]?.toString() ?? "";
    } else if (activityCode == "28") {
      activityDate = row["RescheduleDate"]?.toString() ?? "";
    } else if (activityCode == "32") {
      activityDate = row["FollowupDt"]?.toString() ?? "";
    } else if (activityCode == "37" && subActivityCode == "4") {
      activityDate = row["CallBackDate"]?.toString() ?? "";
    } else if (activityCode == "37" && subActivityCode == "5") {
      activityDate = row["AppointmentDate"]?.toString() ?? "";
    } else if (activityCode == "37" && subActivityCode == "6") {
      activityDate = row["ParkedLeadDateTime"]?.toString() ?? "";
    } else {
      activityDate = row["CreateDTim"]?.toString() ?? "";
    }
    return activityDate;
  }

  Future<List<String>> getUpcomingScheduleCodes() async {
    final db = await DatabaseHelper.instance.database;

    final trackerData = await db.query("LMSLeadActivityTracker");

    List<String> validCodes = [
      "1",
      "2",
      "19",
      "20",
      "21",
      "27",
      "28",
      "32",
      "37",
    ];

    List<String> matchedCodes = [];

    DateTime startDate = convertDate(fromDate);

    DateTime endDate = convertDate(toDate);

    for (var row in trackerData) {
      String activityCode = row["ActivityCode"]?.toString() ?? "";

      String subActivityCode = row["SubActivityCode"]?.toString() ?? "";

      if (!validCodes.contains(activityCode)) {
        continue;
      }

      String activityDate = getActivityTrackerDate(
        row,
        activityCode,
        subActivityCode,
      );

      if (activityDate.isEmpty) continue;

      try {
        DateTime compareDate = DateTime.parse(activityDate);

        bool isBetween =
            compareDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            compareDate.isBefore(endDate.add(const Duration(days: 1)));

        if (isBetween) {
          matchedCodes.add(row["SrvcReqDtlCode"].toString());
        }
      } catch (e) {
        print("Error $e");
      }
    }
    return matchedCodes.toSet().toList();
  }

  Future<void> leadUpcomingSchedules() async {
    final db = await DatabaseHelper.instance.database;

    List<String> scheduleCodes = await getUpcomingScheduleCodes();
    final trackerData = await db.query("LMSLeadActivityTracker");

    List<String> validCodes = [
      "1",
      "2",
      "19",
      "20",
      "21",
      "27",
      "28",
      "32",
      "37",
    ];

    DateTime startDate = convertDate(fromDate);

    DateTime endDate = convertDate(toDate);

    List<Map<String, dynamic>> finalList = [];

    for (var row in trackerData) {
      String activityCode = row["ActivityCode"]?.toString() ?? "";

      String subActivityCode = row["SubActivityCode"]?.toString() ?? "";

      if (!validCodes.contains(activityCode)) {
        continue;
      }

      String activityDate = getActivityTrackerDate(
        row,
        activityCode,
        subActivityCode,
      );

      if (activityDate.isEmpty) {
        continue;
      }

      try {
        DateTime compareDate = DateTime.parse(activityDate);

        bool isBetween =
            compareDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            compareDate.isBefore(endDate.add(const Duration(days: 1)));

        if (!isBetween) {
          continue;
        }

        String srvcReqDtlCode = row["SrvcReqDtlCode"]?.toString() ?? "";

        final leadResult = await db.query(
          "LeadDetails",
          where: "SrvcReqDtlCode = ?",
          whereArgs: [srvcReqDtlCode],
        );

        if (leadResult.isEmpty) {
          continue;
        }

        Map<String, dynamic> leadData = Map<String, dynamic>.from(
          leadResult.first,
        );

        final activityDescription = await getActivityDescription(activityCode);

        leadData["ScheduleDate"] = activityDate;

        leadData["ActivityCode"] = activityCode;

        leadData["ActivityDescription"] = activityDescription;

        finalList.add(leadData);
      } catch (e) {
        print("Schedule Error: $e");
      }
    }

    setState(() {
      scheduleList = finalList;
      print(filteredList);
    });
  }

  Future<void> getLeadDetails() async {
    try {
      final result = await repository.getUpcomingLeads();
      setState(() {
        leadList = result;
        // filteredList = List.from(result);
      });

      // await loadUpcomingSchedules();

      await getProductList();
      applyFilter();
    } catch (e) {
      print("Error loading leads: $e");
    }
  }

  Future<void> getProductList() async {
    try {
      final db = await DatabaseHelper.instance.database;

      //Step 1 : Get Product Code from the leaddetails
      final leadResult = await db.query(
        "LeadDetails",
        columns: ["ProdCode"],
        where: "UserId = ?",
        whereArgs: [StaticVariables.mSAPCode],
      );
      print(leadResult);

      List<String> prodCodes = [];

      for (var row in leadResult) {
        if (row["ProdCode"] != null) {
          prodCodes.add(row["ProdCode"].toString());
        }
      }

      //Step2 : Remove Duplicates
      prodCodes = prodCodes.toSet().toList();
      print(prodCodes);

      List<Map<String, dynamic>> productResult = [];

      //Step3 : Fetch Products
      if (prodCodes.isNotEmpty) {
        String placeholders = List.filled(prodCodes.length, '?').join(',');

        productResult = await db.query(
          "CBFrmMSTProduct",
          columns: ["ProdCode", "ProdDesc1"],
          where: "ProdCode IN ($placeholders)",
          whereArgs: prodCodes,
        );
      } else {
        productResult = await db.query(
          "CBFrmMSTProduct",
          columns: ["ProdCode", "ProdDesc1"],
          where: "isActive = ?",
          whereArgs: ["Y"],
        );
      }
      print(productResult);

      productList.clear();
      productCodeList.clear();

      productList.add("All Product");
      productCodeList.add("");

      for (var row in productResult) {
        String prodDesc = row["ProdDesc1"]?.toString() ?? "";
        String prodCode = row["ProdCode"]?.toString() ?? "";
        if (prodDesc.isNotEmpty) {
          productList.add(prodDesc);
          productCodeList.add(prodCode);
        }
      }
      // selectedProduct ??= "All Product";
      if (selectedProduct == null || !productList.contains(selectedProduct)) {
        selectedProduct = "All Product";
        selectedProductCode = "";
      }
      print(productResult);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error $e");
    }
  }

  String selectedTab = "schedule";
  String filterMessage = "Showing acitivies for next 5days";
  String showingDate = "30-04-2026";
  String showingTime = "11:08AM";
  String fromDate = "";
  String toDate = "";
  String scheduleDays = "5";
  String renewalDays = "10";
  // String selectedProduct = "All Product";
  String? selectedProduct;

  bool isFilterVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        // foregroundColor: Colors.,
        title: const Text("Upcoming Schedules"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        //leading: const Icon(Icons.arrow_back_ios),

        //bug for logout functionality
        actions: [
          GestureDetector(
            onTap: popUp,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.power_settings_new),
                Text("Logout", style: TextStyle(fontSize: 10)),
              ],
            ),
          ),

          const SizedBox(width: 10),
        ], //bug resolve end
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _buildTabs(),

              const SizedBox(height: 20),

              _buildDateTimeCard(),
              const SizedBox(height: 15),

              _buildRefreshCard(),
              const SizedBox(height: 20),

              _buildFilterHeader(),
              const SizedBox(height: 15),

              _buildFilterSection(),
              const SizedBox(height: 15),

              _buildLegend(),
              const SizedBox(height: 40),

              //Empty State
              // const Center(
              //   child: Text(
              //     "No Upcoming Schedule Available",
              //     style: TextStyle(color: Colors.grey, fontSize: 16),
              //   ),
              // ),
              selectedTab == "renewal"
                  ? _buildRenewalList()
                  // : const Center(
                  //     child: Text(
                  //       "No Upcoming Renewal Available",
                  //       style: TextStyle(color: Colors.grey, fontSize: 16),
                  //     ),
                  //   ),
                  : _buildScheduleList(),

              // : const Center(

              //   child:Text(
              //     "No Upcoming Schedule Available",
              //     style:TextStyle(color: Colors.grey, fontSize: 16),
              //   ),

              // );
            ],
          ),
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.format_list_bulleted),
          ),
          const SizedBox(height: 5),
          const Text(
            "GO TO HOME",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _buildTab("schedule", "Upcoming Schedules")),
        const SizedBox(width: 10),
        Expanded(child: _buildTab("renewal", "Upcoming Renewals")),
      ],
    );
  }

  Widget _buildTab(String value, String title) {
    final isSelected = selectedTab == value;

    return InkWell(
      onTap: () async {
        setState(() {
          selectedTab = value;
        });
        if (value == "schedule") {
          filterMessage = "Showing activities for next $scheduleDays days";
          setScheduleDates();
          await leadUpcomingSchedules();
          applyFilter();
        } else {
          filterMessage = "Showing renewal in next $renewalDays days";
          setRenewalDates();
          applyFilter();
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.black,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: -10,
              child: Container(
                width: 40,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      color: Colors.white,

      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfo("Showing Date", showingDate), //Changes on 11Aug26
            _buildInfo("Timing", showingTime),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRefreshCard() {
    return Card(
      child: InkWell(
        onTap: () async {
          print("Refresh Clicked");

          //await callApi();
          await repository.refreshLeads(sapCode: StaticVariables.mSAPCode);

          await getLeadDetails();
          //Added By Rahul on 29th May 2026
          if (selectedTab == "schedule") {
            filterMessage = "Showing activities for next $scheduleDays days";
            setScheduleDates();
            await leadUpcomingSchedules();
          } else {
            filterMessage = "Showing renewal in next $renewalDays days";
            setRenewalDates();
          }

          applyFilter();
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.refresh, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Refresh Leads",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          filterMessage,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        CircleAvatar(
          backgroundColor: Colors.blue,
          child: IconButton(
            onPressed: () {
              setState(() {
                isFilterVisible = !isFilterVisible;
              });
            },
            icon: const Icon(Icons.filter_alt, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(Colors.red, "Renewal Leads"),
        const SizedBox(width: 20),
        _legendItem(Colors.blue, "Fresh Leads"),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  Widget _buildFilterSection() {
    if (!isFilterVisible) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(child: _buildDateUI("From Date", fromDate, true)),
            const SizedBox(width: 10),

            Expanded(child: _buildDateUI("To Date", toDate, false)),
          ],
        ),
        const SizedBox(height: 15),

        const Text(
          "Product",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),

        //Added by manish 11Aug26
        InkWell(
          onTap: () {
            _showProductSearchDialog();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedProduct ?? "Select Product",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedProduct == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ), //end by manish
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(10),
        //     border: Border.all(color: Colors.black),
        //   ),
        //   child: DropdownButton<String>(
        //     value: selectedProduct,
        //     isExpanded: true,
        //     underline: const SizedBox(),
        //     items: productList.map((item) {
        //       return DropdownMenuItem<String>(value: item, child: Text(item));
        //     }).toList(),
        //     onChanged: (val) {
        //       int index = productList.indexOf(val!);
        //       setState(() {
        //         selectedProduct = val;
        //         selectedProductCode = productCodeList[index];
        //       });
        //       applyFilter();
        //     },
        //     hint: const Text("Select Product"),
        //   ),
        // ),
      ],
    );
  }

  //Added by manish on 11Aug26
  void _showProductSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    List<String> filteredProducts = List<String>.from(productList);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void searchProduct(String value) {
              setDialogState(() {
                final searchText = value.trim().toLowerCase();

                if (searchText.isEmpty) {
                  filteredProducts = List<String>.from(productList);
                } else {
                  filteredProducts = productList
                      .where(
                        (product) => product.toLowerCase().contains(searchText),
                      )
                      .toList();
                }
              });
            }

            return AlertDialog(
              title: const Text("Select Product"),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: searchProduct,
                      decoration: InputDecoration(
                        hintText: "Search Product",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  searchProduct("");
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                "No Product Found",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];

                                final productIndex = productList.indexOf(
                                  product,
                                );

                                final isSelected = selectedProduct == product;

                                return ListTile(
                                  title: Text(product),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.blue,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      selectedProduct = product;

                                      if (productIndex >= 0 &&
                                          productIndex <
                                              productCodeList.length) {
                                        selectedProductCode =
                                            productCodeList[productIndex];
                                      } else {
                                        selectedProductCode = "";
                                      }
                                    });

                                    Navigator.of(dialogContext).pop();

                                    applyFilter();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );
      },
    );
  } //end by manish

  Widget _buildDateUI(String title, String value, bool isFrom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        InkWell(
          onTap: () async {
            final now = DateTime.now();

            // Maximum allowed days based on selected tab
            final int maxDays = selectedTab == "schedule"
                ? int.tryParse(scheduleDays) ?? 5
                : int.tryParse(renewalDays) ?? 10;

            // Calculate maximum selectable date
            final DateTime maxDate = now.add(Duration(days: maxDays - 1));

            final pickedDate = await showDatePicker(
              context: context,

              // Start from today
              initialDate: now,

              // Don't allow dates before today
              firstDate: now,

              // Disable dates after allowed range
              lastDate: maxDate,
            );

            if (pickedDate != null) {
              final String formatted =
                  "${pickedDate.day.toString().padLeft(2, '0')}-"
                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                  "${pickedDate.year}";

              setState(() {
                if (isFrom) {
                  fromDate = formatted;
                } else {
                  toDate = formatted;
                }
              });

              applyFilter();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(value), const Icon(Icons.calendar_month)],
            ),
          ),
        ),
      ],
    );
  }

  DateTime convertDate(String date) {
    final parts = date.split("-");

    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  String formatApiDate(String apiDate) {
    if (apiDate.isEmpty) return "";

    print(apiDate);

    DateTime parsedDate = DateTime.parse(apiDate);

    return DateFormat("dd-MM-yyyy  hh:mm a").format(parsedDate);
  }

  //added by manish on 11Aug26 for logout bug
  void popUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CommonPopup(
          title: "Logout",
          message: "Are you sure you want to logout?",
          onNo: () {
            Navigator.of(dialogContext).pop();
          },
          onYes: () {
            Navigator.of(dialogContext).pop();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginActivity()),
            );
          },
        );
      },
    );
  } //end for logout

  void setScheduleDates() {
    final now = DateTime.now();

    fromDate =
        "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}";

    final to = now.add(Duration(days: int.parse(scheduleDays) - 1));

    toDate =
        "${to.day.toString().padLeft(2, '0')}-"
        "${to.month.toString().padLeft(2, '0')}-"
        "${to.year}";
  }

  void setRenewalDates() {
    final now = DateTime.now();

    fromDate =
        "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year}";

    final to = now.add(Duration(days: int.parse(renewalDays) - 1));

    toDate =
        "${to.day.toString().padLeft(2, '0')}-"
        "${to.month.toString().padLeft(2, '0')}-"
        "${to.year}";
  }

  void applyFilter() {
    DateTime startDate = convertDate(fromDate);
    DateTime endDate = convertDate(toDate);

    List<Map<String, dynamic>> tempList = [];
    List<Map<String, dynamic>> sourceList = selectedTab == "schedule"
        ? scheduleList
        : leadList;

    for (var item in sourceList) {
      try {
        DateTime? compareDate;

        // UPCOMING SCHEDULE FILTER
        if (selectedTab == "schedule") {
          String createdDate = item["CreateDTim"]?.toString() ?? "";

          if (createdDate.isEmpty) continue;

          compareDate = DateTime.parse(createdDate);
        }
        // UPCOMING RENEWAL FILTER
        else {
          String renewalDate = item["PolicyEndDate"]?.toString() ?? "";

          if (renewalDate.isEmpty) continue;

          compareDate = DateTime.parse(renewalDate);
        }

        bool isBetween =
            compareDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            compareDate.isBefore(endDate.add(const Duration(days: 1)));

        if (!isBetween) continue;

        // PRODUCT FILTER
        if (selectedProductCode.isNotEmpty) {
          if (item["ProdCode"].toString() != selectedProductCode) {
            continue;
          }
        }

        tempList.add(item);
      } catch (e) {
        print("Filter Error: $e");
      }
    }

    setState(() {
      filteredList = tempList;
    });
  }

  Widget _buildRenewalList() {
    if (filteredList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            "No Renewal Leads Available",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = filteredList[index];
        // String Makemodel = item["Make"] ?? "" + item["Model"] ?? "";

        String makeModel = "${item["Make"] ?? ""} ${item["Model"] ?? ""}"
            .trim();
        if (makeModel.isEmpty) {
          makeModel = "Not Available and Not Available";
        }
        String leadstatus = item["SrvcComments"] ?? "";
        if (leadstatus.isEmpty) {
          leadstatus = "Not Available";
        }

        String rawDate = item["PolicyEndDate"] ?? "";
        String displayDate = formatApiDate(rawDate);
        print(displayDate);

        return LeadCardWidget(
          pageFlag: "Renewal",

          leadData: {
            "leadType": item["LeadTypeDesc"] ?? "",

            "customerName": item["Name"] ?? "",

            "leadId": item["SrvcReqDtlCode"]?.toString() ?? "",

            "product": item["ProdName"] ?? "",

            "premium": item["leadAmt"]?.toString() ?? "0",

            "policyNumber": item["PolicyNo"] ?? "NA",

            "ncb": item["PolNCB"] ?? "NA",

            "vehicleModel": makeModel,

            "addon": item["Addon"] ?? "Not Available",

            "date": displayDate,

            "leadStatus": leadstatus,

            "renewalLink": item["RenewalPaymentLink"] ?? "NA",

            "mobileNumber": item["MobileTel"] ?? "",
          },

          onViewDetails: () async {
            String srvcReqDtlCode = item["SrvcReqDtlCode"]?.toString() ?? "";

            print("View Details Clicked: $srvcReqDtlCode");

            final String leadId = item["SrvcReqDtlCode"]?.toString() ?? "";
            final String PolicyNo = item["PolicyNo"]?.toString() ?? "";
            final apiresult = await GetSingleLeadDetails(
              sapCode: StaticVariables.mSAPCode,
              LeadID: leadId,
              PolicyNo: PolicyNo,
            );
            print("GetSingleLeadDetails $apiresult");

            final db = await DatabaseHelper.instance.database;

            final result = await db.query(
              "LeadDetails",
              where: "SrvcReqDtlCode = ?",
              whereArgs: [srvcReqDtlCode],
            );

            //If data is available

            if (result.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewDetails(lead: item, decryptedLead: item),
                ),
              );
            } else {
              final String leadId = item["SrvcReqDtlCode"]?.toString() ?? "";
              final String PolicyNo = item["PolicyNo"]?.toString() ?? "";
              final apiresult = await GetSingleLeadDetails(
                sapCode: StaticVariables.mSAPCode,
                LeadID: leadId,
                PolicyNo: PolicyNo,
              );
              if (apiresult["errorFlag"] == "success") {
                ///fetch again from db
                final freshResult = await db.query(
                  "LeadDetails",
                  where: "SrvcReqDtlCode = ?",
                  whereArgs: [leadId],
                );

                if (freshResult.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewDetails(
                        lead: freshResult.first,
                        decryptedLead: freshResult.first,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lead Saved Failed")),
                  );
                }

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) =>
                //         ViewDetails(lead: item, decryptedLead: item),
                //   ),
                // );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Customer/Lead details not available"),
                  ),
                );
              }
            }
          },

          //onCall: () async {},
          onCall: () async {
            await handleLeadCall(item);
          },

          onEmail: () async {},

          onMessage: () async {},

          onUpdateAcitivity: () async {
            String srvcReqDtlCode = item["SrvcReqDtlCode"]?.toString() ?? "";

            final db = await DatabaseHelper.instance.database;

            /// FETCH FROM DB
            final result = await db.query(
              "LeadDetails",
              where: "SrvcReqDtlCode = ?",
              whereArgs: [srvcReqDtlCode],
            );

            if (result.isNotEmpty) {
              final data = result.first;

              String userId = data["UserId"]?.toString() ?? "";

              String reqChannelId = data["ReqChannelId"]?.toString() ?? "";

              String leadSourceId = data["LeadSource"]?.toString() ?? "";

              String activityCode = data["ActivityStatus"]?.toString() ?? "";

              String leadType = data["LeadTypeDesc"]?.toString() ?? "";

              String bizType = data["BusinessType"]?.toString() ?? "";

              String tempSrvcReqDtlCode =
                  data["TempSrvcReqDtlCode"]?.toString() ?? "";

              /// VALIDATION
              if (userId == StaticVariables.mSAPCode) {
                /// CONDITION CHECK
                if (reqChannelId == "RQ17" && leadSourceId == "29") {
                  /// NAVIGATE UpdateActivity
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LeadUpdate(lead: item)),
                  );
                } else {
                  /// NAVIGATE UpdateNewActivity
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeadUpdateNew(lead: item),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "The lead is either converted or lost, you cannot perform any action now.",
                    ),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Lead details not found")),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildScheduleList() {
    if (filteredList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            "No Upcoming Schedule Available",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = filteredList[index];

        String makeModel = "${item["Make"] ?? ""} ${item["Model"] ?? ""}"
            .trim();

        if (makeModel.isEmpty) {
          makeModel = "Not Available";
        }

        String rawDate = item["ScheduleDate"] ?? "";
        String displayDate = formatApiDate(rawDate);

        return LeadCardWidget(
          pageFlag: "Schedule",

          leadData: {
            "leadType": item["LeadTypeDesc"] ?? "",

            "customerName": item["Name"] ?? "",

            "leadId": item["SrvcReqDtlCode"]?.toString() ?? "",

            "product": item["ProdName"] ?? "",

            "premium": item["leadAmt"]?.toString() ?? "0",

            "policyNumber": item["PolicyNo"] ?? "NA",

            "ncb": item["PolNCB"] ?? "NA",

            "vehicleModel": makeModel,

            "addon": item["Addon"] ?? "Not Available",

            // DIFFERENT FIELDS
            "date": displayDate,

            "leadStatus": item["ActivityDescription"]?.toString() ?? "Schedule",

            "mobileNumber": item["MobileTel"] ?? "",
          },

          onViewDetails: () async {
            String srvcReqDtlCode = item["SrvcReqDtlCode"]?.toString() ?? "";

            print("View Details Clicked: $srvcReqDtlCode");

            final String leadId = item["SrvcReqDtlCode"]?.toString() ?? "";
            final String PolicyNo = item["PolicyNo"]?.toString() ?? "";
            final apiresult = await GetSingleLeadDetails(
              sapCode: StaticVariables.mSAPCode,
              LeadID: leadId,
              PolicyNo: PolicyNo,
            );
            print("GetSingleLeadDetails $apiresult");

            final db = await DatabaseHelper.instance.database;

            final result = await db.query(
              "LeadDetails",
              where: "SrvcReqDtlCode = ?",
              whereArgs: [srvcReqDtlCode],
            );

            //If data is available

            if (result.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewDetails(lead: item, decryptedLead: item),
                ),
              );
            } else {
              final String leadId = item["SrvcReqDtlCode"]?.toString() ?? "";
              final String PolicyNo = item["PolicyNo"]?.toString() ?? "";
              final apiresult = await GetSingleLeadDetails(
                sapCode: StaticVariables.mSAPCode,
                LeadID: leadId,
                PolicyNo: PolicyNo,
              );
              if (apiresult["errorFlag"] == "success") {
                ///fetch again from db
                final freshResult = await db.query(
                  "LeadDetails",
                  where: "SrvcReqDtlCode = ?",
                  whereArgs: [leadId],
                );

                if (freshResult.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewDetails(
                        lead: freshResult.first,
                        decryptedLead: freshResult.first,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lead Saved Failed")),
                  );
                }

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) =>
                //         ViewDetails(lead: item, decryptedLead: item),
                //   ),
                // );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Customer/Lead details not available"),
                  ),
                );
              }
            }
          },

          onCall: () async {
            await handleLeadCall(item);
          },
          onEmail: () async {},

          onMessage: () async {},

          onUpdateAcitivity: () async {},
        );
      },
    );
  }
}
