// ✅ FILE: lib/Activities/activity_add_contact.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/common/common_confirmation_popup.dart';
import 'package:flutter_bottom_nav/common/common_primary_popup.dart';
import 'package:flutter_bottom_nav/core/apicall/async_mark_primary_contact.dart';
import 'package:flutter_bottom_nav/core/apicall/async_submit_customer_contact.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class AddCustomerContactScreen extends StatefulWidget {
  final List<Map<String, dynamic>> contactList;

  // ✅ Optional context params from previous screen
  final String? leadId;
  final String? policyNo;
  final String? custName;
  final String? srvcReqDtlCode;

  const AddCustomerContactScreen({
    Key? key,
    required this.contactList,
    this.leadId,
    this.policyNo,
    this.custName,
    this.srvcReqDtlCode,
  }) : super(key: key);

  @override
  _AddCustomerContactScreenState createState() =>
      _AddCustomerContactScreenState();
}

class _AddCustomerContactScreenState extends State<AddCustomerContactScreen> {
  // 🔹 UI State
  bool isPrimaryMobile = false;
  bool isPrimaryEmail = false;
  bool isSubmitting = false;

  // 🔹 Controllers
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // 🔹 Data
  late List<Map<String, dynamic>> contactList;

  // 🔹 Customer Context Variables (matching Android)
  String iLeadId = "";
  String iPolicyNo = "";
  String iCustName = "";
  String iSrvcReqDtlCode = "";

  @override
  void initState() {
    super.initState();

    // ✅ Initialize contact list (safe copy)
    contactList = List<Map<String, dynamic>>.from(widget.contactList);

    print("👉 widget.leadId: ${widget.leadId}");
    print("👉 widget.policyNo: ${widget.policyNo}");
    print("👉 widget.custName: ${widget.custName}");
    print("👉 widget.srvcReqDtlCode: ${widget.srvcReqDtlCode}");

    // ✅ Extract customer fields from first contact or widget params
    _extractCustomerContext();

    print("👤 Customer: $iCustName");
    print("🔖 Lead: $iLeadId, Policy: $iPolicyNo");
    print("📋 Contacts loaded: ${contactList.length}");
  }

  @override
  void dispose() {
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // 🔹 HELPER: Extract Customer Context
  // ─────────────────────────────────────────────

  void _extractCustomerContext() {
    if (contactList.isNotEmpty) {
      final first = contactList[0];

      // ✅ Map from DB/API fields → UI variables (flexible fallback)
      iSrvcReqDtlCode =
          first['SrvcReqDtlCode']?.toString() ??
          first['LEAD_NO']?.toString() ??
          widget.leadId ??
          "";
      iPolicyNo =
          first['PolicyNo']?.toString() ??
          first['POLICY_NO']?.toString() ??
          widget.policyNo ??
          "";
      iCustName =
          first['CustName']?.toString() ??
          first['Cust_Name']?.toString() ??
          widget.custName ??
          "";
      iLeadId = iSrvcReqDtlCode; // Alias for consistency
    } else {
      // Fallback to widget params if contactList is empty
      iSrvcReqDtlCode = widget.leadId ?? widget.srvcReqDtlCode ?? "";
      iPolicyNo = widget.policyNo ?? "";
      iCustName = widget.custName ?? "";
      iLeadId = iSrvcReqDtlCode;
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 HELPER: Safe Display Value
  // ─────────────────────────────────────────────

  String _safeDisplayValue(String value) {
    if (value.isEmpty ||
        value.toLowerCase() == 'not available' ||
        value.toLowerCase() == 'null' ||
        value.toLowerCase() == 'n/a') {
      return "Not Available";
    }
    return value;
  }

  // ─────────────────────────────────────────────
  // 🔹 HELPER: Badge Color
  // ─────────────────────────────────────────────

  Color _getBadgeColor(String type) =>
      (type == "Default" || type == "Primary") ? Colors.blue : Colors.grey;

  // ─────────────────────────────────────────────
  // 🔹 ADD CONTACT (Local UI Only)
  // ─────────────────────────────────────────────

  void _addContact() {
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();

    if (mobile.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter Mobile or Email")));
      return;
    }

    setState(() {
      // ✅ Clear previous primary flags if new one is selected
      if (isPrimaryMobile || isPrimaryEmail) {
        for (var c in contactList) {
          if (isPrimaryMobile) c['isPrimaryMobile'] = "N";
          if (isPrimaryEmail) c['isPrimaryEmail'] = "N";
          // Update badge type if both are now N
          if (c['isPrimaryMobile'] == "N" && c['isPrimaryEmail'] == "N") {
            c['contactType'] = "Alternate";
          }
        }
      }

      // ✅ Add new contact to local list
      contactList.add({
        "mobile": mobile,
        "email": email,
        "isPrimaryMobile": isPrimaryMobile ? "Y" : "N",
        "isPrimaryEmail": isPrimaryEmail ? "Y" : "N",
        "contactType": (isPrimaryMobile || isPrimaryEmail)
            ? "Primary"
            : "Alternate",
        // ✅ Keep original fields for reference/API
        "SrvcReqDtlCode": iSrvcReqDtlCode,
        "PolicyNo": iPolicyNo,
        "CustName": iCustName,
      });

      // ✅ Clear form
      mobileController.clear();
      emailController.clear();
      isPrimaryMobile = false;
      isPrimaryEmail = false;
    });
  }

  // ─────────────────────────────────────────────
  // 🔹 MARK PRIMARY CONTACT (Badge Click)
  // ─────────────────────────────────────────────

  void _onBadgeClicked(int index) {
    if (index < 0 || index >= contactList.length) return;

    final c = contactList[index];
    final type = c['contactType']?.toString() ?? 'Alternate';
    final mobile = c['mobile']?.toString()?.trim() ?? '';
    final email = c['email']?.toString()?.trim() ?? '';

    final safeMobile = _safeDisplayValue(mobile);
    final safeEmail = _safeDisplayValue(email);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CommonConfirmationPopup(
        title: "Confirmation",
        message:
            "Are you sure, You want to make \n selected contact as Primary Contact",
        mobileNumber: safeMobile,
        emailId: safeEmail,
        onConfirm: (bool isMobileSelected, bool isEmailSelected) async {
          final selectedContact = contactList[index];
          final contactMobile = selectedContact['mobile']?.toString() ?? "";
          final contactEmail = selectedContact['email']?.toString() ?? "";

          final isPrimaryMobileVal = isMobileSelected ? "Y" : "N";
          final isPrimaryEmailVal = isEmailSelected ? "Y" : "N";

          // ✅ CUSTOMER: programFlag = "CUST"
          const String programFlag = "CUST";
          final String paramValue = iSrvcReqDtlCode.isNotEmpty
              ? iSrvcReqDtlCode
              : iLeadId;

          // ✅ 1. Update UI instantly (optimistic update)
          _updatePrimaryLocally(index, isPrimaryMobileVal, isPrimaryEmailVal);

          try {
            // ✅ 2. Call API (shared function, different programFlag)
            final response = await markPrimaryContact(
              sapCode: StaticVariables.mSAPCode,
              programFlag: programFlag,
              paramValue: paramValue,
              mobileNo: contactMobile,
              emailId: contactEmail,
              isPrimaryMobile: isPrimaryMobileVal,
              isPrimaryEmail: isPrimaryEmailVal,
              callerId: StaticVariables.callerId,
              callerPass: StaticVariables.callerPass!,
              tokenId: StaticVariables.TokenId,
            );
            print("✅ Mark Primary Response: $response");
          } catch (e) {
            print("❌ Mark Primary Error: $e");
            // Optional: Revert UI on error if needed
          }

          if (!mounted) return;

          // ✅ 3. Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CommonMsgPopup(
              title: "Success",
              message:
                  "$type: Mobile = $isMobileSelected | Email = $isEmailSelected",
              icon: Icons.check_circle,
              iconColor: Colors.green,
              onOk: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          );
        },
      ),
    );
  }

  void _updatePrimaryLocally(int index, String isMobile, String isEmail) {
    if (!mounted) return;

    setState(() {
      // Step 1: Clear previous primary flags for this type
      for (var c in contactList) {
        if (isMobile == "Y" && c['isPrimaryMobile'] == "Y") {
          c['isPrimaryMobile'] = "N";
        }
        if (isEmail == "Y" && c['isPrimaryEmail'] == "Y") {
          c['isPrimaryEmail'] = "N";
        }
      }
      // Step 2: Set new primary on selected contact
      contactList[index]['isPrimaryMobile'] = isMobile;
      contactList[index]['isPrimaryEmail'] = isEmail;
      // Step 3: Update badge type
      contactList[index]['contactType'] = (isMobile == "Y" || isEmail == "Y")
          ? "Primary"
          : "Alternate";
    });
  }

  // ─────────────────────────────────────────────
  // 🔹 SUBMIT CONTACT (API Call)
  // ─────────────────────────────────────────────

  Future<void> _handleSubmitContact() async {
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();

    // ✅ Validation
    if (mobile.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter mobile or email ID")),
      );
      return;
    }

    // ✅ Email format validation
    if (email.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    // ✅ Optional: Check connectivity (uncomment if needed)
    // final connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Internet connection not available")),
    //   );
    //   return;
    // }

    try {
      setState(() => isSubmitting = true);

      final isPrimaryMobileVal = isPrimaryMobile ? "Y" : "N";
      final isPrimaryEmailVal = isPrimaryEmail ? "Y" : "N";

      // ✅ USE CUSTOMER API with CORRECT PARAMETERS
      final response = await submitcustomercontact(
        sapCode: StaticVariables.mSAPCode,
        leadNo: iSrvcReqDtlCode.isNotEmpty ? iSrvcReqDtlCode : iLeadId,
        policyNo: iPolicyNo,
        contactNo: mobile,
        emailId: email,
        isPrimaryMobile: isPrimaryMobileVal,
        isPrimaryEmail: isPrimaryEmailVal,
        callerId: StaticVariables.callerId,
        callerPass: StaticVariables.callerPass!,
        tokeId: StaticVariables.TokenId,
      );

      print("✅ SubmitCustomerContact Response: $response");

      // ✅ Parse response
      final table = response['Table'];
      String status = '';
      String message = '';

      if (table != null && table.isNotEmpty) {
        final first = table[0];
        status = first['ResponseCode']?.toString() ?? '';
        message = first['Message']?.toString() ?? '';
      }

      print("📊 Status: $status | Message: $message");

      // ✅ Check success (flexible matching)
      final isSuccess =
          status == 'Success' ||
          status == '1' ||
          status == '0' ||
          message.toLowerCase().contains('success') ||
          response.containsKey('Table'); // Fallback

      if (isSuccess) {
        setState(() {
          // ✅ Clear previous primary if new one is primary
          if (isPrimaryMobileVal == "Y" || isPrimaryEmailVal == "Y") {
            for (var c in contactList) {
              if (isPrimaryMobileVal == "Y") c['isPrimaryMobile'] = "N";
              if (isPrimaryEmailVal == "Y") c['isPrimaryEmail'] = "N";
            }
          }

          // ✅ Add submitted contact to list with flags
          contactList.add({
            "mobile": mobile,
            "email": email,
            "isPrimaryMobile": isPrimaryMobileVal,
            "isPrimaryEmail": isPrimaryEmailVal,
            "contactType":
                (isPrimaryMobileVal == "Y" || isPrimaryEmailVal == "Y")
                ? "Primary"
                : "Alternate",
            "SrvcReqDtlCode": iSrvcReqDtlCode,
            "PolicyNo": iPolicyNo,
            "CustName": iCustName,
          });

          // ✅ Clear form
          mobileController.clear();
          emailController.clear();
          isPrimaryMobile = false;
          isPrimaryEmail = false;
        });

        // ✅ Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Contact submitted successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // ✅ Handle API error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed: ${message.isEmpty ? 'Unknown error' : message}",
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Submit Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 BUILD UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Add New Customer Contact",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        padding: const EdgeInsets.all(12),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Header
                const Text(
                  "Existing Contact Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479E),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Contact List
                contactList.isEmpty
                    ? const Center(
                        child: Text(
                          "No Contacts Available",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: contactList.length,
                        itemBuilder: (context, index) {
                          final c = contactList[index];
                          final mobile = c['mobile']?.toString()?.trim() ?? '';
                          final email = c['email']?.toString()?.trim() ?? '';
                          final type = c['contactType']?.toString() ?? '';

                          return Column(
                            children: [
                              // Mobile Row + Badge
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "MOBILE NO. ${index + 1}:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        mobile.isEmpty
                                            ? 'Not Available'
                                            : mobile,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: mobile.isEmpty
                                              ? Colors.grey
                                              : (c['isPrimaryMobile'] == "Y"
                                                    ? Colors.blue[900]
                                                    : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () => _onBadgeClicked(index),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _getBadgeColor(type),
                                                width: 1.2,
                                              ),
                                              color: type == "Alternate"
                                                  ? Colors.white
                                                  : Colors.blue.shade50,
                                            ),
                                            child: Text(
                                              type,
                                              style: TextStyle(
                                                color: _getBadgeColor(type),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Email Row
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "EMAIL ID ${index + 1}:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        email.isEmpty ? 'Not Available' : email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: email.isEmpty
                                              ? Colors.grey
                                              : (c['isPrimaryEmail'] == "Y"
                                                    ? Colors.blue[900]
                                                    : Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index < contactList.length - 1)
                                const Divider(height: 1, color: Colors.grey),
                            ],
                          );
                        },
                      ),

                const Divider(height: 24),

                // 🔹 Add Contact Button
                Center(
                  child: ElevatedButton(
                    onPressed: _addContact,
                    child: const Text(
                      "Add Contact",
                      style: TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17479E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Add New Contact Form Header
                const Text(
                  "Add New Customer Contact",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479E),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Mobile Input
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: "Mobile Number",
                    filled: true,
                    fillColor: Colors.grey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                    counterText: "",
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isPrimaryMobile,
                      activeColor: const Color(0xFF17479E),
                      onChanged: (val) =>
                          setState(() => isPrimaryMobile = val!),
                    ),
                    const Text(
                      "Primary Mobile",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                // 🔹 Email Input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email ID",
                    filled: true,
                    fillColor: Colors.grey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isPrimaryEmail,
                      activeColor: const Color(0xFF17479E),
                      onChanged: (val) => setState(() => isPrimaryEmail = val!),
                    ),
                    const Text("Primary Email", style: TextStyle(fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔹 Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _handleSubmitContact,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Submit", style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17479E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
