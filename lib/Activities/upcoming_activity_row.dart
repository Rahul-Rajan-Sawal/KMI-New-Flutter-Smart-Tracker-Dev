import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeadCardWidget extends StatelessWidget {
  final Map<String, dynamic> leadData;
  final VoidCallback onViewDetails;
  final VoidCallback onCall;
  final VoidCallback onEmail;
  final VoidCallback onMessage;
  final VoidCallback onUpdateAcitivity;
  final String pageFlag;

  const LeadCardWidget({
    super.key,
    required this.leadData,
    required this.onViewDetails,
    required this.onCall,
    required this.onEmail,
    required this.onMessage,
    required this.onUpdateAcitivity,
    required this.pageFlag,
    //add flag required this.mflag,
  });

  @override
  Widget build(BuildContext context) {
    /// API VALUES
    final String leadType = (leadData["leadType"] ?? "fresh")
        .toString()
        .toLowerCase();

    /// CARD COLOR
    final Color indicatorColor = leadType == "renewal"
        ? const Color(0xff800000) // MAROON
        : const Color(0xff1565C0); // BLUE

    return Container(
      margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP INDICATOR
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// NAME + VIEW DETAILS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leadData["customerName"] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff424242),
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              "(${leadData["leadId"] ?? ""})",
                              style: TextStyle(
                                fontSize: 14,
                                color: indicatorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// VIEW DETAILS
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: onViewDetails,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                color: indicatorColor,
                                size: 28,
                              ),

                              const SizedBox(height: 2),

                              Text(
                                "VIEW DETAILS",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: indicatorColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// PRODUCT + PREMIUM
                  buildRow(
                    leftTitle: "PRODUCT",
                    leftValue: leadData["product"] ?? "NA",
                    rightTitle: "PREMIUM",
                    rightValue: leadData["premium"] ?? "NA",
                    color: indicatorColor,
                  ),

                  const SizedBox(height: 12),

                  /// POLICY + NCB
                  buildRow(
                    leftTitle: "POLICY NUMBER",
                    leftValue: leadData["policyNumber"] ?? "NA",
                    rightTitle: "NCB",
                    rightValue: leadData["ncb"] ?? "NA",
                    color: indicatorColor,
                  ),

                  const SizedBox(height: 12),

                  /// VEHICLE + ADDON
                  buildRow(
                    leftTitle: "VEHICLE MAKE & MODEL",
                    leftValue: leadData["vehicleModel"] ?? "NA",
                    rightTitle: "ADD-ON",
                    rightValue: leadData["addon"] ?? "NA",
                    color: indicatorColor,
                  ),

                  const SizedBox(height: 12),

                  /// STATUS + DATE TIME
                  buildRow(
                    leftTitle: "LEAD STATUS / LAST ACTIVITY",
                    leftValue: leadData["leadStatus"] ?? "NA",
                    rightTitle: "DATE & TIME",
                    rightValue: leadData["date"] ?? "NA",
                    color: indicatorColor,
                  ),

                  const SizedBox(height: 12),

                  /// PAYMENT LINK + COPY
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "RENEWAL PAYMENT LINK",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              leadData["paymentLink"] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: indicatorColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: leadData["paymentLink"] ?? "",
                                ),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Copied Successfully"),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.copy,
                                color: indicatorColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// BOTTOM ACTIONS
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        actionButton(
                          icon: Icons.call,
                          label: "Call",
                          color: indicatorColor,
                          onTap: onCall,
                        ),

                        actionButton(
                          icon: Icons.message,
                          label: "Message",
                          color: indicatorColor,
                          onTap: onMessage,
                        ),

                        actionButton(
                          icon: Icons.email,
                          label: "Email",
                          color: indicatorColor,
                          onTap: onEmail,
                        ),

                        // actionButton(
                        //   icon: Icons.phone_callback_outlined,
                        //   label: "Call Status",
                        //   color: indicatorColor,
                        //   onTap: () {
                        //     print("CALL STATUS CLICKED");
                        //   },
                        // ),
                        if (pageFlag == "Renewal")
                          actionButton(
                            icon: Icons.edit,
                            label: "Update Activity",
                            color: indicatorColor,
                            onTap: onUpdateAcitivity,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// REUSABLE ROW
  Widget buildRow({
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: infoColumn(
            title: leftTitle,
            value: leftValue,
            alignRight: false,
            color: color,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: infoColumn(
            title: rightTitle,
            value: rightValue,
            alignRight: true,
            color: color,
          ),
        ),
      ],
    );
  }

  /// REUSABLE INFO COLUMN
  Widget infoColumn({
    required String title,
    required String value,
    required bool alignRight,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          softWrap: true,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// REUSABLE ACTION BUTTON
  Widget actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),

            const SizedBox(height: 5),

            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
