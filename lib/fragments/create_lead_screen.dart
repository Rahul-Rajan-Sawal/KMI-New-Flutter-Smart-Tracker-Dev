import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen>
    with SingleTickerProviderStateMixin {
  int selectedTabIndex = 0;
  late TabController _tabController;
  String? selectedRequestChannel;
  String? selectedLeadSource;
  String? selectedSubLeadSource;

  void onPersonalDetailsClick() {
    if (selectedRequestChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Request Channel")),
      );
      return;
    }
    if (selectedLeadSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Source")),
      );
      return;
    }
    if (selectedSubLeadSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Sub Source")),
      );
      return;
    }

    _tabController.animateTo(1);
  }

  void validateLeadSourceAndMoveNext() {
    if (selectedRequestChannel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Request Channel")),
      );
      return;
    }
    if (selectedLeadSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Source")),
      );
      return;
    }
    if (selectedSubLeadSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select Lead Sub Source")),
      );
      return;
    }

    _tabController.animateTo(1);
  }

  void handleClear() {
    if (selectedTabIndex == 0) {
      selectedRequestChannel = null;
      selectedLeadSource = null;
      selectedSubLeadSource = null;
    } else if (selectedTabIndex == 1) {
    } else if (selectedTabIndex == 2) {
    } else if (selectedTabIndex == 3) {}
    setState(() {});
  }

  void handleNextorFinish() {
    if (selectedTabIndex < 3) {
      _tabController.animateTo(selectedTabIndex + 1);
    } else {
      submitLead();
    }
  }

  void submitLead() {
    print("Submit API called");
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          //title: const Text("Create Lead"),
          bottom: ButtonsTabBar(
            backgroundColor: Colors.blue,
            unselectedBackgroundColor: Colors.white,
            borderWidth: 1.5,
            borderColor: Colors.black,

            height: 70,

            // contentPadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(icon: Icon(Icons.menu, size: 30)),
              Tab(icon: Icon(Icons.person, size: 30)),
              Tab(icon: Icon(Icons.location_on, size: 30)),
              Tab(icon: Icon(Icons.work, size: 30)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // LeadSourceTab(),
            // ProfileTab(),
            // AddressTab(),
            // BusinessTab(),
          ],
        ),
      ),
    );
  }

  Widget bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                handleClear();
              },
              child: const Text("Clear"),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: () {
                handleNextorFinish();
              },
              child: Text(selectedTabIndex == 3 ? "Finish" : "Next"),
            ),
          ),
        ],
      ),
    );
  }

  Widget leadSourceTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              //Drop Down Logic
            ],
          ),
        ),

        bottomButtons(),
      ],
    );
  }

  Widget profileTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              //profile fields
            ],
          ),
        ),
        bottomButtons(),
      ],
    );
  }

  Widget address() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              //Address fields
            ],
          ),
        ),
        bottomButtons(),
      ],
    );
  }
}
