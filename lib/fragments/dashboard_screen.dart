import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/filter_activity.dart';
import 'package:flutter_bottom_nav/Activities/view_details.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/apicall/getdata_fordashboard.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/Dashboard/dashboard_detail_model.dart';
import 'package:flutter_bottom_nav/models/Dashboard/dashboard_summary_model.dart';
import 'package:flutter_bottom_nav/models/dashboard_provider.dart';
import 'package:flutter_bottom_nav/models/route_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with RouteAware {
  // int? _expandedCardIndex;
  CardData? _selectedCard;
  bool _isGridFilterApplied = false;
  List<DashboardDetailModel> _gridFilteredList = [];

  //String _nop = "...";
  //String _gwp = "...";
  String _dashboardDate = "Not Available";
  String _dashboardTime = "NA";

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  String _dashboardType = "self";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _printPath();
    // _fetchData();
    _loadSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDashboardLogic();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _handleDashboardLogic();
  }

  // Future<void> _handleDashboardLogic() async {
  //   final dashboardType = getDashboardType();
  //   bool isDashboardListFilter = false;
  //   final isFilter = isDashboardListFilter;

  //   if (dashboardType.toLowerCase() == "team" && !isFilter) {
  //     final db = await DatabaseHelper.instance.database;

  //     final result = await db.query(
  //       'TeamDashboardData_Mob',
  //       where: 'RMCode = ?',
  //       whereArgs: [StaticVariables.mSAPCode.toUpperCase()],
  //     );

  //     if (result.isNotEmpty) {
  //       print("Data available in DB → Fetch from table");
  //       //_prepareTeamDashboard(); // we will write later
  //     } else {
  //       print("No data → Call API");
  //       _callDashboardData(false); // we will write later
  //     }
  //   } else if (dashboardType.toLowerCase() == "self" && !isFilter) {
  //     _callDashboardData(false);
  //   } else {
  //     isDashboardListFilter = false;
  //   }
  // }

  // Future<void> _callDashboardData(bool isFromFilter) async {
  //   final now = DateTime.now();
  //   final month = "${now.year}-${now.month.toString().padLeft(2, '0')}-01";

  //   await ref
  //       .read(dashboardProvider.notifier)
  //       .loadDashboard(
  //         rmCode:
  //             StaticVariables.mSAPCode, // replace with actual login SAP code
  //         month: month, // current month
  //       );
  // }

  // String getDashboardType() {
  //   // if (mDashboardType != null && mDashboardType.trim().length() > 0 && (mDashboardType.trim().equalsIgnoreCase("Team") ||
  //   //         mDashboardType.trim().equalsIgnoreCase("Self"))) {
  //   //     return mDashboardType;
  //   // } else if (mDashboardType == null || mDashboardType.trim().length() <= 0 || (!mDashboardType.trim().equalsIgnoreCase("Team") &&
  //   //         !mDashboardType.trim().equalsIgnoreCase("Self"))) {
  //   //     if (img_selfDashboardSelect.getVisibility() == View.VISIBLE) {
  //   //         return "Self";
  //   //     } else if (img_teamDashboardSelect.getVisibility() == View.VISIBLE) {
  //   //         return "Team";
  //   //     } else {
  //   //         return mDashboardType;
  //   //     }
  //   // } else {
  //   //     return mDashboardType;
  //   // }
  //   return "self";
  // }

  // void _fetchData() async {
  //   await Future.delayed(const Duration(seconds: 2));

  //   setState(() {
  //     _currentDate = "20-01-2025";
  //     _currentTiming = "04:33 AM";
  //     _nop = "12";
  //     _gwp = "24.20";
  //   });
  // }

  //Newly revised functionmethods by Rahul on 30-06-2026

  String getActivityCodeFromStatus(String status) {
    switch (status) {
      case "Converted":
        return "35";
      case "Sale Closed":
        return "36";
      case "Lost":
        return "38";
      case "Open":
        return "37";
      default:
        return "";
    }
  }

  String getFlagFromStatus(String status) {
    switch (status) {
      case "Converted":
        return "Converted";
      case "Sale Closed":
        return "Close";
      case "Lost":
        return "Lost";
      case "Open":
        return "Open";
      default:
        return "";
    }
  }

  Future<void> printLeadDetailsRecords() async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query("LeadDetails");

    print("========== LEAD DETAILS RAW RECORDS ==========");
    print("LeadDetails total rows = ${rows.length}");

    for (int i = 0; i < rows.length && i < 5; i++) {
      final row = rows[i];

      print("---------- LeadDetails ROW $i ----------");
      print("UserId => ${row["UserId"]}");
      print("SMCode => ${row["SMCode"]}");
      print("MothYear => ${row["MothYear"]}");
      print("Activity => ${row["Activity"]}");
      print("SubActivity => ${row["SubActivity"]}");
      print("LeadType => ${row["LeadType"]}");
      print("SrvcReqDtlCode => ${row["SrvcReqDtlCode"]}");
      print("PolicyNo => ${row["PolicyNo"]}");
      print("ProdName => ${row["ProdName"]}");
      print("leadAmt => ${row["leadAmt"]}");
    }

    print("========== END LEAD DETAILS ==========");
  }

  Future<void> _handleDashboardLogic() async {
    await _callDashboardData(forceRefresh: false);
  }

  String get selectedMonthLabel {
    return DateFormat("MMMM yyyy").format(_selectedMonth);
  }

  String get currentMonthParam {
    return "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-01";
  }

  // Future<void> _callDashboardData({required bool forceRefresh}) async {
  //   final month =
  //       "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-01";

  //   await ref
  //       .read(dashboardProvider.notifier)
  //       .loadDashboard(
  //         rmCode: StaticVariables.mSAPCode.toUpperCase(),
  //         month: month,
  //         forceRefresh: forceRefresh,
  //         leadType: _selectedType,
  //       );

  //   await _loadSession();
  // }

  //changed
  Future<void> _callDashboardData({required bool forceRefresh}) async {
    final selectedLeadType = ref.read(dashboardLeadTypeProvider);

    await ref
        .read(dashboardProvider.notifier)
        .loadDashboard(
          rmCode: StaticVariables.mSAPCode.toUpperCase(),
          month: currentMonthParam,
          forceRefresh: forceRefresh,
          leadType: selectedLeadType,
        );

    await _loadSession();
    await printLeadDetailsRecords();
  }

  Future<void> _loadSession() async {
    final user = await DatabaseHelper.instance.getUserByUserId(
      StaticVariables.mSAPCode,
    );

    if (user != null) {
      String DashboardUpdatedDate = CommonUtil.decryptIfNotEmpty(
        user['DashboardUpdatedDate'] as String,
      );
      print('DashboardUpdatedDate:$DashboardUpdatedDate');

      if (DashboardUpdatedDate.isEmpty || DashboardUpdatedDate == "-") {
        setState(() {
          _dashboardDate = "Not available";
          _dashboardTime = "NA";
        });
        return;
      }

      try {
        String formattedString = DashboardUpdatedDate.replaceAll("T", " ");

        DateTime parsedDate = DateFormat(
          "dd-MM-yyyy hh:mm a",
        ).parse(formattedString);

        String date = DateFormat("dd-MM-yyyy").format(parsedDate);

        String time = DateFormat("hh:mm a").format(parsedDate).toUpperCase();

        setState(() {
          _dashboardDate = date;
          _dashboardTime = time;
        });
      } catch (e) {
        setState(() {
          _dashboardDate = "Not Available";
          _dashboardTime = "NA";
        });
      }

      String mUserName = CommonUtil.decryptIfNotEmpty(
        user['UserName'] as String,
      );
      print('mUserName:$mUserName');
      String mBranchName = CommonUtil.decryptIfNotEmpty(
        user['BranchName'] as String,
      );
      print('BranchName:$mBranchName');
      String Createdby = CommonUtil.decryptIfNotEmpty(
        user['Createdby'] as String,
      );
      print('Createdby:$Createdby');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, stack) => Center(child: Text('Error: $err')),

        data: (summary) {
          print("_selectedCard = $_selectedCard");
          print("DASHBOARD DATA STATE REACHED");
          print("Total Leads: ${summary.totalLeads}");
          print("Converted: ${summary.convertedCount}");
          print("Lost: ${summary.lostCount}");
          print("Open: ${summary.openCount}");
          print("Sale Closed: ${summary.salesCloseCount}");
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopCard(),
                _buildRefreshCard(),

                if (_selectedCard == null) ...[
                  _buildStatusCard(summary), // 👈 PASS SUMMARY
                  const SizedBox(height: 12),
                  _buildGrid(summary), // 👈 PASS SUMMARY
                ],

                if (_selectedCard != null) ...[
                  const SizedBox(height: 12),
                  _buildExpandedSection(summary),
                ],

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  //added for the lead open radio
  CardData _getUpdatedSelectedCard(DashboardSummary summary) {
    switch (_selectedCard?.title) {
      case "Converted":
        return CardData(
          title: "Converted",
          percentage: "${summary.convertedPercentage.toStringAsFixed(2)}%",
          nop: summary.convertedCount.toString(),
          gwp: CommonUtil.getValueInLakh(summary.convertedAmount),
        );

      case "Lost":
        return CardData(
          title: "Lost",
          percentage: "${summary.lostPercentage.toStringAsFixed(2)}%",
          nop: summary.lostCount.toString(),
          gwp: CommonUtil.getValueInLakh(summary.lostAmount),
        );

      case "Open":
        return CardData(
          title: "Open",
          percentage: "${summary.openPercentage.toStringAsFixed(2)}%",
          nop: summary.openCount.toString(),
          gwp: CommonUtil.getValueInLakh(summary.openAmount),
        );

      case "Sale Closed":
        return CardData(
          title: "Sale Closed",
          percentage: "${summary.salesClosedPercentage.toStringAsFixed(2)}%",
          nop: summary.salesCloseCount.toString(),
          gwp: CommonUtil.getValueInLakh(summary.salesCloseAmount),
        );

      default:
        return _selectedCard!;
    }
  }

  Widget _buildExpandedSection(DashboardSummary summary) {
    final selectedCard = _getUpdatedSelectedCard(summary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Back Button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedCard = null;
            });
          },
        ),

        /// Expanded Main Card (uses real data)
        Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  // _selectedCard!.title,
                  selectedCard.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479e),
                  ),
                ),
                const SizedBox(height: 12),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     _buildStatColumn("NOP", _selectedCard!.nop.toString()),
                //     _buildStatColumn(
                //       "GWP(in Lacs)",
                //       _selectedCard!.gwp.toString(),
                //     ),
                //     _buildStatColumn(
                //       "Percentage",
                //       _selectedCard!.percentage.toString(),
                //     ),
                //   ],
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     _buildStatColumn("NOP", selectedCard.nop),
                //     _buildStatColumn("GWP(in Lacs)", selectedCard.gwp),
                //     _buildStatColumn("Percentage", selectedCard.percentage),
                //   ],
                // ),
                _buildExpandedStatsBox(selectedCard),

                const SizedBox(height: 12),
                // Radio btns
                Text(
                  selectedMonthLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479e),
                  ),
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRadioItem("All", 1),
                    _buildRadioItem("Contact", 2),
                    _buildRadioItem("Lead", 3),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 26),

        /// Mini Cards
        // Row(
        //   children: [
        //     Expanded(child: _buildMiniCard("Parked", "45")),
        //     const SizedBox(width: 12),
        //     Expanded(child: _buildMiniCard("Follow Up", "12")),
        //   ],
        // ),
        _buildSubStatusCards(summary),

        /// 👇 Show Recycler Grid ONLY when Open clicked
        // if (_selectedCard!.title == "Open") ...[
        //   const SizedBox(height: 16),
        //   _buildRecyclerGrid(),
        // ],
        // const SizedBox(height: 16),
        // _buildRecyclerGrid(),
        if (_selectedCard?.title == "Open") ...[
          const SizedBox(height: 16),
          _buildRecyclerGrid(),
        ],
      ],
    );
  }

  Widget _buildSubStatusCards(DashboardSummary summary) {
    final selectedTitle = _selectedCard?.title ?? "";

    // if (selectedTitle == "Lost") {
    //   return Row(
    //     children: [
    //       Expanded(
    //         child: _buildMiniCard(
    //           "Lost to Competitor",
    //           summary.lostToCompetitionCount.toString(),
    //         ),
    //       ),
    //       const SizedBox(width: 8),
    //       Expanded(
    //         child: _buildMiniCard(
    //           "Not Responding",
    //           summary.notRespondingCount.toString(),
    //         ),
    //       ),
    //       const SizedBox(width: 8),
    //       Expanded(
    //         child: _buildMiniCard(
    //           "Not Interested",
    //           summary.notInterestedCount.toString(),
    //         ),
    //       ),
    //     ],
    //   );
    // }
    // if (selectedTitle == "Lost") {
    //   return Row(
    //     children: [
    //       Expanded(
    //         child: _buildOpenLeadCard(
    //           title: "Lost to Competitor",
    //           nop: summary.lostToCompetitionCount.toString(),
    //           gwp: CommonUtil.getValueInLakh(summary.lostToCompetitionAmount),
    //         ),
    //       ),
    //       const SizedBox(width: 8),
    //       Expanded(
    //         child: _buildOpenLeadCard(
    //           title: "Not Responding",
    //           nop: summary.notRespondingCount.toString(),
    //           gwp: CommonUtil.getValueInLakh(summary.notRespondingAmount),
    //         ),
    //       ),
    //       const SizedBox(width: 8),
    //       Expanded(
    //         child: _buildOpenLeadCard(
    //           title: "Not Interested",
    //           nop: summary.notInterestedCount.toString(),
    //           gwp: CommonUtil.getValueInLakh(summary.notInterestedAmount),
    //         ),
    //       ),
    //     ],
    //   );
    // }
    if (selectedTitle == "Lost") {
      return Column(
        children: [
          Row(
            children: [
              SizedBox(width: 8),
              Expanded(
                child: _buildOpenLeadCard(
                  title: "Lost to Competitor",
                  nop: summary.lostToCompetitionCount.toString(),
                  gwp: CommonUtil.getValueInLakh(
                    summary.lostToCompetitionAmount,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _buildOpenLeadCard(
                  title: "Not Responding",
                  nop: summary.notRespondingCount.toString(),
                  gwp: CommonUtil.getValueInLakh(summary.notRespondingAmount),
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SizedBox(
                  width: (constraints.maxWidth - 8) / 2,
                  child: _buildOpenLeadCard(
                    title: "Not Interested",
                    nop: summary.notInterestedCount.toString(),
                    gwp: CommonUtil.getValueInLakh(summary.notInterestedAmount),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    // if (selectedTitle == "Open") {
    //   return Row(
    //     children: [
    //       Expanded(
    //         child: _buildMiniCard("Parked", summary.parkedCount.toString()),
    //       ),
    //       const SizedBox(width: 12),
    //       Expanded(
    //         child: _buildMiniCard(
    //           "Follow Up",
    //           summary.followUpCount.toString(),
    //         ),
    //       ),
    //     ],
    //   );
    // }

    if (selectedTitle == "Open") {
      return Row(
        children: [
          Expanded(
            child: _buildOpenLeadCard(
              title: "Parked",
              nop: summary.parkedCount.toString(),
              gwp: CommonUtil.getValueInLakh(summary.parkedAmount),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildOpenLeadCard(
              title: "Follow Up",
              nop: summary.followUpCount.toString(),
              gwp: CommonUtil.getValueInLakh(summary.followUpAmount),
            ),
          ),
        ],
      );
    }

    // if (selectedTitle == "Sale Closed") {
    //   return Row(
    //     children: [
    //       Expanded(
    //         child: _buildMiniCard(
    //           "Premium Collected",
    //           summary.premiumCollectedCount.toString(),
    //         ),
    //       ),
    //       const SizedBox(width: 12),
    //       Expanded(
    //         child: _buildMiniCard(
    //           "Policy Issued",
    //           summary.policyIssuedCount.toString(),
    //         ),
    //       ),
    //     ],
    //   );
    // }
    if (selectedTitle == "Sale Closed") {
      return Row(
        children: [
          Expanded(
            child: _buildOpenLeadCard(
              title: "Premium Collected",
              nop: summary.premiumCollectedCount.toString(),
              gwp: CommonUtil.getValueInLakh(summary.premiumCollectedAmount),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildOpenLeadCard(
              title: "Policy Issued",
              nop: summary.policyIssuedCount.toString(),
              gwp: CommonUtil.getValueInLakh(summary.policyIssuedAmount),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildExpandedStatsBox(CardData selectedCard) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  "NOP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479e),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "GWP(In Lacs)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479e),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "Percentage",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479e),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedCard.nop,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  selectedCard.gwp,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  selectedCard.percentage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  //Rahuls 2.0
  String _getGridColumnValue(DashboardDetailModel item, String columnName) {
    switch (columnName) {
      case "Lead No":
        return item.leadNo;
      case "Policy No":
        return item.policyNo;
      case "Product":
        return item.product;
      case "Premium":
        return item.premium;
      default:
        return "";
    }
  }

  Map<String, dynamic> _decryptDashboardLeadRow(Map<String, dynamic> row) {
    final decryptedLead = Map<String, dynamic>.from(row);

    final encryptedKeys = [
      "Name",
      "PolicyNo",
      "ProdName",
      "leadAmt",
      "Amount",
      "MobileTel",
      "Email",
      "InstallmentPrem",
      "Make",
      "Model",
      "PolNCB",
      "ActivityStatus",
      "TelesaleActivity",
      "TelesaleActivityDoneBy",
      "TelesaleActivityDate",
      "TelesaleRemark",
      "WFStatus",
      "WFStatDesc",
    ];

    for (final key in encryptedKeys) {
      decryptedLead[key] = CommonUtil.decryptIfNotEmpty(
        row[key]?.toString() ?? "",
      );
    }

    return decryptedLead;
  }

  Future<void> _openDashboardLeadDetails(String srvcReqDtlCode) async {
    if (srvcReqDtlCode.trim().isEmpty) return;

    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      "LeadDetails",
      where: "SrvcReqDtlCode = ?",
      whereArgs: [srvcReqDtlCode],
      limit: 1,
    );

    if (rows.isEmpty) {
      Fluttertoast.showToast(
        msg: "Customer/Lead details not available in mobile.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
      );
      return;
    }

    final decryptedLead = _decryptDashboardLeadRow(
      Map<String, dynamic>.from(rows.first),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewDetails(lead: decryptedLead, decryptedLead: decryptedLead),
      ),
    );
  }

  Widget _buildRecyclerGrid() {
    final isLoading = ref.watch(dashboardDetailsLoadingProvider);
    // final detailList = ref.watch(dashboardDetailsProvider);

    final originalList = ref.watch(dashboardDetailsProvider);
    final detailList = _isGridFilterApplied ? _gridFilteredList : originalList;

    print("DETAIL LIST LENGTH = ${detailList.length}");

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (detailList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No records found",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Table(
        border: TableBorder.all(color: Colors.black26, width: 1),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFE9E9E9)),
            children: [
              _buildGridHeaderCell("Lead No"),
              _buildGridHeaderCell("Policy No"),
              _buildGridHeaderCell("Product"),
              _buildGridHeaderCell("Premium"),
            ],
          ),

          ...detailList.map((item) {
            return TableRow(
              children: [
                _buildGridDataCell(
                  item.leadNo,
                  onTap: () {
                    _openDashboardLeadDetails(item.leadNo);
                  },
                ),
                _buildGridDataCell(
                  item.policyNo,
                  onTap: () {
                    _openDashboardLeadDetails(item.leadNo);
                  },
                ),

                // _buildGridDataCell(item.leadNo),
                // _buildGridDataCell(item.policyNo),
                _buildGridDataCell(item.product),
                _buildGridDataCell(item.premium),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  //version 3.0
  Widget _buildGridHeaderCell(String title) {
    return InkWell(
      onTap: () {
        _showGridFilterPopup(title);
      },
      child: SizedBox(
        height: 42,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479e),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.filter_alt_outlined,
                size: 15,
                color: Color(0xFF17479e),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGridFilterPopup(String columnName) {
    final originalList = ref.read(dashboardDetailsProvider);

    final allValues = originalList
        .map((item) => _getGridColumnValue(item, columnName).trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    allValues.sort();

    List<String> filteredValues = List.from(allValues);
    Set<String> tempSelected = {};

    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 18),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 52),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  columnName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.close, size: 22),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              hintText: "Search",
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                filteredValues = allValues
                                    .where(
                                      (item) => item.toUpperCase().contains(
                                        value.toUpperCase(),
                                      ),
                                    )
                                    .toList();
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 2),

                        if (filteredValues.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text("No record found"),
                          )
                        else
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredValues.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, thickness: 0.3),
                              itemBuilder: (context, index) {
                                final value = filteredValues[index];

                                return Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Checkbox(
                                            value: tempSelected.contains(value),
                                            onChanged: (checked) {
                                              setDialogState(() {
                                                if (checked == true) {
                                                  tempSelected.add(value);
                                                } else {
                                                  tempSelected.remove(value);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: -5,
                    right: -5,
                    bottom: 0,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (tempSelected.isEmpty) {
                            Fluttertoast.showToast(
                              msg:
                                  "Please select atleast one ${columnName.toLowerCase()}",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.SNACKBAR,
                            );
                            return;
                          }

                          final selectedRows = originalList.where((item) {
                            final value = _getGridColumnValue(item, columnName);
                            return tempSelected.contains(value);
                          }).toList();

                          setState(() {
                            _isGridFilterApplied = true;
                            _gridFilteredList = selectedRows;
                          });

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Select",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //version 3.0
  Widget _buildGridDataCell(String value, {VoidCallback? onTap}) {
    final isClickable = onTap != null;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isClickable ? const Color(0xFF17479e) : Colors.black87,
                decoration: isClickable
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
  //version 2.0
  // Widget _buildGridHeaderCell(String title) {
  //   return SizedBox(
  //     height: 42,
  //     child: Center(
  //       child: Text(
  //         title,
  //         textAlign: TextAlign.center,
  //         style: const TextStyle(
  //           fontSize: 13,
  //           fontWeight: FontWeight.bold,
  //           color: Color(0xFF17479e),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildGridDataCell(String value) {
  //   return SizedBox(
  //     height: 46,
  //     child: Center(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 4),
  //         child: Text(
  //           value,
  //           textAlign: TextAlign.center,
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //           style: const TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.black87,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // //Rahuls1.0
  //   Widget _buildRecyclerGrid() {
  //     final isLoading = ref.watch(dashboardDetailsLoadingProvider);
  //     final detailList = ref.watch(dashboardDetailsProvider);
  //     print("DETAIL LIST LENGTH = ${detailList.length}");
  //     if (isLoading) {
  //       return const Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Center(child: CircularProgressIndicator()),
  //       );
  //     }

  //     if (detailList.isEmpty) {
  //       return const Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Center(
  //           child: Text(
  //             "No records found",
  //             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  //           ),
  //         ),
  //       );
  //     }

  //     return Column(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.symmetric(vertical: 10),
  //           decoration: const BoxDecoration(
  //             border: Border(bottom: BorderSide(color: Colors.grey)),
  //           ),
  //           child: Row(
  //             children: [
  //               _buildHeaderCell("Lead No"),
  //               _buildHeaderCell("Policy No"),
  //               _buildHeaderCell("Product"),
  //               _buildHeaderCell("Premium"),
  //             ],
  //           ),
  //         ),

  //         const SizedBox(height: 8),

  //         ListView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: detailList.length,
  //           itemBuilder: (context, index) {
  //             final item = detailList[index];

  //             return Container(
  //               padding: const EdgeInsets.symmetric(vertical: 12),
  //               decoration: const BoxDecoration(
  //                 border: Border(bottom: BorderSide(color: Colors.black12)),
  //               ),
  //               child: Row(
  //                 children: [
  //                   _buildDataCell(item.leadNo),
  //                   _buildDataCell(item.policyNo),
  //                   _buildDataCell(item.product),
  //                   _buildDataCell(item.premium),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ],
  //     );
  //   }
  //sameers
  // Widget _buildRecyclerGrid() {
  //   final List<OpenItem> openList = [
  //     OpenItem(
  //       leadNo: "LD001",
  //       policyNo: "POL12345",
  //       product: "Motor",
  //       premium: "₹12,500",
  //     ),
  //     OpenItem(
  //       leadNo: "LD002",
  //       policyNo: "POL56789",
  //       product: "Health",
  //       premium: "₹18,300",
  //     ),
  //     OpenItem(
  //       leadNo: "LD003",
  //       policyNo: "POL99999",
  //       product: "Life",
  //       premium: "₹25,000",
  //     ),
  //     OpenItem(
  //       leadNo: "LD004",
  //       policyNo: "POL12345",
  //       product: "Motor",
  //       premium: "₹12,500",
  //     ),
  //     OpenItem(
  //       leadNo: "LD005",
  //       policyNo: "POL56789",
  //       product: "Health",
  //       premium: "₹18,300",
  //     ),
  //     OpenItem(
  //       leadNo: "LD006",
  //       policyNo: "POL99999",
  //       product: "Life",
  //       premium: "₹25,000",
  //     ),
  //     OpenItem(
  //       leadNo: "LD007",
  //       policyNo: "POL12345",
  //       product: "Motor",
  //       premium: "₹12,500",
  //     ),
  //     OpenItem(
  //       leadNo: "LD008",
  //       policyNo: "POL56789",
  //       product: "Health",
  //       premium: "₹18,300",
  //     ),
  //     OpenItem(
  //       leadNo: "LD009",
  //       policyNo: "POL99999",
  //       product: "Life",
  //       premium: "₹25,000",
  //     ),
  //   ];

  //   return Column(
  //     children: [
  //       /// =========================
  //       /// HEADER ROW (Clickable)
  //       /// =========================
  //       Container(
  //         padding: const EdgeInsets.symmetric(vertical: 10),
  //         decoration: const BoxDecoration(
  //           border: Border(bottom: BorderSide(color: Colors.grey)),
  //         ),
  //         child: Row(
  //           children: [
  //             _buildHeaderCell("Lead No"),
  //             _buildHeaderCell("Policy No"),
  //             _buildHeaderCell("Product"),
  //             _buildHeaderCell("Premium"),
  //           ],
  //         ),
  //       ),

  //       const SizedBox(height: 8),

  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: openList.length,
  //         itemBuilder: (context, index) {
  //           final item = openList[index];

  //           return Container(
  //             padding: const EdgeInsets.symmetric(vertical: 12),
  //             decoration: const BoxDecoration(
  //               border: Border(bottom: BorderSide(color: Colors.black12)),
  //             ),
  //             child: Row(
  //               children: [
  //                 _buildDataCell(item.leadNo),
  //                 _buildDataCell(item.policyNo),
  //                 _buildDataCell(item.product),
  //                 _buildDataCell(item.premium),
  //               ],
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDataCell(String value) {
    return Expanded(
      child: Center(child: Text(value, style: const TextStyle(fontSize: 13))),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$title clicked"),
              duration: const Duration(milliseconds: 600),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF17479e),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.filter_alt_outlined, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Widget _buildTopCard() {
  //   return Card(
  //     color: Color(0xFFE9E9E9),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildCardItem("Showing Date", _currentDate),
  //           _buildCardItem("Timing", _currentTiming),
  //           _buildIcon(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //card updeated By Rahul
  Widget _buildTopCard() {
    return Card(
      color: const Color(0xFFE9E9E9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCardItem("Showing Date", _dashboardDate),
            _buildCardItem("Timing", _dashboardTime),
            _buildIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshCard() {
    return Card(
      color: Color(0xFFE9E9E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          await _refreshData();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildIconhorizontal("refresh"),
        ),
      ),
    );
  }

  Widget _buildStatusCard(DashboardSummary summary) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconhorizontal("status"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem("NOP", summary.totalLeads.toString()),
                _buildDetailItem(
                  "GWP(In Lacs)",
                  CommonUtil.getValueInLakh(summary.totalGwp),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // _buildDetailItem("Month-Year", "January 2026"),
                    Text(
                      // "March 2026",
                      selectedMonthLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17479e),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _buildRadioItem("All", 1),
                        _buildRadioItem("Contact", 2),
                        _buildRadioItem("Lead", 3),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(String title, String value) {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  //addd by rahul
  Widget _buildOpenLeadCard({
    required String title,
    required String nop,
    required String gwp,
  }) {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 105,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17479e),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOpenMetric("NOP", nop),
                  const SizedBox(
                    height: 30,
                    child: VerticalDivider(color: Colors.grey, thickness: 1),
                  ),
                  _buildOpenMetric("GWP", gwp),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Widget _buildRadioItem(String title, int value) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min, // Keep row tight
  //     children: [
  //       SizedBox(
  //         height: 30, // Reduces vertical space
  //         width: 30, // Reduces horizontal space
  //         child: Radio<int>(
  //           value: value,
  //           groupValue: _selectedType,
  //           onChanged: (int? newValue) {
  //             setState(() {
  //               _selectedType = newValue!;
  //             });
  //           },
  //         ),
  //       ),
  //       Text(title, style: const TextStyle(fontSize: 12)),
  //     ],
  //   );
  // }

  Widget _buildRadioItem(String title, int value) {
    return Consumer(
      builder: (context, ref, _) {
        final selectedType = ref.watch(dashboardLeadTypeProvider);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: Radio<int>(
                value: value,
                groupValue: selectedType,
                onChanged: (int? newValue) async {
                  if (newValue == null) return;
                  if (newValue == selectedType) return;

                  ref.read(dashboardLeadTypeProvider.notifier).state = newValue;

                  await ref
                      .read(dashboardProvider.notifier)
                      .changeLeadType(
                        rmCode: StaticVariables.mSAPCode.toUpperCase(),
                        month: currentMonthParam,
                        leadType: newValue,
                      );
                  // if (_selectedCard != null) {
                  //   await ref
                  //       .read(dashboardProvider.notifier)
                  //       .loadDashboardDetails(
                  //         rmCode: StaticVariables.mSAPCode.toUpperCase(),
                  //         month: currentMonthParam,
                  //         status: _selectedCard!.title,
                  //         leadType: newValue,
                  //       );
                  // }

                  //newly added by rahul

                  setState(() {
                    _isGridFilterApplied = false;
                    _gridFilteredList.clear();
                  });

                  if (_selectedCard != null) {
                    await ref
                        .read(dashboardProvider.notifier)
                        .loadDashboardDetails(
                          rmCode: StaticVariables.mSAPCode.toUpperCase(),
                          month: currentMonthParam,
                          status: _selectedCard!.title,
                          leadType: newValue,
                        );
                  }
                },
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF17479e),
            fontWeight: .bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCardItem(String title, String Value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF17479e),
            fontWeight: .bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(Value, style: const TextStyle(fontSize: 14, fontWeight: .bold)),
      ],
    );
  }

  Widget _buildIcon() {
    return InkWell(
      onTap: () {
        _onFilterClick();
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF17479e),
              fontWeight: .bold,
            ),
          ),
          Image.asset(
            'assets/filter_round.png',
            height: 25, // Set size to match your previous Icon size
            width: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildIconhorizontal(String flag) {
    String assetPath;
    String displayText;

    if (flag == "refresh") {
      assetPath = 'assets/icons_refresh.png';
      displayText = "Refresh Dashboard";
    } else if (flag == "status") {
      assetPath = 'assets/dashboard_status.png';
      displayText = "Status";
    } else {
      assetPath = 'assets/default_icon.png';
      displayText = "More Info";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 2. Use Image.asset instead of Icon
        Image.asset(
          assetPath,
          height: 25, // Set size to match your previous Icon size
          width: 25,
          errorBuilder: (context, error, stackTrace) {
            // Fallback in case the image is missing from assets
            return const Icon(Icons.error, color: Colors.red);
          },
        ),
        const SizedBox(width: 10),
        Text(
          displayText,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF17479e),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(CardData data) {
    return Card(
      elevation: 0,
      color: Color(0xFF17479e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: .w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              data.percentage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: .bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomMetric(data.nop, "NOP"),
                SizedBox(
                  height: 30, // controls line height
                  child: VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                    width: 12,
                  ),
                ),
                _buildBottomMetric(data.gwp, "GWP"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: .bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      ],
    );
  }

  Widget _buildGrid(DashboardSummary summary) {
    print("BUILD GRID CALLED");
    final List<CardData> grid = [
      CardData(
        title: "Converted",
        percentage: "${summary.convertedPercentage.toStringAsFixed(2)}%",
        nop: summary.convertedCount.toString(),
        gwp: CommonUtil.getValueInLakh(summary.convertedAmount),
      ),
      CardData(
        title: "Lost",
        percentage: "${summary.lostPercentage.toStringAsFixed(2)}%",
        nop: summary.lostCount.toString(),
        //gwp: summary.lostAmount.toString(),
        gwp: CommonUtil.getValueInLakh(summary.lostAmount),
      ),
      CardData(
        title: "Open",
        percentage: "${summary.openPercentage.toStringAsFixed(2)}%",
        nop: summary.openCount.toString(),
        gwp: CommonUtil.getValueInLakh(summary.openAmount),
      ),
      CardData(
        title: "Sale Closed",
        percentage: "${summary.salesClosedPercentage.toStringAsFixed(2)}%",
        nop: summary.salesCloseCount.toString(),
        //gwp: summary.salesCloseAmount.toString(),
        gwp: CommonUtil.getValueInLakh(summary.salesCloseAmount),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grid.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final card = grid[index];
        print("GRID ITEM BUILDING: ${card.title}");

        return GestureDetector(
          // onTap: () async {
          //   setState(() {
          //     _selectedCard = card;
          //   });
          // },
          onTap: () async {
            setState(() {
              _selectedCard = card;
              _isGridFilterApplied = false;
              _gridFilteredList.clear();
            });

            final selectedLeadType = ref.read(dashboardLeadTypeProvider);

            await ref
                .read(dashboardProvider.notifier)
                .loadDashboardActivityDetails(
                  rmCode: StaticVariables.mSAPCode.toUpperCase(),
                  month: currentMonthParam,
                  activityCode: getActivityCodeFromStatus(card.title),
                  subActivityCode: "",
                  statusFlag: getFlagFromStatus(card.title),
                  leadType: selectedLeadType,
                );
          },

          child: _buildCard(card),
        );
      },
    );
  }

  // void _refreshData() async {
  //   // ScaffoldMessenger.of(context).showSnackBar(
  //   //   const SnackBar(
  //   //     content: Text("Refreshing data..."),
  //   //     duration: Duration(seconds: 2),
  //   //   ),
  //   // );
  //   if (!mounted) return;

  //   Fluttertoast.showToast(
  //     msg: "Refreshing dashboard...",
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.SNACKBAR,
  //   );
  //     await _callDashboardData(forceRefresh: true);

  // }

  Future<void> _refreshData() async {
    if (!mounted) return;

    Fluttertoast.showToast(
      msg: "Refreshing dashboard...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
    );

    await _callDashboardData(forceRefresh: true);
  }

  void _onFilterClick() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterActivity()),
    );
  }
}

class CardData {
  final String title;
  final String percentage;
  final String nop;
  final String gwp;

  CardData({
    required this.title,
    required this.percentage,
    required this.nop,
    required this.gwp,
  });
}
