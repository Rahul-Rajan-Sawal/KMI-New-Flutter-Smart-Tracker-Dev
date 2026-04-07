import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/common/common_popup.dart';
import 'package:flutter_bottom_nav/common/common_singltbtn_popup.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/async_search_customer_contact.dart';
import 'package:flutter_bottom_nav/core/repository/view_details_repository.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/dbcopyhelper.dart';

class ViewDetails extends StatefulWidget {
  final Map<String, dynamic> lead;
  final Map<String, dynamic> decryptedLead;

  const ViewDetails({Key? key, required this.lead, required this.decryptedLead})
    : super(key: key);

  @override
  State<ViewDetails> createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  bool isWithinWorkingHours(int fromHour, int toHour) {
    final now = DateTime.now();

    int currentMinutes = now.hour * 60 + now.minute;
    int start = fromHour * 60;
    int end = toHour * 60;

    if (start <= end) {
      return currentMinutes >= start && currentMinutes <= end;
    } else {
      return currentMinutes >= start || currentMinutes <= end;
    }
  }

  String bridgeCallToTime = "";
  String bridgeCallFromTime = "";
  String bridgeCallDownTime = "";
  String uniqueNo = "";
  late String leadId;
  late String leadValue;
  late String name;
  late String policyName;
  late String premium;
  late String vehicleMakeModel;
  late String ncb;
  late String addOn;
  late String activityStatus;
  late String activityDoneBy;
  late String activityDate;
  late String remark;
  late String tremark;
  late String emailId;
  late String mobilenumber;
  late String leadType;
  late String policyNumber;
  late String workflowStatus;
  late String leadStatus;
  late String activity;
  late String renewalNotice;

  final repo = ViewDetailsRepository();

  Future<void> loadBridgeCallTime() async {
    final data = await repo.getBridgeCallTimes(StaticVariables.mSAPCode);

    if (!mounted) return;

    if (data != null) {
      setState(() {
        bridgeCallToTime = data["BridgeCallToTime"] ?? "";
        bridgeCallFromTime = data["BridgeCallFromTime"] ?? "";
        bridgeCallDownTime = data["BridgeCallDownTime"] ?? "";
        print(bridgeCallToTime + bridgeCallFromTime + bridgeCallDownTime);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("INIT STATE CALLED");
    loadBridgeCallTime();
    String safeValue(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "Not Available";
      }
      return value.toString();
    }

    tremark = "Not Available";
    addOn = "Not Available";

    /// VALUES FROM lead MAP
    leadId = safeValue(widget.lead['SrvcReqDtlCode']);
    name = safeValue(widget.lead['Name']);
    policyName = safeValue(widget.lead['ProdName']);
    leadValue = "₹${safeValue(widget.lead['leadAmt'])}";

    /// DECRYPTED VALUES FROM decryptedLead MAP
    mobilenumber = safeValue(widget.decryptedLead['MobileTel']);
    emailId = safeValue(widget.decryptedLead['Email']);
    policyNumber = safeValue(widget.decryptedLead['PolicyNo']);
    leadType = safeValue(widget.decryptedLead['LeadType']);

    premium = "₹${safeValue(widget.decryptedLead['InstallmentPrem'])}";

    vehicleMakeModel =
        "${safeValue(widget.decryptedLead['Make'])} ${safeValue(widget.decryptedLead['Model'])}";

    ncb = safeValue(widget.decryptedLead['PolNCB']);

    activityStatus = safeValue(widget.decryptedLead['ActivityStatus']);

    activity = safeValue(widget.decryptedLead['TelesaleActivity']);
    activityDoneBy = safeValue(widget.decryptedLead['TelesaleActivityDoneBy']);
    activityDate = safeValue(widget.decryptedLead['TelesaleActivityDate']);

    remark = safeValue(widget.decryptedLead['TelesaleRemark']);

    workflowStatus = safeValue(widget.decryptedLead['WFStatus']);
    leadStatus = safeValue(widget.decryptedLead['WFStatDesc']);

    uniqueNo = policyNumber;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.blue[400],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                double top = constraints.biggest.height;
                bool isCollapsed = top <= kToolbarHeight + 20;

                return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: Text(
                    "Lead ID: $leadId",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  background: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF090979)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: top > kToolbarHeight + 20 ? 1.0 : 0.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$leadType",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      int fromHour =
                                          int.tryParse(bridgeCallFromTime) ?? 0;
                                      int toHour =
                                          int.tryParse(bridgeCallToTime) ?? 0;

                                      print(
                                        "From time : $fromHour Totime : $toHour",
                                      );

                                      bool iswithintime = isWithinWorkingHours(
                                        fromHour,
                                        toHour,
                                      );

                                      // if (!iswithintime) {
                                      //   CommonUtil.show(
                                      //     context,
                                      //     message:
                                      //         "Calling allowed only between $fromHour:00 and $toHour:00",
                                      //   );
                                      //   return;
                                      // }

                                      bool isAllowed = await repo.isDownTime(
                                        sapCode: StaticVariables.mSAPCode,
                                        srvcReqDtlCode: leadId,
                                      );

                                      if (!isAllowed) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return CommonSinglePopup(
                                              title: "Unable to make call",
                                              message:
                                                  "You cannot initiate a call within $bridgeCallDownTime minutes",
                                              onOk: (){
                                                Navigator.pop(context);
                                              }
                                            );
                                          },
                                        );
                                      }

                                      CommonUtil.show(
                                        context,
                                        message:
                                            "Searching For Customer Contact Please wait..",
                                      );

                                      // check the logged in user privecy  flag
                                      bool isPrivacy =
                                          await CommonUtil.isPrivacyFlag();
                                      print(isPrivacy);

                                      final result = await searchCustomerContact(
                                        sapCode: StaticVariables
                                            .mSAPCode, // make sure these variables exist
                                        leadNo: leadId,
                                        policyNo: policyNumber,
                                      );
                                      print(result);
                                      // final numbers = await repo
                                      //     .getCustomerMobileNumbers(leadId);
                                      // print(numbers);

                                      //Dummy mobile numbers

                                      bool hasPermission =
                                          await CommonUtil.requestCallPermission();

                                      if (!hasPermission) {
                                        print(
                                          "permission not granted to make call",
                                        );
                                        return;
                                      }
                                      final List<String> numbers = [
                                        "8459408423",
                                        "8652192185",
                                        "9029352977",
                                      ];
                                      if (numbers.isEmpty) {
                                        CommonUtil.hide(context);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Number Not Available",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (numbers.length == 1) {
                                        CommonUtil.hide(context);
                                        await CommonUtil.makeCall(
                                          numbers.first,
                                          leadId,
                                          uniqueNo,
                                          name,
                                        );
                                      } else {
                                        CommonUtil.hide(context);
                                        _showNumberSelection(numbers);
                                      }

                                      // handle response
                                      if (result["errorFlag"] == "success") {
                                        print("API Success");
                                      } else {
                                        print("API Failed");
                                      }
                                      CommonUtil.hide(context);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.call,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Call",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    children: const [
                                      Icon(
                                        Icons.phone_callback_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Call Status",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    children: const [
                                      Icon(
                                        Icons.message,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Message",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    children: const [
                                      Icon(
                                        Icons.email,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Email",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              //Updated Ui
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //    InkWell(
                              //     onTap: ()async{
                              //       print("CAll Icon Clicked You Mother fucker !");
                              //     },
                              //    ),

                              //     Column(
                              //       children: const [
                              //         Icon(Icons.call,
                              //             color: Colors.white, size: 28),
                              //         SizedBox(height: 4),
                              //         Text("Call",
                              //             style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 12)),
                              //       ],
                              //     ),
                              //    // const SizedBox(width: 32),

                              //      Column(
                              //       children: const [
                              //         Icon(Icons.phone_callback_outlined,
                              //             color: Colors.white, size: 28),
                              //         SizedBox(height: 4),
                              //         Text("Call Status",
                              //             style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 12)),
                              //       ],
                              //     ),
                              //    // const SizedBox(width: 32),
                              //     Column(
                              //       children: const [
                              //         Icon(Icons.message,
                              //             color: Co lors.white, size: 28),
                              //         SizedBox(height: 4),
                              //         Text("Message",
                              //             style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 12)),
                              //       ],
                              //     ),
                              //     //const SizedBox(width: 32),
                              //     Column(
                              //       children: const [
                              //         Icon(Icons.email,
                              //             color: Colors.white, size: 28),
                              //         SizedBox(height: 4),
                              //         Text("Email",
                              //             style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 12)),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              const SizedBox(height: 12),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isCollapsed ? 1.0 : 0.0,
                                child: Column(
                                  children: [
                                    Text(
                                      leadId,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      leadValue,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// 🔽 SCROLL CONTENT
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Contact Details",
                              style: TextStyle(
                                color: Color(0xFF17479E),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              iconSize: 25,
                              onPressed: () {
                                DatabaseCopyHelper dbHelper =
                                    DatabaseCopyHelper(context);
                                dbHelper.copyDatabaseToDownloads();
                                print("Icon Clicked");
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                      vertical: 5,
                                    ),
                                    child: const Text(
                                      "Mobile Number",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                      vertical: 5,
                                    ),
                                    child: Text(
                                      ": $mobilenumber",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF17479E),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      8,
                                      0,
                                      15,
                                    ),
                                    child: const Text(
                                      "Email Id",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                    child: Text(
                                      ":$emailId",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF17479E),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // CARD 2
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Last Activity",
                              style: TextStyle(
                                color: Color(0xFF17479E),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              iconSize: 25,
                              onPressed: () {
                                print("icon edit card 2 tapped");
                              },
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Activity Status",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  ": $activityStatus",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Remark",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $remark",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // CARD 3
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Lead Detail",
                              style: TextStyle(
                                color: Color(0xFF17479E),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.note),
                              iconSize: 25,
                              onPressed: () {
                                print("icon edit card 2 tapped");
                              },
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Product",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  ": $policyName",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Policy Number",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $policyNumber",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Lead Type",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $leadType",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Premium",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $premium",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Vehicle Make & Model",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $vehicleMakeModel",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "NCB",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $ncb",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Add-On",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $addOn",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                //Card 4
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),
                            const Text(
                              "Telesales Disposition",
                              style: TextStyle(
                                color: Color(0xFF17479E),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Activity",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  ": $activityStatus",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Activity Done By",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $activityDoneBy",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Activity Date",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $activityDate",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Remark",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $tremark",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                //Card 5
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),
                            const Text(
                              "Lead Status",
                              style: TextStyle(
                                color: Color(0xFF17479E),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Lead Status",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  ": $leadStatus",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 150,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  "Work Flow Status",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 15),
                                child: Text(
                                  ": $workflowStatus",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17479E),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        const Divider(color: Colors.grey, thickness: 1),
                        const SizedBox(height: 8),
                        //iconss
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Renewal Notice",
                              style: TextStyle(
                                color: Color(0xFF17479E),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  iconSize: 30,
                                  onPressed: () {
                                    print("icon edit card 2 tapped");
                                  },
                                ),
                                Text("Mail"),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye),
                                  iconSize: 30,
                                  onPressed: () {
                                    print("icon edit card 2 tapped");
                                  },
                                ),
                                Text("View"),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  iconSize: 30,
                                  onPressed: () {
                                    print("icon edit card 2 tapped");
                                  },
                                ),
                                Text("Share"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        const Divider(color: Colors.grey, thickness: 1),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Log",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF17479E),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Date & Time"), Text("Mode")],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // void showNumberSelectionDialog(List<String> numbers) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Select Mobile Number"),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: numbers.length,
  //           itemBuilder: (context, index) {
  //             final number = numbers[index];

  //             return ListTile(
  //               leading: const Icon(Icons.phone),
  //               title: Text(number),
  //               onTap: () async {
  //                 Navigator.pop(context);

  //                 await CommonUtil.makeCall(number);
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showNumberSelection(List<String> numbers) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 200 + numbers.length * 60, // ensures enough height
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Select Number",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: numbers.map((number) {
                    return ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(number),
                      onTap: () async {
                        Navigator.pop(context);
                        await CommonUtil.makeCall(
                          number,
                          leadId,
                          uniqueNo,
                          name,
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
