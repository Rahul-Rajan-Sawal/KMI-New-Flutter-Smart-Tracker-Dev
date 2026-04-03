import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/filter_activity.dart';
import 'package:flutter_bottom_nav/Activities/login_activity.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/common/encryption_util.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/database/database_helper.dart';
import 'package:flutter_bottom_nav/models/dashboard_provider.dart';
import 'package:flutter_bottom_nav/models/dashboard_summary_model.dart';
import 'package:flutter_bottom_nav/models/filter_provider.dart';
import 'package:flutter_bottom_nav/models/open_card_model.dart';
import 'package:flutter_bottom_nav/models/route_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with RouteAware {
  int? _expandedCardIndex;
  CardData? _selectedCard;
  String _currentDate = "Loading...";
  String _currentTiming = "Loading...";
  String _nop = "...";
  String _gwp = "...";
  int _selectedType = 1; // default selection
  String _dashboardDate = "Not Available";
  String _dashboardTime = "NA";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _printPath();
    _fetchData();
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

  Future<void> _handleDashboardLogic() async {
    final dashboardType = getDashboardType();
    bool isDashboardListFilter = false;
    final isFilter = isDashboardListFilter;

    if (dashboardType.toLowerCase() == "team" && !isFilter) {
      final db = await DatabaseHelper.instance.database;

      final result = await db.query(
        'Tbl_TeamDashboardData_Mob',
        where: 'RMCode = ?',
        whereArgs: [StaticVariables.mSAPCode.toUpperCase()],
      );

      if (result.isNotEmpty) {
        print("Data available in DB → Fetch from table");
        // _prepareTeamDashboard(); // we will write later
      } else {
        print("No data → Call API");
        _callDashboardData(false); // we will write later
      }
    } else if (dashboardType.toLowerCase() == "self" && !isFilter) {
      _callDashboardData(false);
    } else {
      isDashboardListFilter = false;
    }
  }

  Future<void> _callDashboardData(bool isFromFilter) async {
    await ref
        .read(dashboardProvider.notifier)
        .loadDashboard(
          rmCode: "70782643", // replace with actual login SAP code
          month: "2026-03-01", // current month
        );
  }

  String getDashboardType() {
    // if (mDashboardType != null && mDashboardType.trim().length() > 0 && (mDashboardType.trim().equalsIgnoreCase("Team") ||
    //         mDashboardType.trim().equalsIgnoreCase("Self"))) {
    //     return mDashboardType;
    // } else if (mDashboardType == null || mDashboardType.trim().length() <= 0 || (!mDashboardType.trim().equalsIgnoreCase("Team") &&
    //         !mDashboardType.trim().equalsIgnoreCase("Self"))) {
    //     if (img_selfDashboardSelect.getVisibility() == View.VISIBLE) {
    //         return "Self";
    //     } else if (img_teamDashboardSelect.getVisibility() == View.VISIBLE) {
    //         return "Team";
    //     } else {
    //         return mDashboardType;
    //     }
    // } else {
    //     return mDashboardType;
    // }
    return "self";
  }

  void _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _currentDate = "20-01-2025";
      _currentTiming = "04:33 AM";
      _nop = "12";
      _gwp = "24.20";
    });
  }

  void _printPath() async {
    final dbPath = await getDatabasesPath();
    final extDir = await getExternalStorageDirectory();

    print(dbPath);
    print(extDir?.path);
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
    final filterState = ref.watch(filterProvider);
    final dashboardState = ref.watch(dashboardProvider);
    print("==== DASHBOARD FILTER CHECK ====");
    print("Period: ${filterState.period}");
    print("Branch: ${filterState.branch}");
    print("Zones: ${filterState.zones}");
    print("Regions: ${filterState.regions}");

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, stack) => Center(child: Text('Error: $err')),

        data: (summary) {
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
                  _buildExpandedSection(),
                ],

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedSection() {
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
                  _selectedCard!.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479e),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn("NOP", _selectedCard!.nop.toString()),
                    _buildStatColumn(
                      "GWP(in Lacs)",
                      _selectedCard!.gwp.toString(),
                    ),
                    _buildStatColumn(
                      "Percentage",
                      _selectedCard!.percentage.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// Mini Cards
        Row(
          children: [
            Expanded(child: _buildMiniCard("Parked", "45")),
            const SizedBox(width: 12),
            Expanded(child: _buildMiniCard("Follow Up", "12")),
          ],
        ),

        /// 👇 Show Recycler Grid ONLY when Open clicked
        if (_selectedCard!.title == "Open") ...[
          const SizedBox(height: 16),
          _buildRecyclerGrid(),
        ],
      ],
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

  Widget _buildRecyclerGrid() {
    final List<OpenItem> openList = [
      OpenItem(
        leadNo: "LD001",
        policyNo: "POL12345",
        product: "Motor",
        premium: "₹12,500",
      ),
      OpenItem(
        leadNo: "LD002",
        policyNo: "POL56789",
        product: "Health",
        premium: "₹18,300",
      ),
      OpenItem(
        leadNo: "LD003",
        policyNo: "POL99999",
        product: "Life",
        premium: "₹25,000",
      ),
      OpenItem(
        leadNo: "LD004",
        policyNo: "POL12345",
        product: "Motor",
        premium: "₹12,500",
      ),
      OpenItem(
        leadNo: "LD005",
        policyNo: "POL56789",
        product: "Health",
        premium: "₹18,300",
      ),
      OpenItem(
        leadNo: "LD006",
        policyNo: "POL99999",
        product: "Life",
        premium: "₹25,000",
      ),
      OpenItem(
        leadNo: "LD007",
        policyNo: "POL12345",
        product: "Motor",
        premium: "₹12,500",
      ),
      OpenItem(
        leadNo: "LD008",
        policyNo: "POL56789",
        product: "Health",
        premium: "₹18,300",
      ),
      OpenItem(
        leadNo: "LD009",
        policyNo: "POL99999",
        product: "Life",
        premium: "₹25,000",
      ),
    ];

    return Column(
      children: [
        /// =========================
        /// HEADER ROW (Clickable)
        /// =========================
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              _buildHeaderCell("Lead No"),
              _buildHeaderCell("Policy No"),
              _buildHeaderCell("Product"),
              _buildHeaderCell("Premium"),
            ],
          ),
        ),

        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: openList.length,
          itemBuilder: (context, index) {
            final item = openList[index];

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  _buildDataCell(item.leadNo),
                  _buildDataCell(item.policyNo),
                  _buildDataCell(item.product),
                  _buildDataCell(item.premium),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

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

  Widget _buildTopCard() {
    return Card(
      color: Color(0xFFE9E9E9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCardItem("Showing Date", _currentDate),
            _buildCardItem("Timing", _currentTiming),
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
        onTap: () {
          _refreshData();
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
                      "March 2026",
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

  Widget _buildRadioItem(String title, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Keep row tight
      children: [
        SizedBox(
          height: 30, // Reduces vertical space
          width: 30, // Reduces horizontal space
          child: Radio<int>(
            value: value,
            groupValue: _selectedType,
            onChanged: (int? newValue) {
              setState(() {
                _selectedType = newValue!;
              });
            },
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
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
        gwp: summary.lostAmount.toString(),
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
        gwp: summary.salesCloseAmount.toString(),
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

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCard = card;
            });
          },
          child: _buildCard(card),
        );
      },
    );
  }

  void _refreshData() {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text("Refreshing data..."),
    //     duration: Duration(seconds: 2),
    //   ),
    // );
    if (!mounted) return;

    Fluttertoast.showToast(
      msg: "Refreshing data...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
    );
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
