import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/common/common_confirmation_popup.dart';
import 'package:flutter_bottom_nav/common/common_primary_popup.dart';
import 'package:flutter_bottom_nav/core/apicall/async_mark_primary_contact.dart';
import 'package:flutter_bottom_nav/core/apicall/async_submit_agent_contact.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';

class AddCustomerContactScreen extends StatefulWidget {
  final List<Map<String, dynamic>> contactList;

  const AddCustomerContactScreen({Key? key, required this.contactList})
    : super(key: key);

  @override
  _AddCustomerContactScreenState createState() =>
      _AddCustomerContactScreenState();
}

class _AddCustomerContactScreenState extends State<AddCustomerContactScreen> {
  bool isPrimaryMobile = false;
  bool isPrimaryEmail = false;

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  late List<Map<String, dynamic>> contactList;

  //Adding API VAriable
  String mSAPCode = "";
  String iIntermediaryCode = "";
  String iIntermediaryName = "";
  String mIntermediaryType = ""; //"";
  String mIntermediaryValue = "";
  String callerId = "";
  String callerPass = "";
  String tokeId = "";
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    contactList = List.from(widget.contactList);
    contactList = List.from(widget.contactList);

    if (contactList.isNotEmpty) {
      final first = contactList[0];

      iIntermediaryCode = first['IMDCode']?.toString() ?? "";
      mIntermediaryType = first['SRC']?.toString() ?? "";
      mIntermediaryValue = first['IMDCode']?.toString() ?? "";
      iIntermediaryName = first['IMDName']?.toString() ?? "";
    }

    print("IMDCode: $iIntermediaryCode");
    print("Type: $mIntermediaryType");
  }

  void _addContact() {
    if (mobileController.text.isEmpty && emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter Mobile or Email")));
      return;
    }

    //comment start by rahul
    // setState(() {
    //   if (isPrimaryMobile || isPrimaryEmail) {
    //     for (var c in contactList) c['isPrimary'] = "N";
    //   }

    //   contactList.add({
    //     "mobile": mobileController.text.trim(),
    //     "email": emailController.text.trim(),
    //     // "contactType": "Alternate",
    //     "isPrimary": (isPrimaryMobile || isPrimaryEmail) ? "Y" : "N",
    //     "contactType": (isPrimaryMobile || isPrimaryEmail)
    //         ? "Primary"
    //         : "Alternate",
    //   });

    //   mobileController.clear();
    //   emailController.clear();
    //   isPrimaryMobile = false;
    //   isPrimaryEmail = false;
    // });

    //End by rahul

    setState(() {
      if (isPrimaryMobile || isPrimaryEmail) {
        for (var c in contactList) {
          if (isPrimaryMobile) c['isPrimaryMobile'] = "N";
          if (isPrimaryEmail) c['isPrimaryEmail'] = "N";
        }
      }

      contactList.add({
        "mobile": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "isPrimaryMobile": isPrimaryMobile ? "Y" : "N",
        "isPrimaryEmail": isPrimaryEmail ? "Y" : "N",
        "contactType": (isPrimaryMobile || isPrimaryEmail)
            ? "Primary"
            : "Alternate",
      });

      mobileController.clear();
      emailController.clear();
      isPrimaryMobile = false;
      isPrimaryEmail = false;
    });
  }

  void _onBadgeClicked(int index) {
    final c = contactList[index];
    final type = c['contactType']?.toString() ?? 'Alternate';

    final mobile = c['mobile']?.toString()?.trim() ?? '';
    final email = c['email']?.toString()?.trim() ?? '';

    final safeMobile =
        (mobile.isEmpty ||
            mobile.toLowerCase() == 'not available' ||
            mobile.toLowerCase() == 'null')
        ? "Not Available"
        : mobile;

    final safeEmail =
        (email.isEmpty ||
            email.toLowerCase() == 'not available' ||
            email.toLowerCase() == 'null')
        ? "Not Available"
        : email;

    print("Clicked Type=$type, Index=$index");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dailogContext) => CommonConfirmationPopup(
        title: "Confirmation",
        message:
            "Are you sure, You want to make \n selected contact as Primary Contact",
        mobileNumber: safeMobile,
        emailId: safeEmail,

        onConfirm: (bool isMobileSelected, bool isEmailSelected) async {
          //Navigator.of(dailogContext).pop();
          //Navigator.of(context, rootNavigator: true).pop();

          final selectedContact = contactList[index];

          final mobile = selectedContact['mobile']?.toString() ?? "";
          final email = selectedContact['email']?.toString() ?? "";

          final isPrimaryMobileVal = isMobileSelected ? "Y" : "N";
          final isPrimaryEmailVal = isEmailSelected ? "Y" : "N";

          String programFlag = "AGNT";
          String paramValue = iIntermediaryCode;

          // ✅ 1. Update UI instantly (like Android)
          _updatePrimaryLocally(index, isPrimaryMobileVal, isPrimaryEmailVal);

          try {
            // ✅ 2. Call API
            final response = await markPrimaryContact(
              sapCode: StaticVariables.mSAPCode,
              programFlag: programFlag,
              paramValue: paramValue,
              mobileNo: mobile,
              emailId: email,
              isPrimaryMobile: isPrimaryMobileVal,
              isPrimaryEmail: isPrimaryEmailVal,
              callerId: StaticVariables.callerId,
              callerPass: StaticVariables.callerPass!,
              tokenId: StaticVariables.TokenId,
            );

            print("Mark Primary Response: $response");
          } catch (e) {
            print("Mark Primary Error: $e");
          }

          if (!mounted) return;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CommonMsgPopup(
              title: "Success",
              message:
                  "$type: Mobile = $isMobileSelected | Email = $isEmailSelected",
              icon: Icons.check_circle,
              iconColor: Colors.green,
              onOk: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       "$type: Mobile = $isMobileSelected | Email = $isEmailSelected",
          //     ),
          //     backgroundColor: Colors.green,
          //   ),
          // );
          // ✅ 3. Snackbar (INSIDE callback)
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       "$type: Mobile = $isMobileSelected | Email = $isEmailSelected",
          //     ),
          //     backgroundColor: Colors.green,
          //   ),
          // );
        },
      ),
    );
  }

  void _updatePrimaryLocally(int index, String isMobile, String isEmail) {
    if (!mounted) return;

    setState(() {
      // Step 1: Remove previous primary
      for (var c in contactList) {
        if (isMobile == "Y" && c['isPrimaryMobile'] == "Y") {
          c['isPrimaryMobile'] = "N";
        }
        if (isEmail == "Y" && c['isPrimaryEmail'] == "Y") {
          c['isPrimaryEmail'] = "N";
        }
      }

      // Step 2: Set new primary EXACTLY like Android
      contactList[index]['isPrimaryMobile'] = isMobile;
      contactList[index]['isPrimaryEmail'] = isEmail;

      // Step 3: Update UI badge
      if (isMobile == "Y" || isEmail == "Y") {
        contactList[index]['contactType'] = "Primary";
      } else {
        contactList[index]['contactType'] = "Alternate";
      }
    });
  }

  Color _getBadgeColor(String type) =>
      (type == "Default" || type == "Primary") ? Colors.blue : Colors.grey;

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
                const Text(
                  "Existing Contact Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479E),
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ Contact List - Android-matching layout, small fonts
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
                                          //changes by rahul
                                          // color: email.isEmpty
                                          //     ? Colors.grey
                                          //     : Colors.blue[900],
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

                // Add Contact Button
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

                // Add New Contact Form
                const Text(
                  "Add New Customer Contact",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17479E),
                  ),
                ),
                const SizedBox(height: 12),

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

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _handleSubmitContact,

                    // TODO: Add API submission logic here

                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text(
                    //       "Ready to submit ${contactList.length} contacts",
                    //     ),
                    //   ),
                    // );
                    child: const Text("Submit", style: TextStyle(fontSize: 13)),
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

  Future<void> _handleSubmitContact() async {
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();

    if (mobile.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter mobile or email ID")),
      );
      return;
    }
    if (email.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email address")),
      );

      return;
    }

    //Internet Connectivity

    // final ConnectivityResult = await Connectivity().checkConnectivity();
    // if (ConnectivityResult == ConnectivityResult.none) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Internet connection not available.")),
    //   );
    //   return;
    // }

    try {
      //loading
      //setState(() => isSubmitting = true);

      //flags

      final isPrimaryMobileVal = isPrimaryMobile ? "Y" : "N";
      final isPrimaryEmailVal = isPrimaryEmail ? "Y" : "N";

      //API Call
      final response = await submitagentcontact(
        sapCode: StaticVariables.mSAPCode,
        intermediaryType: mIntermediaryType,
        intermediaryValue: mIntermediaryValue,
        intermediaryName: iIntermediaryName,
        contactNo: mobile,
        emailId: email,
        isPrimaryMobile: isPrimaryMobileVal,
        isPrimaryEmail: isPrimaryEmailVal,
        callerId: StaticVariables.callerId,
        callerPass: StaticVariables.callerPass!,
        tokenId: StaticVariables.TokenId,
      );

      print("SubmitAgentContact Response : $response");

      final table = response['Table'];

      String status = '';
      String message = '';

      if (table != null && table.isNotEmpty) {
        final first = table[0];

        status = first['ResponseCode']?.toString() ?? '';
        message = first['Message']?.toString() ?? '';
      }

      print("Status: $status | Message: $message");

      print("For referenceeeeeee  status :  $status with msg $message");
      final isSucess =
          status == 'Success' ||
          status == '1' ||
          status == '0' ||
          message.toLowerCase().contains('Success');

      if (isSucess) {
        setState(() {
          //Comment by rahul on 27/04/2026
          // if (isPrimaryMobileVal == "Y" || isPrimaryEmailVal == "Y") {
          //   for (var c in contactList) {
          //     if (c['isPrimary'] == "Y") {
          //       c['isPrimary'] = "N";
          //     }
          //   }
          // }
          if (isPrimaryMobileVal == "Y" || isPrimaryEmailVal == "Y") {
            for (var c in contactList) {
              if (isPrimaryMobileVal == "Y") {
                c['isPrimaryMobile'] = "N";
              }
              if (isPrimaryEmailVal == "Y") {
                c['isPrimaryEmail'] = "N";
              }
            }
          }

          //end by rahul

          // Add new contact changes by rahul 27 apr 2026
          // contactList.add({
          //   "mobile": mobile,
          //   "email": email,
          //   "contactType":
          //       (isPrimaryMobileVal == "Y" || isPrimaryEmailVal == "Y")
          //       ? "Primary"
          //       : "Alternate",
          //   "isPrimary": (isPrimaryMobileVal == "Y" || isPrimaryEmailVal == "Y")
          //       ? "Y"
          //       : "N",
          // });

          //added by rahul 27 apr 2026
          contactList.add({
            "mobile": mobile,
            "email": email,
            "isPrimaryMobile": isPrimaryMobileVal,
            "isPrimaryEmail": isPrimaryEmailVal,
            "contactType":
                (isPrimaryMobileVal == "Y" || isPrimaryEmailVal == "Y")
                ? "Primary"
                : "Alternate",
          });
          //end

          mobileController.clear();
          emailController.clear();
          isPrimaryMobile = false;
          isPrimaryEmail = false;
        });
      }

      // final maskedMobile = mobile.isNotEmpty ? _maskMobile(mobile):"";
      // final maskedEmail = email.isNotEmpty ? _maskEmail(email):"";
    } catch (e) {
      print("Error $e");
    }
  }
}
