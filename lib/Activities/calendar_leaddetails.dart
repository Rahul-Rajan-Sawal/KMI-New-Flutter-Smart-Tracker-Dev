import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/view_details.dart';
import 'package:flutter_bottom_nav/Providers/Calendarlead/calendar_lead_provider.dart';
import 'package:flutter_bottom_nav/core/repository/leaddetails_repository.dart';
import 'package:flutter_bottom_nav/models/Calendar/calendar_lead_args.dart';
import 'package:flutter_bottom_nav/models/Calendar/lead_card_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Leaddetails extends ConsumerWidget {
  final CalendarLeadArgs args;

  const Leaddetails({super.key, required this.args});

  String get formattedSelectedDate {
    return DateFormat('dd/MM/yyyy').format(args.selectedDate);
  }

  String get businessTypeTitle {
    final businessType = args.businessType.trim().toUpperCase();

    if (businessType == 'R' ||
        businessType == 'RENEWAL' ||
        businessType == '3') {
      return 'Renewal';
    }

    return 'Fresh';
  }

  String get currentTime {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadState = ref.watch(calendarLeadProvider(args));

    final bool isRenewal = businessTypeTitle == 'Renewal';

    final Color indicatorColor = isRenewal
        ? const Color(0xff9B1C1F)
        : const Color(0xff1565C0);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Lead Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),

          const SizedBox(height: 8),

          Expanded(
            child: leadState.when(
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },

              error: (error, stackTrace) {
                return _buildErrorState(
                  context: context,
                  ref: ref,
                  error: error,
                );
              },

              data: (leadList) {
                if (leadList.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () {
                    return ref
                        .read(calendarLeadProvider(args).notifier)
                        .forceRefresh();
                    // .read(calendarLeadProvider(args).notifier)
                    // .refreshLocal();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 105),
                    itemCount: leadList.length,
                    itemBuilder: (context, index) {
                      final lead = leadList[index];

                      return _buildLeadCard(
                        context: context,
                        lead: lead,
                        indicatorColor: indicatorColor,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xff1565C0),
            onPressed: () {
              ref.read(calendarLeadProvider(args).notifier).refreshLocal();
            },
            child: const Icon(Icons.refresh, color: Colors.white),
          ),

          const SizedBox(height: 5),

          const Text(
            'Refresh',
            style: TextStyle(
              color: Color(0xff1565C0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$businessTypeTitle >> $formattedSelectedDate',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Showing Date',
                      style: TextStyle(
                        color: Color(0xff1E4FA3),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      formattedSelectedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timing',
                      style: TextStyle(
                        color: Color(0xff1E4FA3),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      currentTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard({
    required BuildContext context,
    required LeadCardModel lead,
    required Color indicatorColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.customerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff424242),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '(${lead.leadId})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: indicatorColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () {
                          _openLeadDetails(context, lead);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              color: indicatorColor,
                              size: 32,
                            ),

                            const SizedBox(height: 2),

                            Text(
                              'VIEW\nDETAILS',
                              textAlign: TextAlign.center,
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

                const SizedBox(height: 18),

                _buildRow(
                  leftTitle: 'PRODUCT',
                  leftValue: lead.product,
                  rightTitle: 'PREMIUM',
                  rightValue: lead.premium,
                ),

                const SizedBox(height: 18),

                _buildRow(
                  leftTitle: 'POLICY NUMBER',
                  leftValue: lead.policyNumber,
                  rightTitle: 'NCB',
                  rightValue: lead.ncb,
                ),

                const SizedBox(height: 18),

                _buildRow(
                  leftTitle: 'VEHICLE MAKE & MODEL',
                  leftValue: lead.vehicleModel,
                  rightTitle: 'PAYMENT LINK',
                  rightValue: lead.paymentLink == 'Not Available'
                      ? 'Not Available'
                      : 'Available',
                ),

                const SizedBox(height: 18),

                _buildRow(
                  leftTitle: 'LEAD STATUS / LAST ACTIVITY',
                  leftValue: lead.lastActivity,
                  rightTitle: 'DATE & TIME',
                  rightValue: lead.dateTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),

            const SizedBox(height: 12),

            Text(
              'No lead details found for '
              '$formattedSelectedDate',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Expected calendar count: '
              '${args.expectedCount}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required BuildContext context,
    required WidgetRef ref,
    required Object error,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),

            const SizedBox(height: 12),

            const Text(
              'Unable to load lead details.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                ref.read(calendarLeadProvider(args).notifier).refreshLocal();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftTitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                leftValue,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xff1E4FA3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rightTitle,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                rightValue,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xff1E4FA3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openLeadDetails(
    BuildContext context,
    LeadCardModel lead,
  ) async {
    final leadDetails = await LeadDetailsRepository.fetchLeadDetailsById(
      lead.leadId,
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
        "VehicleType",
      ],
    );

    if (leadDetails == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewDetails(
          lead: {
            "SrvcReqDtlCode": lead.leadId,
            "Name": lead.customerName,
            "ProdName": lead.product,
            "leadAmt": lead.premium,
            "PolicyNo": lead.policyNumber,
          },
          decryptedLead: leadDetails,
        ),
      ),
    );
  }

  // void _openLeadDetails(BuildContext context, LeadCardModel lead) {
  //   // We will replace this with actual navigation
  //   // after checking your target View Details page.
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Open lead details: ${lead.leadId}')),
  //   );
  // }
}
