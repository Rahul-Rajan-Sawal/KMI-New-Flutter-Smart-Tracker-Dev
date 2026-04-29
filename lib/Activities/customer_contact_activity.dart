// ✅ FILE: lib/Activities/customer_contact_screen.dart
// 🔹 Minimal fix: Just pass customerData to next screen (no DB upsert changes)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/activity_add_contact.dart';
import 'package:flutter_bottom_nav/core/apicall/async_search_customer_contact.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

// ✅ Keep your original constant (for future use if needed)
const String TBL_CUSTOMER_CNT_DTLS = 'TBL_CUSTOMER_CNT_DTLS';

class CustomerContactScreen extends StatefulWidget {
  @override
  _CustomerContactScreenState createState() => _CustomerContactScreenState();
}

class _CustomerContactScreenState extends State<CustomerContactScreen> {
  final TextEditingController leadController = TextEditingController();
  final TextEditingController policyController = TextEditingController();

  bool isLoading = false;
  bool showNoData = false;

  // ✅ Keep your original type: List<dynamic> (works fine!)
  List<dynamic> customerData = [];

  @override
  void dispose() {
    leadController.dispose();
    policyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Customer Contact"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Lead ID
                TextField(
                  controller: leadController,
                  decoration: const InputDecoration(
                    labelText: "Lead ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                /// Policy No
                TextField(
                  controller: policyController,
                  decoration: const InputDecoration(
                    labelText: "Policy Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          leadController.clear();
                          policyController.clear();
                          setState(() {
                            customerData.clear();
                            showNoData = false;
                          });
                        },
                        child: const Text("Clear"),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSearch,
                        child: const Text("Search"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// ✅ SINGLE CARD - Your original logic preserved!
                if (customerData.isNotEmpty) buildCustomerCard(customerData[0]),

                /// ❌ NO DATA
                if (showNoData)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        "No record found",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          /// LOADER
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  /// ✅ MAIN SEARCH LOGIC - Your original API-only flow (no DB changes)
  Future<void> _handleSearch() async {
    final leadId = leadController.text.trim();
    final policyNo = policyController.text.trim();

    // ✅ Validate - at least one field required
    if (leadId.isEmpty && policyNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter either Lead ID or Policy Number."),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
        showNoData = false;
        customerData.clear();
      });

      final response = await searchCustomerContact(
        sapCode: StaticVariables.mSAPCode,
        leadNo: leadId,
        policyNo: policyNo,
      );

      print("API RESPONSE MAP: $response");

      final responseBody = response["response"];
      final decoded = jsonDecode(responseBody);

      print("DECODED JSON: $decoded");

      final List<dynamic> table = decoded["Table"] ?? [];

      if (table.isNotEmpty) {
        final firstItem = table[0];

        // ✅ SAME AS ANDROID - check first row ResponseCode only
        bool isError =
            firstItem.containsKey("ResponseCode") &&
            (firstItem["ResponseCode"].toString() == "1" ||
                firstItem["ResponseCode"].toString() == "2");

        if (isError) {
          setState(() {
            showNoData = true;
            customerData.clear();
          });
          return;
        }

        // ✅ Filter rows to match exactly what user typed (your original logic)
        final List<dynamic> validRows = table.where((item) {
          final record = item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item);

          String srvcReqDtlCode = (record["SrvcReqDtlCode"] ?? "")
              .toString()
              .trim();
          String policyNoFromApi = (record["PolicyNo"] ?? "").toString().trim();
          String custName = (record["Cust_Name"] ?? "")
              .toString()
              .trim()
              .toUpperCase();

          // ✅ Skip rows with invalid/placeholder name
          if (custName.isEmpty ||
              custName.contains("NAME NOT AVAILABLE") ||
              custName == "NULL") {
            if (policyNo.isNotEmpty &&
                policyNoFromApi.toLowerCase() == policyNo.toLowerCase()) {
              return true;
            }
            if (leadId.isNotEmpty &&
                srvcReqDtlCode.toLowerCase() == leadId.toLowerCase()) {
              return true;
            }
            return false;
          }

          // ✅ If leadId entered, must match SrvcReqDtlCode exactly
          if (leadId.isNotEmpty &&
              srvcReqDtlCode.toLowerCase() != leadId.toLowerCase()) {
            return false;
          }

          // ✅ If policyNo entered, must match PolicyNo exactly
          if (policyNo.isNotEmpty &&
              policyNoFromApi.toLowerCase() != policyNo.toLowerCase()) {
            return false;
          }

          return true;
        }).toList();

        if (validRows.isNotEmpty) {
          setState(() {
            customerData = validRows; // ✅ Keep as List<dynamic>
            showNoData = false;
          });
        } else {
          setState(() {
            showNoData = true;
            customerData.clear();
          });
        }
      } else {
        setState(() {
          showNoData = true;
          customerData.clear();
        });
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        showNoData = true;
        customerData.clear();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// ✅ CARD UI - Your original logic preserved!
  Widget buildCustomerCard(Map<String, dynamic> data) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          /// Green top indicator
          Container(
            height: 6,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                /// Name + Lead Code - Your original field access
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data["Cust_Name"] ??
                            "Not Available", // ✅ Direct from data map
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data["SrvcReqDtlCode"]?.toString() ?? "",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                /// Product & Premium
                Row(
                  children: [
                    _col("PRODUCT", data["ProdCode"]),
                    _col("PREMIUM", data["PremiumAmt"], right: true),
                  ],
                ),
                const SizedBox(height: 10),

                /// Policy & Period
                Row(
                  children: [
                    _col("POLICY", data["PolicyNo"]),
                    _col(
                      "PERIOD",
                      _formatPolicyPeriod(
                        data["PolicyStartDate"],
                        data["PolicyEndDate"],
                      ),
                      right: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                /// Mobile & Email - Your original masking
                Row(
                  children: [
                    _col("MOBILE", maskMobile(data["MobileNo"])),
                    _col("EMAIL", maskEmail(data["Email"]), right: true),
                  ],
                ),
              ],
            ),
          ),

          /// 🔥 ADD CONTACT Button - ✅ THE FIX: Pass customerData (not empty list!)
          GestureDetector(
            onTap: () {
              if (customerData.isEmpty) return;
              final formattedList = customerData.map((item) {
                return {
                  "mobile": item["MobileNo"]?.toString() ?? "",
                  "email": item["Email"]?.toString() ?? "",
                  "isPrimaryMobile": item["IsPrimary"]?.toString() ?? "N",
                  "isPrimaryEmail": item["IsEmailPrimary"]?.toString() ?? "N",
                  "contactType":
                      (item["IsPrimary"] == "Y" ||
                          item["IsEmailPrimary"] == "Y")
                      ? "Primary"
                      : "Alternate",

                  // keep original fields also (important)
                  "SrvcReqDtlCode": item["SrvcReqDtlCode"],
                  "PolicyNo": item["PolicyNo"],
                  "CustName": item["Cust_Name"],
                };
              }).toList();

              print("🚀 Sending list to next screen:");
              print(formattedList);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCustomerContactScreen(
                    contactList: formattedList, // ✅ FULL LIST
                  ),
                ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => AddCustomerContactScreen(
              //       contactList: customerData
              //           .cast<Map<String, dynamic>>(), // ✅ THE FIX!
              //     ),
              //   ),
              // );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Center(
                child: Text(
                  "ADD CONTACT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Column widget - Your original
  Widget _col(String title, dynamic value, {bool right = false}) {
    String displayValue =
        (value == null ||
            value.toString().trim().isEmpty ||
            value.toString().trim().toLowerCase() == "null")
        ? "Not Available"
        : value.toString().trim();

    return Expanded(
      child: Column(
        crossAxisAlignment: right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Mask mobile - Your original
  String maskMobile(dynamic number) {
    if (number == null ||
        number.toString().trim().isEmpty ||
        number.toString().trim().toLowerCase() == "null") {
      return "Not Available";
    }
    String num = number.toString().trim();
    return num.length >= 4 ? "XXXXXX${num.substring(num.length - 4)}" : num;
  }

  /// ✅ Mask email - Your original
  String maskEmail(dynamic email) {
    if (email == null ||
        email.toString().trim().isEmpty ||
        email.toString().trim().toLowerCase() == "null") {
      return "Not Available";
    }
    String e = email.toString().trim();
    int at = e.indexOf("@");
    if (at <= 2) return e;
    return "${e.substring(0, 2)}****${e.substring(at)}";
  }

  /// ✅ Format policy period - Your original (with bug fix)
  String _formatPolicyPeriod(dynamic startDate, dynamic endDate) {
    String start =
        (startDate == null ||
            startDate.toString().trim().isEmpty ||
            startDate.toString().trim().toLowerCase() == "null")
        ? "Not Available"
        : startDate.toString().replaceAll("00:00:00.000", "").trim();

    // ✅ BUG FIX: Use endDate (not startDate twice like Android)
    String end =
        (endDate == null ||
            endDate.toString().trim().isEmpty ||
            endDate.toString().trim().toLowerCase() == "null")
        ? "Not Available"
        : endDate.toString().replaceAll("00:00:00.000", "").trim();

    if (start == "Not Available" && end == "Not Available") {
      return "Not Available";
    }
    return "$start To $end";
  }
}
