import 'package:flutter/material.dart';

class LeadUpdateNew extends StatefulWidget {
  final Map<String, dynamic> lead;

  const LeadUpdateNew({Key? key, required this.lead}) : super(key: key);

  @override
  _LeadUpdateState createState() => _LeadUpdateState();
}

class _LeadUpdateState extends State<LeadUpdateNew> {
  String? selectedActivity;
  String? selectedSubActivity;

  final TextEditingController policyNumberCtrl = TextEditingController();
  final TextEditingController instrumentNumberCtrl = TextEditingController();
  final TextEditingController instrumentAmountCtrl = TextEditingController();
  final TextEditingController competitorPolicyCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController callbackDateCrtl = TextEditingController();
  final TextEditingController appointDateCrtl = TextEditingController();
  final TextEditingController expclosdateCrtl = TextEditingController();

  final List<String> activityList = ['Sale Closed', 'Lead Open', 'Lead Lost'];

  final List<String> saleClosedSub = ['Premium Collected', 'Policy Issued'];
  final List<String> leadLostSub = [
    'Lost to Competitor',
    'Customer Not Interested',
    'Customer Not Responding',
  ];

  final List<String> leadOpenSub = [
    'Call Back',
    'Appointment Fixed',
    'Non Contactable',
  ];

  @override
  Widget build(BuildContext context) {
    final double fieldHeight = MediaQuery.of(context).size.height * 0.055;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Update Leads'),
        // backgroundColor: const Color(0xFF090979),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel('Activity *'),
            buildDropdown(
              'Activity *',
              fieldHeight,
              value: selectedActivity,
              items: activityList,
              onChanged: (val) {
                setState(() {
                  selectedActivity = val;
                  selectedSubActivity = null;
                });
              },
            ),
            if (selectedActivity != null) ...[
              buildLabel('Sub Activity *'),
              buildDropdown(
                'Sub Activity *',
                fieldHeight,
                value: selectedSubActivity,
                items: selectedActivity == 'Sale Closed'
                    ? saleClosedSub
                    : selectedActivity == 'Lead Open'
                    ? leadOpenSub
                    : leadLostSub,
                onChanged: (val) {
                  setState(() => selectedSubActivity = val);
                },
              ),
            ],
            const SizedBox(height: 8),
            buildDynamicSection(fieldHeight),
            buildButton('Save'),
          ],
        ),
      ),
    );
  }

  Widget buildDynamicSection(double fieldHeight) {
    switch (selectedActivity) {
      case 'Sale Closed':
        return buildSaleClosedUI(fieldHeight);

      case 'Lead Lost':
        return buildLeadLostUI(fieldHeight);

      case 'Lead Open':
        return buildLeadOpenUI(fieldHeight);

      default:
        return const SizedBox();
    }
  }

  Widget buildSaleClosedUI(double fieldHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel('Policy Number *'),
        buildTextField(fieldHeight, policyNumberCtrl, 'Policy Number *'),
        buildLabel('Instrument Type *'),
        buildDropdown(
          'Instrument Type *',
          fieldHeight,
          value: null,
          items: ['Cheque', 'Online', 'Cash'],
          onChanged: (_) {},
        ),
        buildLabel('Instrument Number *'),
        buildTextField(
          fieldHeight,
          instrumentNumberCtrl,
          'Instrument Number *',
        ),
        buildLabel('Instrument Amount *'),
        buildTextField(
          fieldHeight,
          instrumentAmountCtrl,
          'Instrument Amount *',
        ),
        buildLabel('Remark *'),
        buildTextField(fieldHeight, remarkCtrl, 'Remark *'),
      ],
    );
  }

  Widget buildLeadLostUI(double fieldHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel('Policy Number of Competitor'),
        buildTextField(
          fieldHeight,
          competitorPolicyCtrl,
          'Policy Number of Competitor',
        ),
        buildLabel('Company Name of Competitor'),
        buildDropdown(
          'Company Name of Competitor',
          fieldHeight,
          value: null,
          items: ['HDFC', 'ICICI', 'LIC'],
          onChanged: (_) {},
        ),
        buildLabel('New Policy Enrd Date'),
        buildDateField('New Policy Enrd Date', fieldHeight, dateCtrl),
        buildLabel('Remark *'),
        buildTextField(fieldHeight, remarkCtrl, 'Remark *'),
      ],
    );
  }

  Widget buildLeadOpenUI(double fieldHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedSubActivity == 'Call Back') ...[
          buildLabel('Call Back *'),
          buildDateField('Call Back *', fieldHeight, callbackDateCrtl),
          buildLabel('Expected Closure Date *'),
          buildDateField(
            'Expected Closure Date ',
            fieldHeight,
            expclosdateCrtl,
          ),
        ],
        if (selectedSubActivity == 'Appointment Fixed') ...[
          buildLabel('Appointment Date *'),
          buildDateField('Appointment Date *', fieldHeight, appointDateCrtl),
          buildLabel('Expected Closure Date *'),
          buildDateField(
            'Expected Closure Date *',
            fieldHeight,
            expclosdateCrtl,
          ),
        ],
        buildLabel('Remark *'),
        buildTextField(fieldHeight, remarkCtrl, 'Remark *'),
      ],
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget buildTextField(
    double height,
    TextEditingController controller,
    String hintText, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: SizedBox(
          height: maxLines == 1 ? height : height * 1.6,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.fromLTRB(12, 14, 12, 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(
    String hintText,
    double height, {
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: SizedBox(
          height: height,
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            items: items
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateField(
    String hintText,
    double height,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        child: SizedBox(
          height: height,
          child: TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_today),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(12, 14, 12, 14),
              hintText: hintText,
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                controller.text = '${date.day}/${date.month}/${date.year}';
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17479E),
            textStyle: TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: () {},
          child: Text(text),
        ),
      ),
    );
  }
}
