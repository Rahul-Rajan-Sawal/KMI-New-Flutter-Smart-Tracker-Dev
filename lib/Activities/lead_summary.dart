import 'package:flutter/material.dart';

class LeadSummary extends StatefulWidget {
  final Map<String, dynamic> lead;
  final Map<String,dynamic>leadSummary;


  const LeadSummary({Key? key, required this.lead, required this.leadSummary}) : super(key: key);

  @override
  State<LeadSummary> createState() => _LeadSummaryState();
}

class _LeadSummaryState extends State<LeadSummary> {
late String name;
late String custType;
late String mobileTel;
late String custPriority;
late String lob;
late String product;
late String leadType;
late String saleType;
late String policyNumber;
late String leadAmount;

late String leadChannel;
late String leadSource;
late String leadSubsource;
late String leadAging;
late String businessType;
late String leadRating;
late String breaking;
late String prevPolicyNo;
late String webQuotes;

late String isOwner;
late String ownerName;

late String assignedTo;
late String assignedToName;

late String leadOwner;
late String leadAssignedTo;


  @override
  void initState() {
    super.initState();

  String safeValue(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    return "Not Available";
  }
    return value.toString();
  }
  name = safeValue(widget.lead["Name"]);
 custType = safeValue(widget.leadSummary["CustTypeDesc"]);
mobileTel = safeValue(widget.leadSummary["MobileTel"]);
custPriority = safeValue(widget.leadSummary["CustPriorityDesc"]);
lob = safeValue(widget.leadSummary["LOB"]);
product = safeValue(widget.leadSummary["ProdName"]);
leadType = safeValue(widget.leadSummary["LeadTypeDesc"]);
saleType = safeValue(widget.leadSummary["SaleTypeDesc"]);
policyNumber = safeValue(widget.leadSummary["PolicyNo"]);
leadAmount = safeValue(widget.leadSummary["InstallmentPrem"]);
  //lead owner
  isOwner = safeValue(widget.leadSummary["isOwner"]);
  ownerName = safeValue(widget.leadSummary["OwnerName"]);
  leadOwner = (isOwner == "Not Available" && ownerName == "Not Available")
    ? "Not Available"
    : "$isOwner ($ownerName)";

//lead assign to
 assignedTo = safeValue(widget.leadSummary["AssignedTo"]);
  assignedToName = safeValue(widget.leadSummary["AssignedToName"]);

leadAssignedTo = (assignedTo == "Not Available" && assignedToName == "Not Available")
    ? "Not Available"
    : "$assignedTo ($assignedToName)";
 
 leadChannel = safeValue(widget.leadSummary["ReqChannel"]);
leadSource = safeValue(widget.leadSummary["LeadSourceDesc"]);
leadSubsource = safeValue(widget.leadSummary["LeadSubSourceDesc"]);
leadAging = safeValue(widget.leadSummary["LeadAging"]);

businessType = safeValue(widget.leadSummary["BusinessTypeDesc"]);
leadRating = safeValue(widget.leadSummary["LeadRating"]);
breaking = safeValue(widget.leadSummary["Breaking"]);

prevPolicyNo = safeValue(widget.leadSummary["txt_prev_policy_no"]);
webQuotes = safeValue(widget.leadSummary["txt_web_quetes"]);
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
        title: const Text("Leads Summary"),
        elevation: 0,
         backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
         flexibleSpace: Container
         (
         decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF090979), 
            Color(0xFF00D4FF),                 
            ],
            ),
          ),
         ),
      ),





      body:SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children:[
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height:50),
                                    const Text(
                                      "Customer Detail",
                                      style: TextStyle(
                                        color: Color(0xFF17479E),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                   
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Text(
                                          "Customer Name",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                     Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Text(
                                          ":$name",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF17479E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(
                                                0, 8, 0, 5),
                                        child: Text(
                                          "Customer Type",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                     Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(
                                                0, 8, 0, 5),
                                        child: Text(
                                          ": $custType",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF17479E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Customer Contact Number",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,15),
                                      child:Text(
                                        ": $mobileTel",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,15),
                                        child:Text(
                                          "Customer Priority",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,15),
                                      child:Text(
                                        ": $custPriority",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                                ),                            
                              ],
                            ),
                          ),
            ),
            const SizedBox(height: 16),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height:50),
                                    const Text(
                                      "Product Lead Detail",
                                      style: TextStyle(
                                        color: Color(0xFF17479E),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                   
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Text(
                                          "Line of Business",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                     Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Text(
                                          ": $lob",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF17479E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(
                                                0, 8, 0, 5),
                                        child: Text(
                                          "Product",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                     Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(
                                                0, 8, 0, 5),
                                        child: Text(
                                          ": $product",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF17479E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Type",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $leadType",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Sale Type",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": Not Available",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                                ),

                              Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Policy Number",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $policyNumber",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),

                            Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Amount",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $leadAmount",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),

                              Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Owner",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $leadOwner",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),

                            Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Assigned To",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $leadAssignedTo",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),
                            Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Channel",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $leadChannel",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),
                            Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Source",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $leadSource",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),
                            Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Sub Source",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $leadSubsource",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),
                            Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Lead Aging",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ":$leadAging",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),


                              ],
                            ),
                          ),
            ),
            const SizedBox(height: 16),


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
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height:50),
                                    const Text(
                                      "Other Details",
                                      style: TextStyle(
                                        color: Color(0xFF17479E),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                   
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Text(
                                          "Business Type",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                     Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                                vertical: 5),
                                        child: Text(
                                          ": $businessType",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF17479E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(
                                                0, 8, 0, 5),
                                        child: Text(
                                          "Lead Rating",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      
                                    ),
                                     Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(
                                                0, 8, 0, 5),
                                        child: Text(
                                          ": $leadRating",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF17479E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Breaking",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $breaking",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Previous policy Number",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $prevPolicyNo",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                                ),

                              Row(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children:[
                                    const SizedBox (
                                      width:150,
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(0,8,0,5),
                                        child:Text(
                                          "Website Quotes",
                                          style:TextStyle(
                                            fontSize:15,
                                          fontWeight:FontWeight.w600,
                                          color:Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),

                                     Expanded(
                                      child:Padding(padding:EdgeInsets.fromLTRB(0,8,0,5),
                                      child:Text(
                                        ": $webQuotes",
                                        style:TextStyle(
                                          fontSize:15,
                                        fontWeight:FontWeight.w600,
                                        color:Color(0xFF17479E),
                                        )
                                      ),
                                      )
                                    )
                                  ],
                            ),
                          
                              ],
                            ),
                          ),
            ),
            const SizedBox(height: 16),
          ],
        )
      )
    );
  }
}
