import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/lead_summary.dart';
import 'package:flutter_bottom_nav/Activities/lead_update_activity.dart';
import 'package:flutter_bottom_nav/Activities/view_details.dart';
import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/repository/leaddetails_repository.dart';

class SearchedLead extends StatefulWidget {
  final List<Map<String, dynamic>> leadList;

  const SearchedLead({Key? key, required this.leadList}) : super(key: key);

  @override
  State<SearchedLead> createState() => _SearchedLeadState();
}

class TimeLogger {
  static void log(String msg) {
    final now = DateTime.now();
    debugPrint("${now.toIso8601String()} → $msg");
  }
}

class _SearchedLeadState extends State<SearchedLead> {
  @override
void initState() {
  super.initState();
  TimeLogger.log("RecyclerView INIT START");
}
  @override
  Widget build(BuildContext context) {

     WidgetsBinding.instance.addPostFrameCallback((_) {
    TimeLogger.log("📱 RecyclerView RENDER END");
  });

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


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
      body: widget.leadList.isEmpty
          ? const Center(child: Text("No records found"))
          : ListView.builder(
              itemCount: widget.leadList.length,
              itemBuilder: (context, index) {
                final lead = widget.leadList[index];
                // Print raw DB values
//                print("Raw Lead: $lead");
              
                final name = lead['Name'] ?? '';
                final prodName = lead['ProdName'] ?? '';
                final leadId = lead['SrvcReqDtlCode'] ?? '';
                final leadAmt = lead['leadAmt'] ?? '';

  //              print("Decrypted names found : " + name);
  //              print("Decrypted Product Name Found : " + prodName);
  //              print("Decrypted Product leadId Found : " + leadId);
  //              print("Decrypted Product Lead Amount Found : " + leadAmt);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF090979), Color(0xFF00D4FF)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --------- Name Row ---------
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // --------- Row: Policy Name + Lead Info ---------
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Column 1 → Policy Name
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    prodName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                //const SizedBox(width: 10),

                                // Column 2 → Label + Value Columns
                                Container(
                                  //flex: 2,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // LABEL COLUMN
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            "Lead ID",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Lead Amount",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(width: 12),

                                      // VALUE COLUMN
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leadId,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "₹${leadAmt}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.09,
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.post_add,
                                    color: Colors.grey[700],
                                    size: 30,
                                  ),
                                  onPressed: () => _onUpdateActivity(lead),
                                ),
                                const Text(
                                  "Update Activity",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.article,
                                    color: Colors.grey[700],
                                    size: 30,
                                  ),
                                  onPressed: () => _onViewSummary(lead),
                                ),
                                const Text(
                                  "View Summary",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.grey[700],
                                    size: 30,
                                  ),
                                  onPressed: () => _onViewDetails(lead),
                                ),
                                const Text(
                                  "View Details",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _onUpdateActivity(Map<String, dynamic> lead) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeadUpdate(lead: lead)),
    );
    print("Update Activity clicked for ${lead['leadId']}");
  }

_onViewSummary(Map<String, dynamic> lead) async {
  try {

    String leadId = lead["SrvcReqDtlCode"];

    final leadSummary =
        await LeadDetailsRepository.fetchLeadDetailsById(
      leadId,
      columnsToDecrypt: [
        "CustTypeDesc",
        "MobileTel",
        "CustPriorityDesc",
        "LOB",
        "ProdName",
        "LeadTypeDesc",
        "SaleTypeDesc",
        "PolicyNo",
        "InstallmentPrem",
        "ReqChannel",
        "LeadSourceDesc",
        "LeadSubSourceDesc",
        "LeadAging",
        "BusinessTypeDesc",
        "LeadRating",
        "Breaking",
        "txt_prev_policy_no",
        "txt_web_quetes",
        "isOwner",
        "OwnerName",
        "AssignedTo",
        "AssignedToName"
      ],
    );

    if (leadSummary == null) {
      print("No summary found for LeadId: $leadId");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeadSummary(
          lead: lead,
          leadSummary: leadSummary,
        ),
      ),
    );

  } catch (e, stack) {

    print("ERROR in _onViewSummary: $e");
    print(stack);

  }
}
 Future<void> _onViewDetails(Map<String, dynamic> lead) async {

  String leadId = lead["SrvcReqDtlCode"];

  final leadDetails =
      await LeadDetailsRepository.fetchLeadDetailsById(
    leadId,
    columnsToDecrypt: [
      "LeadType",
      "ActivityStatus",
      "ProdName",
      "MobileTel",
      "Email",
      "PolicyNo",
      "InstallmentPrem",
      "PolicyStartDate",
      "PolicyEndDate",
      "RegistrationNo",
      "Make",
      "Model",
      "PolNCB",
      "TelesaleActivity",
      "TelesaleActivityDoneBy",
      "TelesaleActivityDate",
      "TelesaleRemark",
      "WFStatus",
      "WFStatDesc",
      "FuelType",
      "VehicleType"
    ],
  );

  // Debug print
  print("Fetched Lead Details for $leadId: $leadDetails");

  // Null safety check
  if (leadDetails == null) {
    print("No lead details found for $leadId");
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewDetails(
        lead: lead,
        decryptedLead: leadDetails,
      ),
    ),
  );
}
// _onViewDetails(Map<String, dynamic> lead) async {

//   String leadId = lead["SrvcReqDtlCode"];

//   final leadDetails =
//       await LeadDetailsRepository.fetchLeadDetailsById(
//     leadId,
//     columnsToDecrypt: [
//       "LeadType",
//       "ActivityStatus",
//       "ProdName",
//       "MobileTel",
//       "Email",
//       "PolicyNo",
//       "InstallmentPrem",
//       "PolicyStartDate",
//       "PolicyEndDate",
//       "RegistrationNo",
//       "Make",
//       "Model",
//       "PolNCB",
//       "TelesaleActivity",
//       "TelesaleActivityDoneBy",
//       "TelesaleActivityDate",
//       "TelesaleRemark",
//       "WFStatus",
//       "WFStatDesc",
//       "FuelType",
//       "VehicleType"
//     ],
//   );
// try{
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => ViewDetails(
//         lead: lead,
//         decryptedLead: leadDetails!,
//       ),
//     ),
//   );
//   }catch(e){}
// }
}