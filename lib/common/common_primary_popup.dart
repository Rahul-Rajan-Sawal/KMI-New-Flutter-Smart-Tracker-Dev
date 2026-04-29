import 'package:flutter/material.dart';

class CommonConfirmationPopup extends StatefulWidget {
  final String title; // Dialog header
  final String message; // Confirmation message
  final String mobileNumber; // Mobile number to check availability
  final String emailId; // Email to check availability
  final Function(bool primaryMobile, bool primaryEmail) onConfirm; // Callback

  const CommonConfirmationPopup({
    Key? key,
    required this.title,
    required this.message,
    required this.mobileNumber,
    required this.emailId,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<CommonConfirmationPopup> createState() =>
      _CommonConfirmationPopupState();
}

class _CommonConfirmationPopupState extends State<CommonConfirmationPopup> {
  bool primaryMobile = false; // Checkbox state for Primary Mobile
  bool primaryEmail = false; // Checkbox state for Primary Email

  bool get isMobileAvailable {
    final val = widget.mobileNumber.trim().toLowerCase();
    return val.isNotEmpty &&
        val != 'not available' &&
        val != 'null' &&
        val != 'na' &&
        val != '-';
  }

  bool get isEmailAvailable {
    final val = widget.emailId.trim().toLowerCase();
    return val.isNotEmpty &&
        val != 'not available' &&
        val != 'null' &&
        val != 'na' &&
        val != '_';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ HEADER - Blue background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF003399),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ MESSAGE - Confirmation text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ CHECKBOXES - Primary Mobile & Email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Primary Mobile Checkbox
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(
                          "Primary Mobile",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            // Gray out if not available
                            color: isMobileAvailable
                                ? const Color(0xFF003399)
                                : Colors.grey,
                          ),
                        ),
                        value: primaryMobile,
                        activeColor: const Color(
                          0xFF003399,
                        ), // Blue when checked
                        // Disable if mobile not available
                        onChanged: isMobileAvailable
                            ? (value) => setState(() => primaryMobile = value!)
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Primary Email Checkbox
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(
                          "Primary Email",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            // Gray out if not available
                            color: isEmailAvailable
                                ? const Color(0xFF003399)
                                : Colors.grey,
                          ),
                        ),
                        value: primaryEmail,
                        activeColor: const Color(0xFF003399),
                        // Disable if email not available
                        onChanged: isEmailAvailable
                            ? (value) => setState(() => primaryEmail = value!)
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ BUTTONS - NO and YES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // NO Button - Gray
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(), // Close dialog
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: const Color(0xFF003399),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "NO",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // YES Button - Blue
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ Validation: At least one checkbox must be selected
                      if (!primaryMobile && !primaryEmail) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please select at least Primary Mobile or Primary Email",
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      // Close dialog and call callback with selected options
                      Navigator.of(context).pop();
                      widget.onConfirm(primaryMobile, primaryEmail);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "YES",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
